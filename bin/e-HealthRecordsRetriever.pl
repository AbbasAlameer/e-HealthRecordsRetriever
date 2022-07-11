#!/usr/bin/env perl

##########################################################################################################################################################################################
#                                                                                                                                                                                        #
#                                                                                                                                                                                        #
# e-HealthRecordsRetriever, version 1.0                                                                                                                                                  #
# -------------------------------------                                                                                                                                                  #
#                                                                                                                                                                                        #        
# Last Update: 11/7/22                                                                                                                                                                   #
#                                                                                                                                                                                        #
# Author:   Abbas Alameer <abbas.alameer@ku.edu.kw>,                                                                                                                                     #
#                      Kuwait University                                                                                                                                                 #
#                                                                                                                                                                                        #
# Please email queries, suggestions, and possible bug information to the above author.                                                                                                   #
#                                                                                                                                                                                        #
##########################################################################################################################################################################################

use warnings;
use strict;
use Term::ANSIColor;
use Getopt::Long qw(GetOptions);
use Cwd qw(cwd);
use Spreadsheet::Read;

my $url_start_date 			= "2019-05-20";
my $url_end_date			= "2019-05-25";
my $i						= 1;
my $plos_webpage			= "plos_results_page-";
my $argv_line;
my $user_eHR_query;
my $input_command_line;
my $help;
my $dir 					= cwd();
my @arr_doi_web_links		= ();
my @arr_doi_ID 				= ();
my @arr_spreadsheet_file	= ();
my @e_healthRecords			= ();
my $file					= "";

main();


###################################################
#                                                 #
#             SUBROUTINES BELOW                   #
#             -----------------                   #
#                                                 #
###################################################

############################ SUBROUTINE 1 #######################################################
#This subroutine prints the program details at start-up.
sub start_up {
	
	print color ("yellow"),"  
#######################################################################
#                                                                     #
#                    e-HealthRecordsRetriever v1.0                    #
#                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                    #
#                                                                     #
#                Author:  Abbas Alameer, Kuwait University            #
#                         abbas.alameer\@ku.edu.kw                     #
#                                                                     #
#                                                                     #
#                       Developed in April 2022                       #
#                     and released under GPLv2 license                #
#                                                                     #
#######################################################################\n\n\n" , color("reset");
}
############################ SUBROUTINE 2 #######################################################
#This subroutine checks all command line input switches and arguments (including optional ones).
#It warns the user if mandatory command-line input switches and arguments are missing.
sub input_parameters_check {


	my $help_message1  = "Usage: e-HealthRecordsRetriever -h [-s DISEASE_ELECTRONIC_HEALTH_RECORDS]";
	my $help_message2  = "Mandatory argument:
	-s                    the disease-associated electronic health record as query search term
Optional argument:
	-h                    show help message and exit\n";
 
 
 	#get command line parameters from @ARGV and append them all in string. Used for later output at the end of a run.	
	foreach my $element (@ARGV) {
	
		if ($element !~ m/-s/) {
		
			$argv_line .= "\"$element\" ";
			
		} else {
		
			$argv_line .= "$element ";
		}
	}

	if ($argv_line) {
		
		$input_command_line = "User input command: e-HealthRecordsRetriever $argv_line";
	}
     
    GetOptions(
        's=s'  => \$user_eHR_query,
        'h'    => \$help
    );
     
    if ($help) {
		
		print color ("green"), "$help_message1\n\n$help_message2", color("reset");
		exit;
	}
	
    elsif (!$user_eHR_query) {
			
        print color ("red"), "Error: arguments are missing...\n", color("reset");
        print color ("green"),"$help_message1\n", color("reset");
        exit;
    }
}
############################ SUBROUTINE 3 #######################################################
sub download_plos_webpages {
	
	#example eHR query: "neuroblastoma+electronic health records"
	my @url_eHR_query	= split /\s+/, $user_eHR_query;
	my $url_search_term = shift(@url_eHR_query);
	my $file_name		= "$url_search_term";

	$url_search_term .= "+ ";

	foreach my $elem (@url_eHR_query) {
		
		$url_search_term .= " $elem";
	}

	#Download atom files in a recursive loop and increment page value by 1
	print color ("green"), "Starting run...\n", color("reset");
	print color ("green"), "Downloading PLOS One search results' webpages:\n", color("reset");

	while (1) {
		
		#page incremented url
		#my $url_string 		= "https://journals.plos.org/plosone/search/feed/atom?filterJournals=PLoSONE&filterStartDate=$url_start_date&filterEndDate=$url_end_date&resultsPerPage=60&q=neuroblastoma+electronic health records&sortOrder=DATE_OLDEST_FIRST&page=$i";
		my $url_string 	= "https://journals.plos.org/plosone/search/feed/atom?filterJournals=PLoSONE&filterStartDate=$url_start_date&filterEndDate=$url_end_date&resultsPerPage=60&q=$url_search_term&sortOrder=DATE_OLDEST_FIRST&page=$i";

		system("lynx -dump \"$url_string\" > $file_name\_$plos_webpage$i");
		
		my $full_filename 	= "$file_name\_$plos_webpage$i";	
		my $dir_filename 		= "$dir/$full_filename";
		
		my $size = -s $dir_filename;
		#print color ("white"), "$full_filename\tSize: $size\n", color("reset");
		
		$i++; #increment page number
		
		#Check the file size before opening a file and moving to the next iteration. 
		#This is done in the event that the page limit has been exceeded by 1, stopping further downloads,
		#and this happens when the last file, considered "empty", is <= 1117KB.
		if ($size <= 1117) {
			
			system("rm $dir_filename"); #get rid of the last file, which is empty of an article list; this is our stopping point.
			last;
		} else {
			
			print color ("white"), "$full_filename\tSize: $size KB\n", color("reset");
			
			#save plos webpages in an array
			push(@arr_doi_web_links, $full_filename);
		}
	}
	
	$i--;
	#print color ("green"), "done\n", color("reset");
	#print "\$i's value is: $i\n";
	print color ("green"), "Downloading all articles' main webpages:\n", color("reset");
}
############################ SUBROUTINE 4 #######################################################
sub doi_download {
	
	my $url_input_file		= $_[0];
	my @arr_doi_url 		= ();
	my $flag 				= 0;
	my $doi_url 			= "";
	my $publication_year;
	my ($sec, $min, $hour, $mday, $mon, $yr, $wday, $yday, $isdst) = localtime();
	my $current_year		= $yr + 1900;
	
	#open input file
	open (FH, "$url_input_file") or die "Cannot open file \"$url_input_file\": $!\n";
	
	while (<FH>) {
		
		#switch flag on when our string marker is found
		if ($_ =~ /\s+\<entry\>/) { 
			
			$flag = 1; 
		} 
		
		elsif ($_ =~ /\s+\<title\>/) { 
			
			$flag += 1; 
		}
		
		elsif ($flag == 2) {
			
			#get DOI URL                       href="https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0175041" title="Inositol 1, 4, 5-trisphosphate-dependent nuclear calcium signals regulate angiogenesis and cell motility in triple negative breast cancer" />
			if ($_ =~ /\s+\<link\s*rel=\".+"\s*href=\"(.+\.\d+)\"\s*title=.+/) {	
				
				$doi_url = $1;
			}
			
			#get 			<published>2017-04-04T14:00:00Z</published>
			elsif ($_ =~ /\s+\<published\>(\d+)-\d+-\d+T.+/) {
				
				$publication_year = $1;
				my $year_limit = $current_year - $publication_year;
				
				if ($year_limit <= 5) {

					#extract an article's DOI ID number
					if ($doi_url =~ /^https:\/\/.+\/(journal\.pone\.\d+)/) {
			
						push(@arr_doi_ID, $1);
					}
					
					#append the DOI url of the article in array
					push(@arr_doi_url, $doi_url);
					$flag = 0;
					
				} else {
					
					#The article is old, check the next one.
					$flag = 0;
					next;
				}
			} 
		} 
	}
	
	print color ("white"), "$url_input_file...", color("reset");
	
	#download the DOI webpage of an article, using cURL.
	foreach (@arr_doi_url) {
		
		system ("curl -s -O -C - $_");
	}
	
	print color ("white"), "done\n", color("reset");
}
############################ SUBROUTINE 5 #######################################################
sub supplementary_data_finder {
	
	my $flag				= 0;
	my $j_pone_ID			= "";
	my $supplementary_file	= "";
	my $file_format			= "";
	
	print color ("green"), "Downloading detected spreadsheet supplmentary file(s):\n", color("reset");
	
	#open each DOI webpage and check for "Data Availability line". 
	foreach $j_pone_ID (@arr_doi_ID) {
		
		#open input file
		open (FH, "$j_pone_ID") or die "Cannot open file \"journal.pone.$j_pone_ID\": $!\n";
		
		while (<FH>) {
	
			if ($_ =~ /.+Data\s?Availability\:.+(Supporting\s?Information\s?files).+/) {
				
				$flag = 1;
			}
			
			#download any supplementary files in CSV, XLS, or XLSX format files, if found.
			if ($flag) {
				
							#<a href="https://doi.org/10.1371/journal.pone.0199920.s002">https://doi.org/10.1371/journal.pone.0199920.s002</a>
				if ($_ =~ /.+<a\shref\=\"(https\:\/\/doi\.org.+)\"\>https\:.+(XLS|XLSX|CSV).+/) {
					
					$supplementary_file 	= $1;
					my ($head, $filename)	= split(/journal./, $supplementary_file);
					$file_format			= lc($2);
					
					print color ("white"), "$filename.$file_format...", color("reset");
					system ("lynx --dump $supplementary_file > $filename.$file_format");
					
					push(@arr_spreadsheet_file, "$filename.$file_format");
					print color ("white"), "done\n", color("reset");
				}
			}
			
			#Switch off flag at EOF.
			elsif ($_ =~ /^<\/html>/) {
				
				$flag = 0;
			}
		}
	}
	
	#reinitialize or "empty" @arr_doi_ID array 
	@arr_doi_ID =  ();
}
############################ SUBROUTINE 6 #######################################################
sub spreadsheet_checker {
	
	my $spreadsheet_file  		 = $_[0];
	my ($spreadsheet_file_csv)	 = split(/\.(xls|csv|xlsx)/, $spreadsheet_file); 
	$spreadsheet_file_csv		.= ".csv";
	
	#convert the file to csv format, as the xlscat processing steps below work the fastest on ".csv" formatted files
	print color ("green"), "Converting file: \"$spreadsheet_file\" into CSV format...\n", color("reset");
	
	system("libreoffice --convert-to csv $spreadsheet_file");
	
	print color ("green"), "Processing file: $spreadsheet_file_csv...\n", color("reset");
	
	my $column_total;
	my $row_total;
	my $file_extraction =  qx(xlscat $spreadsheet_file_csv -i 3>&1 1>&2 2>&3);
	
	#file1.csv - 01: [ file1.csv ]  25 Cols,   492 Rows (Active)
			#file1.xls - 01: [ 1 ]  25 Cols,   492 Rows
	if ($file_extraction =~ /.+\]\s+(\d+)\s+Cols.?\s+(\d+)\s+Rows.*/) {
		
		$column_total	= $1;
		chomp($column_total);
		$row_total		= $2;
		chomp($row_total);
		
		print "\"$spreadsheet_file\" has $column_total columns && $row_total rows.\n";
	}
	
	if ( ($column_total > 10 && $row_total > 10) ) {
		
		#print "The spreadsheet $spreadsheet_file has a small column/row count\n";
		push(@e_healthRecords, $spreadsheet_file);
		
	} #else {
		
		#print "\n***The spreadsheet $spreadsheet_file has a high column/row count, and is a likely TP.***\n";
	#}
}
############################ SUBROUTINE 7 #######################################################
sub main {
	
	#display start-up header
	start_up();
	
	input_parameters_check();
	
	download_plos_webpages();
	
	foreach $file (@arr_doi_web_links) {
		
		doi_download($file);
	}
	
	supplementary_data_finder();
	
	foreach (@arr_spreadsheet_file) {
		
		spreadsheet_checker($_);
	}
	
	print color ("green"), "\n=========================================================================================\n", color("reset");
	print color ("green"), "e-Health Records retrieved:\n";
	
	foreach my $file (@e_healthRecords) {

		print color ("white"), "$file\n";
	}
}

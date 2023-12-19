# e-HealthRecordsRetriever
e-HealthRecordsRetriever is a bioinformatics tool for electronic health record (EHR) retrieval from the PLOS article archives. This tool removes the researcher's burden of manually and tediously searching for EHRs from the PLOS article archives by applying a streamlined process. Valuable data obtained from EHRs is particularly useful in clinical and bioinformatics research.
## Summary
<p>e-HealthRecordsRetriever is a bioinformatics tool for electronic health record (EHR) retrieval from the PLOS article archives. This tool easily retrieves EHRs by using a simple command, specifying the disease-associated EHRs (ex. neuroblastoma electronic health records") and article publication range of the PLOS archive (ex. "2019-05-20--2019-05-23"). This bioinformatics tool functions by applying two filters to examine individual clinical science articles' webpage entries. The first filter flags for EHR-associated keywords (ex. “electronic health record” or “electronic medical record”), while the second filter flags for putative EHRs present as .XLS, .XLSX, or .CSV formatted files that are large datasets. If found, this tool retrieves those flagged electronic health records.</p>

## e-HealthRecordsRetriever dependencies
The dependencies (<i>i.e.</i> packages) used by e-HealthRecordsRetriever are:

<p><ul><li>strict</li></ul></p>
<p><ul><li>warnings</li></ul></p>
<p><ul><li>Term::ANSIColor</li></ul></p>
<p><ul><li>Getopt::Long</li></ul></p>
<p><ul><li>Cwd</li></ul></p>
<p><ul><li>File::HomeDir</li></ul></p>
<p><ul><li>Spreadsheet::Read</li></ul></p>


## Installation
e-HealthRecordsRetriever can be used on any Linux, macOS, or Windows machines. On the Windows operating system you will need to install the Windows Subsystem for Linux (WSL) compatibility layer (<a href="https://docs.microsoft.com/en-us/windows/wsl/install" target="_blank" rel="noopener noreferrer">quick installation instructions</a>). Once WSL is launched, the user can follow the e-HealthRecordsRetriever installation instructions described below.

To run the program, you need to have the following programs installed on your computer:

<p><ul><li><b>Perl</b> (version 5.8.0 or later)</li></ul></p>
<p><ul><li><b>cURL</b> (version 7.68.0 or later)</li></ul></p>
By default, Perl is installed on all Linux or macOS operating systems. Likewise, cURL is installed on all macOS versions. cURL may not be installed on Linux and would need to be manually installed through a Linux distribution’s software centre.
<p></p>

<b>Manual install:</b>
```diff
perl Makefile.PL
make
make install
```

On Linux Ubuntu, you might need to run the last command as a superuser
(`sudo make install`) and you will need to manually install (if not
already installed in your Perl 5 configuration) the following packages:

libfile-homedir-perl

```diff
sudo apt-get install -y libfile-homedir-perl
```
cpanminus

```diff
sudo apt -y install cpanminus
```
Spreadsheet::Read

```diff
perl -MCPAN -e 'install "Spreadsheet::Read"'
```

## Data file
The required input file is a PLOS article archive file, upon querying for any particular disease-associated EHRs (for example, neuroblastoma electronic health records) in e-HealthRecordsRetriever.

## Execution instructions
The basic usage for running e-HealthRecordsRetriever is:

```diff
e-HealthRecordsRetriever -s "DISEASE_ELECTRONIC_HEALTH_RECORDS" -d "PUBLICATION_DATE_RANGE"
```

An example basic usage command using "bladder cancer" as a query: 

```diff
e-HealthRecordsRetriever -s "neuroblastoma electronic health records" -d "2019-05-20--2019-05-23"
```
With the basic usage command, the mandatory -s (search) flag is used to download and then retrieve electronic health records associated with a particular disease (ex. "neuroblastoma"). When using this command, the output files of e-HealthRecordsRetriever will be found in the `~/e-HealthRecordsRetriever/results/` directories.

For specialized options, allowing more fine-grained user control, the following options are made available:

-f <user-specified absolute path to save results files>

A user-specified absolute path to save results files (overriding the default results directory) may by specified prior to execution. For example:

```diff
e-HealthRecordsRetriever -s "neuroblastoma electronic health records" -d "2019-05-20--2019-05-23" -f "/neuroblastoma_EHR_files/"
```

The output files will be found in the user-specified directory (for example, "/neuroblastoma_EHR_files/"), created in the user's home directory.

-k <option to keep temporary files>

This option allows a user to keep large temporary/output files instead of them
being removed by default. For example:

```diff
e-HealthRecordsRetriever -s "neuroblastoma electronic health records" -d "2019-05-20--2019-05-23" -f "/neuroblastoma_EHR_files/" -k
```

<p>Help information can be read by typing the following command:</p>

```diff
e-HealthRecordsRetriever -h
```

<p>This command will print the following instructions:</p>

```diff
Usage: e-HealthRecordsRetriever -h [-s DISEASE_ELECTRONIC_HEALTH_RECORDS] [-d PUBLICATION_DATE_RANGE]

Mandatory arguments:
  -s                    the disease-associated electronic health record as query search term
  -d                    publication date range (yyyy-MM-dd) of the electronic health record(s): ex. 2019-05-20--2019-05-25
Optional arguments:
  -f                    user-specified absolute path to save results files
  -k                    option to keep temporary files
  -h                    show help message and exit
```

## Copyright and License

Copyright 2023 by Abbas Alameer, Kuwait University

This program is free software; you can redistribute it and/or modify
it under the terms of the <a href="http://www.gnu.org/licenses/gpl-2.0-standalone.html" target="_blank" rel="noopener noreferrer">GNU General Public License, version 2 (GPLv2).</a>

## Contact
<p>e-HealthRecordsRetriever was developed by:<br>
<a href="http://kuweb.ku.edu.kw/biosc/People/AcademicStaff/Dr.AbbasAlameer/index.htm" target="_blank" rel="noopener noreferrer">Abbas Alameer</a> (Bioinformatics and Molecular Modelling Group, Kuwait University), in collaboration with <a href="http://www.DavideChicco.it" target="_blank" rel="noopener noreferrer">Davide Chicco</a> (Università di Milano-Bicocca)</br>

For information, please contact Abbas Alameer at abbas.alameer(AT)ku.edu.kw</p>

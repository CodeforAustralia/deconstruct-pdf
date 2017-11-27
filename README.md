The **deconstruct-pdf** series of bash shell scripts allows the users to "deconstruct" **pdf** files to **text** and **html** file formats, using poppler-utils. It then allows some text processing to take place and organises the files in a directory structure that makes it eas(y/ier) to serve up from a web server, for example.  


## Pre-requistes
1\. You must have poppler-utils installed. See the Poppler website, [poppler.freedesktop.org](https://poppler.freedesktop.org), for the latest distribution.


If your Linux distribution uses APT you may want to:-

```
sudo apt-get update
sudo apt-get install poppler-utils
```

See a [quick guide](https://www.howtogeek.com/228531/how-to-convert-a-pdf-file-to-editable-text-using-the-command-line-in-linux/).

2\. You will also need to set up a MySQL database and configure so there is a default login at command line.


## Setup
Just download the files and use them from command line (on a Linux system where bash is available.) Start with getting some help:-

```
$sh pdf2text.sh --help
Usage:
  [-d document_directory] [-b base_directory] [-t target_database] [-h] [--help] [-v]

Help Options:
  -h, --help     Show help
  -v             Show version

Options:
  -b             Base directory where "deconstructed" files will be located (in subdirectories)
  -d             Document directory where PDF files are located
  -t             Target database
```  

Then you might want to do a test run with the sample documents provided.

```
$ sh pdf2text.sh -d sample_documents/ -b ./output -t some_database
-----------------------------------------------------
PDF to TEXT and HTML Conversion
Date: Monday 27 November  15:05:09 AEDT 2017
Host: some_hostname
-----------------------------------------------------
Processing files...
sample-001.pdf
Page-1
Target DB = some_database
Letter Date = 2017-08-08
Service ID = 2357111317
Template = TMP-MG-01
UUID = 7b3633e1aa874987dcc3a8e75a1b8ef5
Number of Pages = 1
sample-002.pdf
Page-1
Target DB = some_database
Letter Date = 2015-06-09
Service ID = 1923293137
Template = TMP-MG-02
UUID = 609638bd22cdf23eaf33743d5a1b8ef5
Number of Pages = 1
sample-003.pdf
Page-1
Target DB = some_database
Letter Date = 2016-06-21
Service ID = 1923293137
Template = TMP-MG-03
UUID = 98b4ad4150c945934231b4f15a1b8ef5
Number of Pages = 1
Done!!!
$ tree output/
'output/
├── html
│   ├── 1923293137
│   │   ├── 609638bd22cdf23eaf33743d5a1b8ef5.html
│   │   └── 98b4ad4150c945934231b4f15a1b8ef5.html
│   └── 2357111317
│       └── 7b3633e1aa874987dcc3a8e75a1b8ef5.html
├── pdf
│   ├── 1923293137
│   │   ├── 609638bd22cdf23eaf33743d5a1b8ef5.pdf
│   │   └── 98b4ad4150c945934231b4f15a1b8ef5.pdf
│   └── 2357111317
│       └── 7b3633e1aa874987dcc3a8e75a1b8ef5.pdf
└── text
    ├── 1923293137
    │   ├── 609638bd22cdf23eaf33743d5a1b8ef5.txt
    │   └── 98b4ad4150c945934231b4f15a1b8ef5.txt
    └── 2357111317
        └── 7b3633e1aa874987dcc3a8e75a1b8ef5.txt

9 directories, 9 files
```

Note that the UUIDs will be generated at random and the file names will, therefore, be unique.

## Usage
A per help instructions, the idea is to give a document directory as an input parameter, this is the directory where the **pdf** files are located. It might, for example be the directory of some user who ftp'ed (or stfp'ed) some documents over to your box.

e.g. _/home/someUser/ftp/incoming/_

You will also want to specify where you want the new files to be written to. You may want to write them to a web server location like

e.g. _/var/www/vhs/correspondence_

You also need to specify a target database in which you want certain tables to be updated. If your MySQL database, for example, is named "vhsdb" you will want to issues a command such as:-


```
$ sh pdf2text.sh -d "/home/someUser/ftp/incoming" -b "/var/www/vhs/correspondence" -t vhsdb >> some.log
```  

N.B. You will certainly want to watch your permissions and ownership as the web server process has to be able to at least read the files you have produced. For the database too, you will have to make sure you have set up authentication correctly and that when the command *mysql* is called in [populate-db.sh](https://github.com/CodeforAustralia/deconstruct-pdf/blob/master/populate-db.sh) (line 24) you have sufficient privilege to update the database tables. (See this blog for [configuring MySQL](https://github.com/CodeforAustralia/vhs/wiki/Configuring-MySQL).)

## About
These series of scripts converts **pdf** files to **text** and **html** files and carries out some text processing on the text files. The text files are then searched for certain information, specifically a _Reference Number_, _Template Number_ (from which the letter was generated) and the stated _Letter Date_. The script also uses a utility to calculate the number of pages the document has. The files are then ordered in an output directory structure that corresponds to the type of file and the reference number. So, for instance, the sample letters that are provided in this distribution are organised according to the _Reference Number_ given in the letter. Thus _sample-001.pdf_ is   

## Tested

Tested on Ubuntu 16.04

The **deconstruct-pdf** series of bash shell scripts allows the users to "deconstruct" **pdf** files to **text** and **html** file formats, using poppler-utils. It then allows some text processing to take place and organises the files in a directory structure that makes it eas(y/ier) to serve up from a web server, for example.  


## Pre-requistes
1\. You must have poppler-utils installed. See the Poppler website, [poppler.freedesktop.org](https://poppler.freedesktop.org), for the latest distribution.


If your Linux distribution uses APT you may want to:-

```
sudo apt-get update
sudo apt-get install poppler-utils
```

See a [quick guide](https://www.howtogeek.com/228531/how-to-convert-a-pdf-file-to-editable-text-using-the-command-line-in-linux/).

2\. You will also need to set up a MySQL database and configure it so there is a default login at command line.

To create the database and the relevant tables you may want to do something like this:-
```
CREATE DATABASE `some_database` CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `some_database`;

CREATE TABLE `letters` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `template_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `letter_date` date NOT NULL,
  `pages` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
);


CREATE TABLE `letter_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `letter_uuid` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `unread` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
);


CREATE TABLE `user_services` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reference_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL
);
```

You will also have to make sure you have set up authentication correctly for the MySQL database so that when the command *mysql* is called in [populate-db.sh](https://github.com/CodeforAustralia/deconstruct-pdf/blob/master/populate-db.sh) (line 24) that there is a default login and that that database user has sufficient privilege to update the database tables. See this blog for [configuring MySQL](https://github.com/CodeforAustralia/vhs/wiki/Configuring-MySQL).)


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

## About
These series of scripts converts **pdf** files to **text** and **html** files and carries out some text processing on the text files. The text files are then searched for certain information, specifically a _Reference Number_, _Template Number_ (from which the letter was generated) and the stated _Letter Date_. The script also uses a utility to calculate the number of pages the document has. The files are then ordered in an output directory structure that corresponds to the type of file and the reference number. So, for instance, the sample letters that are provided in this distribution are organised according to the _Reference Number_ given in the letter.

Thus _sample-001.pdf_, which contains the text "Ref No. 2357111317", results in its getting filed under a subdirectory structure _<output_directory>/pdf/2357111317/&lt;UUID&gt;.pdf_ (where the UUID is some randomly-generated unique number.) Additionally, 2 other files are generated:- _<output_directory>/text/2357111317/&lt;UUID&gt;.txt_ which is the letter in plain text format and _<output_directory>/html/2357111317/&lt;UUID&gt;.html_ which is the html rendering of the letter.

Furthermore, the database is updated with the required information so that server-side scripting (whatever you are using) can make use of this information. The [vhs repository](https://github.com/CodeforAustralia/vhs), for instance, makes use of these database tables to generate a secure copy of the **pdf** file (as in, for example, this [Laravel Controller](https://github.com/CodeforAustralia/vhs/blob/master/app/Http/Controllers/ActualLetterController.php))

## Usage
A per help instructions, the idea is to give a document directory as an input parameter, this is the directory where the **pdf** files are located. It might, for example be the directory of some user who ftp'ed (or stfp'ed) some documents over to your box.

e.g. _/home/someUser/ftp/incoming/_

You will also want to specify where you want the new files to be written to. You may want to write them to a web server location like

e.g. _/var/www/vhs/correspondence_

You also need to specify a target database in which you want certain tables to be updated. If your MySQL database, for example, is named "vhsdb" you will want to issues a command such as:-


```
$ sh pdf2text.sh -d "/home/someUser/ftp/incoming" -b "/var/www/vhs/correspondence" -t vhsdb >> some.log
```  

N.B. You will certainly want to watch your permissions and ownership as the web server process has to be able to at least read the files you have produced.

## Tested

Tested on Ubuntu 16.04

The **deconstruct-pdf** series of bash shell scripts allows the users to "deconstruct" **pdf** files to **text** and **html** file formats, using poppler-utils. It then allows some text processing to take place and organises the files in a directory structure that makes it eas(ier) to serve up from a web server, for example.  


## Pre-requistes
You must have poppler-utils installed. See the Poppler website, [poppler.freedesktop.org](https://poppler.freedesktop.org), for the latest distribution.


If your Linux distribution uses APT you may want to:-

```
sudo apt-get update
sudo apt-get install poppler-utils
```

See a [quick guide](https://www.howtogeek.com/228531/how-to-convert-a-pdf-file-to-editable-text-using-the-command-line-in-linux/).

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

## Usage
A per help instructions, the idea is to give a document directory as an input parameter, this is the directory where the **pdf** files are located. It might, for example be the directory of some user who ftp'ed (or stfp'ed) some documents over to your box.

e.g. _/home/someUser/ftp/incoming/_

You will also want to specify where you want the new files to be written to. You may want to write them to a web server location like

e.g. _/var/www/vhs/correspondence_

You also need to specify a target database in which you want certain tables to be updated. If your MySQL database, for example, is named "vhsdb" you will want to issues a command such as:-


```
$ sh pdf2text.sh -d "/home/someUser/ftp/incoming" -b "/var/www/vhs/correspondence" -t vhsdb >> some.log

```  

N.B. You will certainly want to watch your permissions and ownership as the server process has to be able to at least read the files you have produced. For the database too, you will have to make sure you have set up authentication correctly and that when the command *mysql* is called in [populate-db.sh](https://github.com/CodeforAustralia/deconstruct-pdf/blob/master/populate-db.sh) (line 24) you have sufficient privilege to update the database tables. (See this blog for [configuring MySQL](https://github.com/CodeforAustralia/vhs/wiki/Configuring-MySQL).)

## About
These series of scripts converts **pdf** files to **text** and **html** files and carries out some text processing on the text files.

## Tested

Tested on Ubuntu 16.04

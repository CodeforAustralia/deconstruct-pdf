The deconstruct-pdf series of shell scripts allows the users to "deconstruct" **pdf** files to **text** and **html** file formats. It does so using poppler-utils.


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
sh pdf2text.sh --help
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

## About
These series of scripts converts **pdf** files to **text** and **html** files and carries out some text processing on the text files.

## Tested

Tested on Ubuntu 16.04

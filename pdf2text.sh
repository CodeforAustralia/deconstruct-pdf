#!/bin/bash

VERSION=0.0.1
#Initialize
DEBUG=1

usage() {
    echo "Usage:"
    echo "  [-d document_directory] [-b base_directory] [-t target_database] [-h] [--help] [-v]"
    echo ""
    echo "Help Options:"
    echo "  -h, --help     Show help"    
    echo "  -v             Show version" 
    echo ""
    echo "Options:"
    echo "  -b             Base directory where \"deconstructed\" files will be located (in subdirectories)"
    echo "  -d             Document directory where PDF files are located"
    echo "  -t             Target database"
    exit 0
}

version() {
    echo "Version: $VERSION"
    exit 0
}

#If no arguments passed then show help and exit
if [ $# -eq 0 ];
then
    usage;
fi

#Assess first argument 
case $1 in
     -h) usage;
	;; 
 --help) usage;
	;;
     -v) version;
        ;;
esac

# Get arguments
while getopts b:d:t: option
do
 case "${option}"
 in
      b) BASE_DIR=${OPTARG};;
      d) DOCUMENTS_DIR=${OPTARG};;
      t) TARGET_DB=${OPTARG};;
 esac
done

if [ -z "$BASE_DIR" ] 
	then
		 echo "Base directory is not specified"
    		 usage;
fi

if [ -z "$DOCUMENTS_DIR" ] 
	then
		 echo "Document directory is not specified"
    		 usage;
fi

if [ -z "$TARGET_DB" ] 
	then
		 echo "Target database is not specified"
    		 usage;
fi

# Make sure that DOCUMENTS_DIR directory end in '/'
DOCUMENTS_DIR=$(echo $DOCUMENTS_DIR | sed "s,/$,,")
DOCUMENTS_DIR="$DOCUMENTS_DIR/"

# Make sure BASE_DIR does not have a trailing '/'
BASE_DIR=$(echo $BASE_DIR | sed "s,/$,,")

PDF_DIR="$BASE_DIR/pdf/"
TEXT_DIR="$BASE_DIR/text/"
HTML_DIR="$BASE_DIR/html/"

mkdir -p $PDF_DIR
mkdir -p $TEXT_DIR
mkdir -p $HTML_DIR
#
# where to put files that are undefined (i.e. reference
# number and template cannot be found)
UNDEFINED_PDF_DIRECTORY=$PDF_DIR"undefined"
UNDEFINED_TEXT_DIRECTORY=$TEXT_DIR"undefined"
UNDEFINED_HTML_DIRECTORY=$HTML_DIR"undefined"
#
TODAY=$(date)
HOST=$(hostname)
echo "-----------------------------------------------------"
echo "PDF to TEXT and HTML Conversion"
echo "Date: $TODAY"                     
echo "Host: $HOST"
echo "-----------------------------------------------------"

if [ "$DEBUG" -ne "0" ]
	then
		echo "DOCUMENTS_DIR = $DOCUMENTS_DIR"
                echo ""
		echo "BASE_DIR = $BASE_DIR"
		echo "The PDF  Directory is: $PDF_DIR"
		echo "The TEXT Directory is: $TEXT_DIR"
		echo "The HTML Directory is: $HTML_DIR"
                echo ""
fi



if [ $(find "$DOCUMENTS_DIR" -maxdepth 0 -type d -empty 2>/dev/null) ]; 
	then
    		echo "Document directory empty, nothing to process"
		exit 0
fi

echo "Processing files..."

for file in $DOCUMENTS_DIR*
do
  if [ ! -d "$file" ]; then

  	FILE=${file##*/}
  	TEXT_FILE="$TEXT_DIR$FILE"
  	TEXT_FILE="${TEXT_FILE%.*}.txt"
  	HTML_FILE="$HTML_DIR$FILE"
  	HTML_FILE="${HTML_FILE%.*}.html"
  	echo "$FILE"
# Extract to text and html files
  	pdftotext $file $TEXT_FILE
#  	pdftohtml -p -i -c -noframes -nomerge $file $HTML_FILE
  	pdftohtml -p -i -c -noframes $file $HTML_FILE


# Tidy up the HTML file:-

# mitigate MS Word artefact - replace Unicode U+F0B7 with bullet 
  	sed -i 's//\&bull;/g' $HTML_FILE
# bgcolor hardcoded into poppler-utils pdftohtml - change it to white 
  	sed -i 's/body bgcolor=\"\#A0A0A0\"/body style=\"background-color: \#ffffff\;\"/g' $HTML_FILE
# non-breaking space (&#160;) shold be just a space
        sed -i 's/\&\#160;/ /g' $HTML_FILE
# take styling off the paragraphs
        sed -i 's/\<p style\=\".*\"/p/g' $HTML_FILE
# take additional styling off the pages
        sed -i 's/\-div\".style\=\".*\"/\-div\" style\=\"border-bottom\:1px solid \#ccc\;\"/g' $HTML_FILE
#
        sed -i 's/margin\: 0/margin-top\: 20px/g' $HTML_FILE
 

# get the Reference Number, Template Number and Letter Date
	unset REF_NO
	unset TEMPLATE_NO
        unset DAY
        unset MONTH
        unset YEAR
        unset LETTER_DATE
	unset NO_OF_PAGES

	# get the reference number  	
	REF_NO=$(fgrep "Ref No. " $TEXT_FILE | sed 's/Ref No. //g' | sed 's/ //g')
	if [ -z "$REF_NO" ] 
	then
			REF_NO=$(fgrep "Reference Number: " $TEXT_FILE | sed 's/Reference Number: //g' | sed 's/ //g')
	fi


	# get the template number
  	TEMPLATE_NO=$(fgrep "TMP-" $TEXT_FILE | sed 's/ //g')
	if [ -z "$TEMPLATE_NO" ] 
	then
			TEMPLATE_NO=$(fgrep "BO_Seq" $TEXT_FILE | sed 's/ //g')
	fi

 	NO_OF_PAGES=$(pdfinfo $file | grep Pages | sed 's/[^0-9]*//')


	if [ -z "$REF_NO" ] 
	then
    		mkdir -p $UNDEFINED_PDF_DIRECTORY
    		mkdir -p $UNDEFINED_TEXT_DIRECTORY
    		mkdir -p $UNDEFINED_HTML_DIRECTORY
    		mv $file "$UNDEFINED_PDF_DIRECTORY"
    		mv $TEXT_FILE "$UNDEFINED_TEXT_DIRECTORY"
    		mv $HTML_FILE "$UNDEFINED_HTML_DIRECTORY"
	else
    		UUID=$(dbus-uuidgen);

        	LETTER_DATE=$(grep -n "Ref No. " $TEXT_FILE| cut -d : -f 1)
        	LETTER_DATE=$(head -n$LETTER_DATE $TEXT_FILE | tail -2 | head -n1)
		COUNTER=0
		for word in $LETTER_DATE
		do
             		case "$COUNTER" in
	        		0)DAY=$word ;;
         			1)MONTH=$word ;;
	        		2)YEAR=$word;;
	     		esac
             		COUNTER=$((COUNTER+1))
		done

        	case "$MONTH" in
        		January)   MONTH_NO=01 ;;
        		February)  MONTH_NO=02 ;;
        		March)     MONTH_NO=03 ;;
        		April)     MONTH_NO=04 ;;
        		May)       MONTH_NO=05 ;;
        		June)      MONTH_NO=06 ;;
        		July)      MONTH_NO=07 ;;
        		August)    MONTH_NO=08 ;;
        		September) MONTH_NO=09 ;;
        		October)   MONTH_NO=10 ;;
        		November)  MONTH_NO=11 ;;
        		December)  MONTH_NO=12 ;;
		esac
        
        	LETTER_DATE="$YEAR-$MONTH_NO-$DAY"

		if [ "$DEBUG" -ne "0" ]
			then

				echo "Service ID =  $REF_NO"
    				echo "Template =    $TEMPLATE_NO"
 	        		echo "Letter Date = $LETTER_DATE"
	        		echo "Number of Pages = $NO_OF_PAGES"
				echo "-----------------------------------------------------"
		fi

    		REF_PDF_DIRECTORY=$PDF_DIR$REF_NO
    		REF_TEXT_DIRECTORY=$TEXT_DIR$REF_NO
    		REF_HTML_DIRECTORY=$HTML_DIR$REF_NO
    		REF_PDF_FILE="$UUID.pdf"
    		REF_TEXT_FILE="$UUID.txt"
    		REF_HTML_FILE="$UUID.html"
    		mkdir -p $REF_PDF_DIRECTORY
    		mkdir -p $REF_TEXT_DIRECTORY
    		mkdir -p $REF_HTML_DIRECTORY
    		mv $file "$REF_PDF_DIRECTORY/$REF_PDF_FILE"
    		mv $TEXT_FILE "$REF_TEXT_DIRECTORY/$REF_TEXT_FILE"
    		mv $HTML_FILE "$REF_HTML_DIRECTORY/$REF_HTML_FILE"

                sh ./populate-db.sh -d $TARGET_DB -l $LETTER_DATE -r $REF_NO -t $TEMPLATE_NO -u $UUID -p $NO_OF_PAGES
	fi
  fi
done

echo "Done!!!"

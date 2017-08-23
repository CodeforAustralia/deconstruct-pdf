#!/bin/bash
while getopts b:d: option
do
 case "${option}"
 in
 b) BASE_DIR=${OPTARG};;
 d) DOCUMENTS_DIR=${OPTARG};;
 esac
done

if [ -z "$BASE_DIR" ] 
	then
    		echo "usage: pdf2text [-b <base_directory> -d <document_directory>] [--help]"
fi

echo "BASE_DIR = $BASE_DIR"
echo "DOCUMENTS_DIR = $DOCUMENTS_DIR"

#DOCUMENTS_DIR="/home/user01/Projects/CfA/pdf-to-text/documents/"  
#BASE_DIR="/opt/lampp/htdocs/work/documents"  
PDF_DIR="$BASE_DIR/pdf/"
TEXT_DIR="$BASE_DIR/text/"
HTML_DIR="$BASE_DIR/html/"

mkdir -p $PDF_DIR
mkdir -p $TEXT_DIR
mkdir -p $HTML_DIR
#
# where to put files that are undefined in terms of reference
# number and template
UNDEFINED_PDF_DIRECTORY=$PDF_DIR"undefined"
UNDEFINED_TEXT_DIRECTORY=$TEXT_DIR"undefined"
UNDEFINED_HTML_DIRECTORY=$HTML_DIR"undefined"
#
TODAY=$(date)
HOST=$(hostname)
echo "-----------------------------------------------------"
echo "PDF to TEXT and HTML Conversion"
echo "Date: $TODAY"                     
echo "Host:$HOST"
echo "-----------------------------------------------------"
echo "The PDF  Directory is: $PDF_DIR"
echo "The TEXT Directory is: $TEXT_DIR"
echo "The HTML Directory is: $HTML_DIR"
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
#  	pdftohtml -p -i -noframes -nomerge $file $HTML_FILE
  	pdftohtml -p -i -noframes -nomerge $file $HTML_FILE

# mitigate MS Word artefact - replace Unicode U+F0B7 with bullet 
  	sed -i 's//\&bull;/g' $HTML_FILE
# bgcolor hardcoded into poppler-utils pdftohtml - change it to white 
  	sed -i 's/body bgcolor=\"\#A0A0A0\"/body bgcolor=\"\#fff"/g' $HTML_FILE

# get the Reference Number, Tempalte Number and Letter Date
	unset REF_NO
	unset TEMPLATE_NO
        unset DAY
        unset MONTH
        unset YEAR
        unset LETTER_DATE

  	REF_NO=$(fgrep "Ref No. " $TEXT_FILE | sed 's/Ref No. //g' | sed 's/ //g')
	# get the template number
  	TEMPLATE_NO=$(fgrep "TMP-" $TEXT_FILE | sed 's/ //g')

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


    		echo "Service ID = $REF_NO"
    		echo "Template = $TEMPLATE_NO"
 	        echo "Letter Date = $LETTER_DATE"
 

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

                sh ./populate-db.sh -d $LETTER_DATE -r $REF_NO -t $TEMPLATE_NO -u $UUID
	fi
  fi
done

echo "Done!!!"

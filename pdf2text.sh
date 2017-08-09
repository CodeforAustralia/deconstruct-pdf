#!/bin/bash  
PDF_DIR="./pdf/"
TEXT_DIR="./text/"
HTML_DIR="./html/"
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
for file in $PDF_DIR*; do
  FILE=${file##*/}
  TEXT_FILE="$TEXT_DIR$FILE"
  TEXT_FILE="${TEXT_FILE%.*}.txt"
  HTML_FILE="$HTML_DIR$FILE"
  HTML_FILE="${HTML_FILE%.*}.html"
  echo "$FILE"
  pdftotext $file $TEXT_FILE
  pdftohtml -p -i -noframes $file $HTML_FILE
done
# Mitigate MS Word artefact - replace Unicode U+F0B7 with bullet 
sed -i 's//\&bull;/g' $HTML_FILE
# bgcolor hardcoded into poppler-utils pdftohtml - change it to white 
sed -i 's/body bgcolor=\"\#A0A0A0\"/body bgcolor=\"\#fff"/g' $HTML_FILE
echo "Done!!!"

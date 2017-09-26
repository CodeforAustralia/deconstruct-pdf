#!/bin/bash

while getopts d:l:r:t:u: option
do
 case "${option}"
 in
 d) TARGET_DB=${OPTARG};;
 l) LETTER_DATE=${OPTARG};;
 r) REF_NO=${OPTARG};;
 t) TEMPLATE_NO=${OPTARG};;
 u) UUID=$OPTARG;;
 esac
done


echo "Target DB = $TARGET_DB"
#echo "Letter Date = $LETTER_DATE"
#echo "Service ID = $REF_NO"
#echo "Template = $TEMPLATE_NO"
#echo "UUID = $UUID"
 
mysql -uroot $TARGET_DB <<EOF
INSERT INTO letters (uuid, reference_id, template_id, letter_date, created_at, updated_at) VALUES 
('$UUID', '$REF_NO', '$TEMPLATE_NO', '$LETTER_DATE', now(), now());
commit;
EOF

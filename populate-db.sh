#!/bin/bash

while getopts d:l:p:r:t:u: option
do
 case "${option}"
 in
 d) TARGET_DB=${OPTARG};;
 l) LETTER_DATE=${OPTARG};;
 p) NO_OF_PAGES=${OPTARG};;
 r) REF_NO=${OPTARG};;
 t) TEMPLATE_NO=${OPTARG};;
 u) UUID=$OPTARG;;
 esac
done


echo "Target DB = $TARGET_DB"
echo "Letter Date = $LETTER_DATE"
echo "Service ID = $REF_NO"
echo "Template = $TEMPLATE_NO"
echo "UUID = $UUID"
echo "NO_OF_PAGES = $NO_OF_PAGES" 

mysql -uroot $TARGET_DB <<EOF
SET autocommit=0;
START TRANSACTION;
INSERT INTO letters (uuid, reference_id, template_id, filename, letter_date, pages, created_at, updated_at) VALUES 
('$UUID', '$REF_NO', '$TEMPLATE_NO', '$UUID.html', '$LETTER_DATE', $NO_OF_PAGES, now(), now());

INSERT INTO letter_history (reference_id, user_id, letter_uuid, created_at, updated_at) 
(select user_services.reference_id, user_services.user_id, '$UUID' as letter_uuid, now(), now() from user_services where reference_id='$REF_NO');
COMMIT;
SET autocommit=1;
EOF

if pgrep -f "pdf2text" > /dev/null
then
    echo "pdf2text running"
else
    echo "pdf2text stopped"
fi

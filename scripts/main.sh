#!/bin/bash
# Louis Shropshire + Marcus Recck
# main.sh - Runs a vulnerability scan of a given URL

# Check if number of parameters is correct
if [ $# -ne 1 ]
then
	>&2 echo "Usage: main.sh url"
	exit;
fi

# Cleanup Function
# Removes all temporary files created by the script
function cleanup {
	rm *.tmp
}

# Traps SIGINT, SIGQUIT, and SIGTERM
trap cleanup INT QUIT TERM

# Gets the original webpage
wget $1 --output-document=input.tmp --quiet

# Parses the html data from the webpage and extracts all the data associated
# with the forms on the page
#
# data is returned in the following form
# ACTION
# METHOD
# INPUTNAME1^~^INPUTNAME2^~^INPUTNAME3
FORMDATA=`awk -f find_form.awk input.tmp`

# Check if there are no forms on the page
if [ -z "$FORMDATA" ]
then
	>&2 echo "Page does not contain any forms"
	exit;
fi

# Create variables used for SQLI and XSSI
RANDOM_VAL=$RANDOM
CONTROL_VALUE="Hello $RANDOM_VAL"
SQL_VALUE="' OR 1=1 OR ''='"
XSS_VALUE="<u><b>INJECTION TIME BABY!!! $RANDOM_VAL</b></u>"

TOTAL_SQLI_SEVERE=0
TOTAL_SQLI_MODERATE=0
TOTAL_SQLI_LOW=0
TOTAL_SQLI_NO=0
TOTAL_XSSI_TRUE=0
TOTAL_XSSI_FALSE=0



LINENUM=0
# Loop through all of the forms
while read line 
do
	n=$((LINENUM % 3))
	# Parse the form's ACTION
	if [ $n -eq 0 ] 
	then
		ACTION=$line
		#default is returned by the awk script if the ACTION matches the original URL
		if [ $ACTION == "default" -o ${ACTION:0:1} == "#" ]
		then
			ACTION=$1
		elif [ ${ACTION:0:1} == "/" ]
		then
			ACTION=$1$ACTION
		fi
	fi

	# Parse the form's METHOD
	if [ $n -eq 1 ] 
	then
		METHOD=$line
	fi

	# Parse the form's Input Fields and perform the tests
	if [ $n -eq 2 ] 
	then
		fields=(${line//\^~\^/ })

		CONTROL_DATA=""
		SQLI_DATA=""
		XSSI_DATA=""

		# Loop through all of the fields and build out the POST/GET strings for each test
		for field in "${fields[@]}"
		do
			CONTROL_DATA="$CONTROL_DATA$field=$CONTROL_VALUE&"
			SQLI_DATA="$SQLI_DATA$field=$SQL_VALUE&"
			XSSI_DATA="$XSSI_DATA$field=$XSS_VALUE&"
		done


		# Perform the SQLI and XSSI tests by wget calling the form's ACTION URL with 
		# associated POST/GET data; depending on the form's METHOD
		if [ $METHOD == "post" ] 
		then
			wget $ACTION --post-data="$CONTROL_DATA" --output-document=control.tmp --quiet
			wget $ACTION --post-data="$SQLI_DATA" --output-document=sqli.tmp --quiet
			wget $ACTION --post-data="$XSSI_DATA" --output-document=xssi.tmp --quiet
		else 
			wget "$ACTION?$CONTROL_DATA" --output-document=control.tmp --quiet
			wget "$ACTION?$SQLI_DATA" --output-document=sqli.tmp --quiet
			wget "$ACTION?$XSSI_DATA" --output-document=xssi.tmp --quiet
		fi

		# Compute the difference between the control's lines and sqli test's lines
		SQL_DIFF_LINES=`diff -U 0 control.tmp sqli.tmp | grep -v ^@ | wc -l`

		# Compute the percentage of DIFF LINES to CONTROL LINES.
		# This metric takes subtle changes that could be present between pages into account
		CONTROL_LINES=`cat control.tmp | wc -l`
		SQLI_LINES=`cat sqli.tmp | wc -l`
		DIFF_PCT=`echo "scale = 2; $SQL_DIFF_LINES / ($CONTROL_LINES + 1) * 100" | bc`
		DIFF_PCT=`echo $DIFF_PCT | awk 'BEGIN {FS=".";}{print $1;}'`

		# Set the SQLI RISK depending on different threshold buckets
		if [ $DIFF_PCT -ge 45 ]
		then
			SQL_VULN="SEVERE RISK"
			((TOTAL_SQLI_SEVERE++))

		elif [ $DIFF_PCT -ge 20 ]
		then
			SQL_VULN="MODERATE RISK"
			((TOTAL_SQLI_MODERATE++))
		elif [ $DIFF_PCT -gt 5 ]
		then
			SQL_VULN="LOW RISK"
			((TOTAL_SQLI_LOW++))
		else
			SQL_VULN="NO RISK"
			((TOTAL_SQLI_NO++))
		fi

		# Determine whether the XSSI Test was succesful by looking for the 
		# XSS Injected values in the page's html
		XSS_FOUND=`grep "$XSS_VALUE" xssi.tmp | wc -l`
		if [ $XSS_FOUND -gt 0 ]
		then
			XSS_VULN="TRUE"
			((TOTAL_XSSI_TRUE++))

		else
			XSS_VULN="FALSE"
			((TOTAL_XSSI_FALSE++))
		fi


		# Add nice spaces
		if [ $LINENUM -gt 3 ] 
		then
			echo ""
			echo ""
		else
			echo ""
		fi

		# Echo out the test deatils for the current form
		let FORM_NUM="( $LINENUM + 1 ) / 3"
		echo "FORM #$FORM_NUM"
		echo "ACTION: $ACTION"
		echo "METHOD: $METHOD"
		echo "SQL INJECTION VULNERABLE: $SQL_VULN"
		echo "XSS INJECTION VULNERABLE: $XSS_VULN"
	fi

	((LINENUM++)) 

done <<< "$FORMDATA"
echo ""
echo "==========================================="
echo "================  SUMMARY  ================"
echo "==========================================="
echo ""
echo "Total number of forms: $FORM_NUM"
echo "SQL INJECTION RISK"

PRINTF_STYLE="%40s\t%-2d\n"

printf $PRINTF_STYLE "Total number of SEVERE RISK forms:" $TOTAL_SQLI_SEVERE
printf $PRINTF_STYLE "Total number of MODERATE RISK forms:" $TOTAL_SQLI_MODERATE
printf $PRINTF_STYLE "Total number of LOW RISK forms:" $TOTAL_SQLI_LOW
printf $PRINTF_STYLE "Total number of NO RISK forms:" $TOTAL_SQLI_NO
echo ""
echo "XSS INJECTION RISK"
printf $PRINTF_STYLE "Total number of XSS vulnerable forms:" $TOTAL_XSSI_TRUE
printf $PRINTF_STYLE "Total number of XSS invulnerable forms:" $TOTAL_XSSI_FALSE


# Call the cleanup function
cleanup
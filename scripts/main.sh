#!/bin/bash
# Louis Shropshire
# main.sh - Runs the Vulnerability scan

if [ $# -ne 1 ]
then
	>&2 echo "Invalid number of arguments"
	exit;
fi

#Check if its a valid email




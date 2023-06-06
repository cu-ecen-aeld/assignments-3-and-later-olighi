#! /usr/bin/bash
if [ $# -lt 2 ]
then
	echo "not enough arguments"
	exit 1
fi
if [ ! -d $1 ]
then
	echo "$1 is not a directory"
	exit 1
fi
FILE_COUNT=$(find $1 -type f | wc -l)
FIND_FILE_COUNT=$(grep -r $2 $1 | wc -l)
echo "The number of files are $FILE_COUNT and the number of matching lines are $FIND_FILE_COUNT"


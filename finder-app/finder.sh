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



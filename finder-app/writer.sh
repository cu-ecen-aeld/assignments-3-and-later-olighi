#! /usr/bin/bash
if [ $# -lt 2 ]
then
	echo "Not enough argument"
	exit 1
fi
DIR=$(dirname "$1")
echo "dirname is $DIR"
if [ ! -d "$DIR" ]
then
	echo "Create $DIR dir"
	mkdir -p "$DIR"
fi
echo "$2" > "$1"
if [ ! -f "$1" ]
then
	echo "Couldn't create file"
	exit 1
fi


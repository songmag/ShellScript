#!/bin/bash
if [ ! -z $1 ];then
SSH_FILE=$1
FILE=$2

if [ ! -f $SSH_FILE ];then
echo " $1 is not FILE "
exit 1
fi

SSH_URL=$(cat $SSH_FILE | grep ssh | awk '\
{ for(i=2;i<=NF;i++){\
       if( $i == "-p" )\
{ printf "-P ";}\
else{ \
 printf "%s ", $i ;\
 } }}')

echo SSH_URL=$SSH_URL
fi
if [ -z "$SSH_URL" ]
then
echo "SSH URL is NOT Exists"
exit 0
fi

if [ $# -le 2 ]
then 
echo "NO FILE" 
exit 0
fi

for i in $@
do
if [ $i = "$1" ]
then
echo "SH-FILE=$i"
elif [ $i = "$2" ]
then
echo "FOLDER=$i"
else
	if [ -f $i ]
	then 
	echo $i
sftp $SSH_URL << END_SCRIPT
	cd $2
	put "$i"
	bye
END_SCRIPT
	else
	echo "$i is not exist"
	fi
fi
done

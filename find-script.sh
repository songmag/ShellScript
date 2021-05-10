#!/bin/bash
if [ -z $1 ] || [ -z $2 ]
then 
echo "MUST ARGUMENT FILE and FOLDER"
exit 1
fi

FILE=$1
FOLDER=$2

echo "FILE $1 FIND START IN FOLDER $2"

FindArray=$(find $2 -name "*$1*" | sed -e 's/[[:space:]]/\n/')

#echo "몇번째 파일 ? : "
#while read line || [ ${line} -gt 0 ]; 
#do
#echo "reading: ${line}"
#done < /dev/stdin


for file in $FindArray
do
echo $file
done
echo "몇번째 파일?" 

while read fp < /dev/stdin
do
if [ $fp -gt 0 ]
then
break
fi
done

i=1
for file in $FindArray
do
if [ $i -eq $fp ]
then
vim -o $file
fi
i=$((i+1))
done

echo "만약 파일이 안열렸으면 파일이 존재하지 않습니다."

#!/bin/bash
if [ $# -eq 0 ]
then
        echo value is noting
        exit
fi

PARAMS=("${@:2}")

if [ ${#PARAMS[@]} -eq 0 ]; then
        PARAMS=("/opt")
fi

TEST=$(find $PARAMS -name "${1}" 2>/dev/null)

if [ -z $TEST 2> /dev/null ]
then
        echo 파일이 존재하지 않습니다.
        exit
fi
arr=()
for file in $TEST
do
        arr+=($file)
        echo $file
done

printf "몇개의 파일을 여시겠습니까>> "

read count
echo $count

if [ -z $count ];
then
        echo "파일을 열지 않습니다."
        exit
elif [ $count -eq 0  ]
then
        echo "파일을 열지 않습니다."
        exit
fi

if (( $count > ${#arr[@]} )); then
        echo "열 파일이 숫자가 더 큽니다."
        exit
fi

printf "\n 어떤 파일을 여시겠습니까? >>"
echo ${#arr[@]}
for ((i=0 ; i<${#arr[@]} ;i++))
do
        echo $i = ${arr[$i]}
done
numbers=()
for ((i=0 ; i<$count ; i++ ))
do
        read number
        numbers+=($number)
done
echo ${#numbers[@]}
FILES=()
for ((j=0 ; j<${#numbers[@]} ;j++))
do
        FILES+=(${arr[${numbers[$j]}]})
done

COMMEND=$(command -v vim)
if [ -z $COMMEND ]; then
        vi -O ${FILES[*]}
else
        vim -O ${FILES[*]}
fi

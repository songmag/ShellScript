#!/bin/bash

function validateIP()
{
   local ip=$1
   local FLAG=0        ## 0=TRUE, 1=FALSE
   arrIP=(${ip//./ })  ## DIVIDE INTO ARRAY
   items="${ip//[^.]}" ## COUNT EACH DIGIT
   if [ ${#arrIP[@]} -ne 4 -o ${#items} -ne 3 ];then ## COUNT NUMBERS OF THE ARRAY ITEMS
      FLAG=1           ## FALSE
   else
      for i in "${!arrIP[@]}" ## 0 1 2 3
      do
          if [ ${arrIP[i]} -gt 255 -o ${arrIP[i]} -lt 0 ];then  ## CHECK VALID OR NOT (0..255)
             FLAG=1    ## FALSE
             break
          fi
      done
   fi
   return $FLAG
}

function clearServer(){
        local servers=( `egrep "(^server[\s]*.*$)" /etc/ntp.conf | awk '{print $2}' ` )
        for server in ${servers[@]}
        do
                sudo sed -i "s/\(.*$server.*\)/#\1/g" /etc/ntp.conf
        done
}



echo :"IP를 입력하세요 :: *.*.*.*/*"
read DESC_SERVER
if [[ "$DESC_SERVER" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]];then
    validateIP "$DESC_SERVER"
    FLAG=$(echo $?)
    echo $FLAG
    if [ $FLAG -eq 0 ]; then
        if [ -f /etc/ntp.conf ]; then
                TIME_SERVER=$(egrep "(server\s*$DESC_SERVER)" /etc/ntp.conf)
                if [ -z "$TIME_SERVER" ]
                then
                    clearServer
                    echo "server $DESC_SERVER" >> /etc/ntp.conf
                    systemctl restart ntpd
                    if [ $(echo $?) -ne 0 ]; then
                        echo "ntpd가 없거나 실행되지 않았습니다."
                    fi
                fi
        fi
    fi
else
echo "잘못된 아이피 입력입니다."
exit 0
fi

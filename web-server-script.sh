#!/bin/bash

####### 메소드 정의 ############
 checkRoot(){
	if [ $USER = "root" ]
	then
		echo "ROOT 입니다 "
	else
		echo "$USER 입니다 Root 권한으로 실행해주세요."
		exit 0
	fi
}
changePassword(){
passwd $1 <<END_SCRIPT
$2
$2
END_SCRIPT
}
addUser(){
	UserCheck=$(cat /etc/passwd | grep "$1")
	if [ -z $UserCheck ]
	then
		adduser $1
		echo " 비밀번호를 입력해주세요. " 
		while read pwd < /dev/stdin
		do
			echo $pwd "가 맞으면 y 를 입력해주세요."
			read rs 
			if [ ! -z "$rs" ] || [ "$rs" = 'Y' ] || [ "$rs" = 'y' ]
			then
				changePassword $1 $pwd
				break;
			else
				echo "비밀번호를 입력해주세요."
			fi
		done
	else
		echo "$1 이 이미 존재합니다. 존재하지 않는 아이디로 생성 부탁드립니다. 혹은 계속 진행하려면 y를 입력해주세요. 아니라면 n 을 입력해주세요. "
		while read fp < /dev/stdin
		do
		if [ "$fp" = 'Y' ] || [ "$fp" = 'y' ]
		then 
			break;
		elif [ "$fp" = 'n' ] || [ "$fp" = 'N' ]
		then 
			exit 0
		else
			echo "$1 이 이미 존재합니다. 존재하지 않는 아이디로 생성 부탁드립니다. 혹은 계속 진행하려면 y를 입력해주세요. 아니라면 n 을 입력해주세요. "
		fi
		done
	fi
}
checkYn(){
	if [ "$1" = "Y" ] || [ "$1" = "y" ]
	then
		echo 1
	elif [ "$1" = "N" ] || [ "$1" = "n" ]
	then
		echo 0
	else
		echo -1
	fi		
}
LBDetail(){
#$1 은 파일 경로입니다.
	echo "몇개의 LB 인가요."
	read count
	if [ $count -le 0 ]
	then
		echo "0 개의 LB 로 종료합니다."
		return	
	fi
	for (( i = 1 ; i <= $count ; i++ )){
		writeWorkerProperty $1 $i
	}
}
writeWorkerProperty(){
#$1 은 파일 경로입니다.
	FILE=$1/conf/workers.properties
	sed -i '/worker.list/s/$/,flow'"$2"'/g' $FILE
	sed -i '/.balance_workers=/s/$/,flow'"$2"'/g' $FILE
	echo "## flow$2" >> $FILE
	echo "worker.flow$2.reference=worker.template" >> $FILE
	echo "$2 서버 IP 입력 부탁드립니다."
	read ip
	echo "worker.flow$2.host=$ip" >> $FILE
	echo "worker.flow$2.port=8109">> $FILE
	echo "worker.flow$2.lbfactor=1" >> $FILE

}
LBMaker(){
#$1 은 파일 경로입니다.
	echo "LB 를 진행하는 웹 서버인가요? 맞다면 y, Y 를 입력해주세요 아니라면 N 을 입력해주시면 됩니다. " 
	while read rs < /dev/stdin
	do
		yn=$(checkYn $rs)
		if [ $yn -eq 0 ]
		then
			break;
		elif [ $yn -eq 1 ]
		then
			LBSet $1
			LBDetail $1		
			DocMake $1
			break;
		else
			echo "LB 를 진행하는 웹 서버인가요? 맞다면 y, Y 를 입력해주세요 아니라면 N 을 입력해주시면 됩니다. " 
		fi	
	done
}

DocMake(){
	echo "Document 설정입니다. 있으면 Y 없으면 N 을 입력해주시면 됩니다."
	while read rs < /dev/stdin
	do
		yn=$(checkYn $rs)
		if [ $yn -eq 0 ]
		then
			return;
		elif [ $yn -eq 1 ]
		then
			break;
		else
			echo "Document 설정입니다. 있으면 Y , 없으면 N 을 입력해주시면 됩니다."
		fi	
	done
	FILE=$1/conf/workers.properties
	workerList=$(cat $FILE | grep "worker.list")
	if [ -z "$workerList" ]
	then
		echo "worker.list=document" >> $FILE
	else
		sed -i '/worker.list/s/$/,document/g' $FILE
	fi
	echo "## docViewer" >> $FILE
	echo "worker.document.reference=worker.template" >> $FILE
	echo "$2 서버 IP 입력 부탁드립니다."
	read ip
	echo "worker.document.host=$ip" >> $FILE
	echo "worker.document.port=8109">> $FILE

}

LBSet(){
	if [ ! -d $1/conf ]
	then
		mkdir $1/conf
	fi
	FILE=$1/conf/workers.properties
	if [ -e $FILE ]
	then
		echo "" > $FILE
	fi
	if [ ! -f $FILE ]
	then
		touch $FILE

	fi
	template="worker.template"
	echo "$template.type=ajp13" >> $FILE
	echo "$template.socket_timeout=120">>$FILE
	echo "$template.socket_keepalive=true">>$FILE
	echo "$template.recovery_options=4">>$FILE
	echo "$template.ping_mode=A">>$FILE
	echo "$template.ping_timeout=10000">>$FILE
	echo "$template.connection_pool_size=64">>$FILE
	echo "$template.connection_pool_minsize=25">>$FILE
	echo "$template.connection_pool_timeout=30">>$FILE
	echo "$template.max_packet_size=65536">>$FILE
	echo "$template.retires=1">>$FILE
	LBName="worker.flow"
	echo "$LBName.type=lb" >> $FILE
	echo "$LBName.retries=0" >> $FILE
	echo "$LBName.sticky_session=true" >> $FILE
	echo "$LBName.balance_workers=">>$FILE
	echo "worker.list=flow" >> $FILE
}
installWebServer(){
	#$1 은 zip 경로 $2 는 설치 경로

	echo "compile 을 진행하는 zip 파일인가요? 아니면 설치된 zip 파일인가요? 설치된 Zip 파일이면 Y compile 을 진행해야되면 N 을 입력해주세요."
	
	while read rs < /dev/stdin
	do
		yn=$(checkYn $rs)
		if [ $yn -eq 0 ]
		then
			#N 입력
			return;
		elif [ $yn -eq 1 ]
		then
			#Y 입력
			echo "mv $1/*.zip $2"
			mv $1/*.zip $2
			echo "unzip $2/*.zip -d $2/"
			unzip $2/*.zip -d $2/
			INSTALL_TAR=$(ls $2 | grep apache_ | grep -v apache_conf |grep tar) 
			echo "tar xvf $2/$INSTALL_TAR -C $2/"
			tar xvf $2/$INSTALL_TAR -C $2/
			CONF_TAR=$(ls $2 | grep apache_ | grep apache_conf |grep tar) 
			echo "tar xvf $2/$CONF_TAR -C $2/"
			tar xvf $2/$CONF_TAR -C $2/
			break;
		else
			echo "compile 을 진행하는 zip 파일인가요? 아니면 설치된 zip 파일인가요? 설치된 Zip 파일이면 Y compile 을 진행해야되면 N 을 입력해주세요."
		fi
	done
}

######### 실행 #############
checkRoot
if [ -z "$1" ]
then
	echo "유저를 입력해주세요."
	exit 0
fi
addUser $1

echo "zip file 의 경로를 적어주세요. ex) /home/... or /root/" 

read ZIP_PATH

if [ -z "$ZIP_PATH" ] || [ ! -d "$ZIP_PATH" ] 
then
echo $ZIP_PATH
echo "ZIP 파일 경로가 맞지 않습니다. 종료"
exit 0
fi

echo "WEB 서버를 설치할 경로를 입력해주세요. ex ) /opt/" 
read INSTALL_PATH

if [ -z "$ZIP_PATH" ] || [ ! -d "$ZIP_PATH" ] 
then
echo "INSTALL 경로가 디렉토리가 아닙니다. 종료"
exit 0
fi

installWebServer $ZIP_PATH $INSTALL_PATH

FILE_PATH=$INSTALL_PATH/apache

LBMaker $FILE_PATH

chown -R $1.$1 $FILE_PATH
chown root:$1 $FILE_PATH/bin/httpd
chmod +s $FILE_PATH/bin/httpd


echo "###############COMPLETE###############"


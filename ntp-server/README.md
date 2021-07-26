Network Time Protocol
---------------------

##### 포트 사용 : 123 [ UDP ]
##### Conf File 위치 : /etc/ntp.conf

> 시간을 맞추는 서버를 통칭한다.
> 리눅스 명령어 : ntpdate [ IP or Domain ] 를 통해 즉시 맞춤 처리가 가능하다

# 소프트웨어 리스트

> NTPd : http://www.ntp.org

> OpenNTPd : http://openntpd.com

> Chrony : https://chrony.tuxfamily.org

# NTP 서버 국내, 해외

> 국내

1. time.bora.net LG
2. time.nuri.net 아이네트 호스팅
3. ntp.kornet.net KT
4. time.kriss.re.kr 한국 표준 과학 연구원
5. ntp2.kornet.net KT(2)

> 해외

1. time.nist.gov
2. ms...


# 상태확인

ntpq -np 를 통해 확인 가능

*시간 동기화를 로컬로 하는 경우*

127.127.1.0 [ 내부 동기화 서버 ]

기존 서버 제거 및, IP 추가
--------------------------
쉘 스크립트 참조

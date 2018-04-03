#!/bin/bash

#Check for required utilities
if ! which bc > /dev/null
    then
        echo "bc was not found. Please install bc."
        exit 1
fi

if ! which dig > /dev/null
    then
        echo "dig was not found. Please install dnsutils."
        exit 1
fi


PROVIDERS="
75.75.75.75#comcast1 
75.75.76.76#comcast2 
1.1.1.1#cloudflare1 
1.0.0.1#cloudflare2 
8.8.8.8#google1 
8.8.4.4#google2 
9.9.9.9#quad9 
208.67.222.222#opendns1 
208.67.220.220#opendns2 
64.6.64.6#verisign 
8.26.56.26#comodo 
199.85.126.20#norton 
216.146.35.35#dyn
209.244.0.3#level3 
156.154.70.3#neustar 
185.228.168.168#cleanbrowsing 
77.88.8.7#yandex 
"

# Domains to test. Duplicated domains are ok
DOMAINS2TEST="www.google.com amazon.com facebook.com www.youtube.com www.reddit.com  wikipedia.org twitter.com gmail.com www.google.com whatsapp.com"


totaldomains=0
printf "%-15s" ""
for d in $DOMAINS2TEST; do
    totaldomains=$((totaldomains + 1))
    printf "%-8s" "test$totaldomains"
done
printf "%-8s" "Average"
echo ""


for p in $PROVIDERS; do
    pip=`echo $p| cut -d '#' -f 1`;
    pname=`echo $p| cut -d '#' -f 2`;
    ftime=0

    printf "%-15s" "$pname"
    for d in $DOMAINS2TEST; do
        ttime=`dig @$pip $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
	if [ -z "$ttime" ]; then
	    #let's have time out be 1s = 1000ms
	    ttime=1000
	fi
        printf "%-8s" "$ttime ms"
        ftime=$((ftime + ttime))
    done
    avg=`bc <<< "scale=2; $ftime/$totaldomains"`

    echo "  $avg"
done


exit 0;

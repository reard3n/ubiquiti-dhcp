#!/bin/sh

# figure out which bridge eth0 is attached to
BREZ="br0"
LASTBRIDGE=""
PORTNOEZ=1

# find the bridge that has eth0 in it but not eth0.VLAN
brctl show | grep -v "bridge name" > /tmp/bridges.txt
while read line
do
        HASBRIDGENO=`echo $line | grep -c "br"`
        #echo "This line $line has a bridge number ($HASBRIDGENO)"
        if [ $HASBRIDGENO -eq 1 ]
        then
                LASTBRIDGE=`echo $line | awk '{ORS=""}{print $1}'`
                PORTNOEZ=1
                #echo "Setting lastbridge: $LASTBRIDGE"
        fi

        #echo "Checking. Current last bridge is $LASTBRIDGE.";
        HASETHZERO=`echo $line | grep -v "eth0." | grep -c eth0`
        if [ $HASETHZERO -eq 1 ]
        then
                #echo "Setting bridge that contains EZ: $LASTBRIDGE"
                BREZ=$LASTBRIDGE
                break
        else
                let PORTNOEZ=$PORTNOEZ+1
        fi

done < /tmp/bridges.txt

#echo "The bridge that includes eth0 is $BREZ. The port number for eth0 is $PORTNOEZ."

# dump the macs that are local on this bridge
brctl showmacs $BREZ | grep -v "yes" | awk '{ORS=""}{print $1}{print "|"}{print $2}{print "\n"}' | grep "$PORTNOEZ|" | awk -F"|" '{print $2}'

echo "alldone"

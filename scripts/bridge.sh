#!/bin/bash
 
#Description: Création d'un point d'accès wifi sur une interface wlan et partage la connexion Internet d'une autre interface avec celle-ci.
#Requirements: Necessite les paquets hostapd isc-dhcp-server isc-dhcp-common isc-dhcp-client dnsmasq dnsmasq-base macchanger
#Optionnel: paquet macchanger optionnel
#Auteur: Nexus6[at]altern.org 01.12.2010
 
### WARNING : kill hostapd dnsmasq & dhcpd à la fin...
 
# Configuration des interfaces 
INT_2="eth1" # interface du point d'accès wifi
INT_NET="eth0" # interface wlan ou eth0 ayant Internet
 
# IP & mask du sous-réseau créé sur l'interface wlan
SUBNET="10.0.0.1/24" 
IP="10.0.0.1"
MASK="255.255.255.0"
#GW="192.168.0.1"
 
# Change l'adresse mac ?
MACCHANGER="0" #0=change la MAC, 1 garde la MAC d'origine
 
# Definition de quelques couleurs 
red='\e[0;31m'
redhl='\e[0;31;7m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color
 
#Mode Debug Dhcp ?
#DBG="-d"
 
 
#Sudo ?
if [ $USER != "root" ]
then
    echo -e $RED"Need to be root >>   sudo $0!"$NC
    exit 1
fi
 
#Verify all modules are installed
ifconfig=$(which ifconfig) 
if [ $? != 0 ]
then
    echo -e $RED"Fatal Error: No ifconfig found..."$NC
    exit 1
fi
 
hostapd=$(which hostapd)
if [ $? != 0 ]
then
    echo -e $RED"Fatal Error: No hostapd installed..."$NC
    exit 1
fi
 
dnsmasq=$(which dnsmasq)
if [ $? != 0 ]
then
    echo -e $RED"Fatal Error: No dnsmasq on system..."$NC
    exit 1
fi
 
dhcpd3=$(which dhcpd)
if [ $? != 0 ]
then
    echo -e $RED"Fatal Error: dhcpd not found..."$NC
    exit 1
fi
 
macchanger=$(which macchanger)
if [ $? != 0 ]
then
    echo -e $RED"Warning: macchanger not found. Mac@ will not be modified!"$NC
    MACCHANGER="1"
fi
 
echo -e $blue"Start and configuration of the interface $INT_2..."$NC
#Get interface2 state to restore
stateWifi=$(ifconfig | grep $INT_2)
if [ "$stateWifi" != "" ]; then
    stateWifi="ON"
fi

#MAC@ modification 
if [ $MACCHANGER == "0" ]
then
    echo -e $blue"Macchanger random..."$NC
    sudo $ifconfig $INT_2 down
    sudo $macchanger --random $INT_2 $NC
fi
 
sudo ifconfig $INT_2 down
sleep 0.5
sudo ifconfig $INT_2 $IP netmask $MASK up
 
echo -e $blue"Starting daemon hostapd..."$NC
# start hostapd server (see /etc/hostapd/hostapd.conf)
sudo hostapd /etc/hostapd/hostapd.conf &
sleep 1
 
echo -e $blue"Starting daemon dnsmasq... "$NC
# start dnsmasq server (see /etc/dnsmasq.conf) -7 /etc/dnsmasq.d
sudo dnsmasq -x /var/run/dnsmasq.pid -C /etc/dnsmasq.conf
sleep 1
 
echo -e $blue"Starting daemon dhcpd... "$NC
# start or restart dhcpd server (see /etc/dhcpd/dhcpd.conf)
sudo touch /var/lib/dhcp/dhcpd.leases
#sudo mkdir -p /var/run/dhcp-server
#sudo chown dhcpd:dhcpd /var/run/dhcp-server
sudo dhcpd $DBG -f -pf /var/run/dhcp-server/dhcpd.pid -cf /etc/dhcp/dhcpd.conf $INT_2 &
#/etc/init.d/dhcp-server restart
sleep 2
 
# Turn on IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
 
echo -e $blue"Turn on iptables NAT MASQUERADE interface $NC$red$INT_NET$NC"
# load masquerade module
sudo modprobe ipt_MASQUERADE
sudo iptables -A POSTROUTING -t nat -o $INT_NET -j MASQUERADE
 
echo -e $blue"Turn on iptables FORWARD & INPUT between interface $NC$red$INT_2$NC$blue & network $NC$red$SUBNET$NC"
sudo iptables -A FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT
sudo iptables -A FORWARD -i $INT_2 --destination $SUBNET --match state --state NEW --jump ACCEPT
sudo iptables -A INPUT -s $SUBNET --jump ACCEPT
 
# Wait user interaction !!!
echo -e $redhl"[Forwarding enabled, do not close terminal! ]"$NC
echo -e $redhl"[ENTER = STOP hostapd dhcpd dnsmasq   ]"$NC
echo -e $redhl"[        STOP interface wifi $INT_2   ]"$NC
echo -e $redhl"[        Clean up                     ]"$NC
read none
 
 
echo -e $cyan"Stop hostapd, dhcpd, dnsmasq & interface wifi $INT_2..."$NC
# kill hostapd, dnsmasq & dhcpd
sudo killall hostapd dnsmasq dhcpd
echo -e $cyan"Turn off iptables NAT MASQUERADE...$NC$red$INT_NET$NC"$NC
sudo iptables -D POSTROUTING -t nat -o $INT_NET -j MASQUERADE 2>/dev/null || echo -e $cyan"POSTROUTING $INT_NET MASQUERADE clean OK!"$NC
sudo iptables -D FORWARD -i $INT_2 --destination $SUBNET --match state --state NEW --jump ACCEPT 2>/dev/null || echo -e $cyan"FORWARD $INT_NET/$SUBNET clean OK!"$NC
sudo iptables -D FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT 2>/dev/null || echo -e $cyan"FORWARD ESTABLISHED clean OK!"$NC
sudo iptables -D INPUT -s $SUBNET --jump ACCEPT 2>/dev/null || echo -e $cyan"INPUT $SUBNET clean OK!"$NC
 
echo -e $cyan"Turn off iptables FORWARD & INPUT...$NC $red$INT_2$NC$blue & $NC$red$SUBNET$NC"
# interface wake up!
sudo ifconfig $INT_2 down
if [ "$stateWifi" = "ON" ]; then
    sudo ifconfig $INT_2 up
fi
 
# Turn off IP forwarding
echo 0 > /proc/sys/net/ipv4/ip_forward
echo -e $blue"Done!"$NC

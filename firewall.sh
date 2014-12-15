#!/bin/sh
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#Flush semua table
iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT
iptables -F -t nat

#eth0 is the green zone
#wlan0 is the red zone
#Membina undang-undang
#INPUT Rules
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i wlan0 -s 0/0 -d 0/0 -j ACCEPT
iptables -A INPUT -i lo -s 0/0 -d 0/0 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 80 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 443 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 22 -j ACCEPT
iptables -A INPUT -p udp -s 0/0 -d 0/0 --destination-port 53 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 1863 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 5050 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 21 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 3128 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 3000 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

#Forward rule
iptables -A FORWARD -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 80 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 443 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p udp --destination-port 53 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 1863 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 5050 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 22 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 21 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --destination-port 6667 -o wlan0 -j ACCEPT
iptables -A FORWARD -i lo -p tcp --destination-port 3128 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -p udp --destination-port 53 -o wlan0 -j ACCEPT
iptables -A FORWARD -i eth0 -o wlan0 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -i lo -o wlan0 -j ACCEPT

#nat table
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

#redirect port
/sbin/iptables -t nat -A PREROUTING -i wlan0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3128
/sbin/iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 80 -j DNAT --to-destination 192.168.0.1:3128

#Besarkan sikit port
echo 1024 32768 > /proc/sys/net/ipv4/ip_local_port_range

#Block yang mana patut
/sbin/iptables -A FORWARD -p tcp -m multiport --dports 6881,6882,6883,6884,6885,6886,6887,6888,6889,1214 -j REJECT
/sbin/iptables -A FORWARD -p udp -m multiport --dports 6881,6882,6883,6884,6885,6886,6887,6888,6889,1214 -j REJECT
/sbin/iptables -A FORWARD -p tcp -m multiport --dports 6346,6347 -j REJECT
/sbin/iptables -A FORWARD -p udp -m multiport --dports 6346,6347 -j REJECT
/sbin/iptables -A FORWARD -p tcp -m multiport --dports 4711,4665,4661,4672,4662,8080,9955 -j REJECT
/sbin/iptables -A FORWARD -p udp -m multiport --dports 4711,4665,4661,4672,4662,8080,9955 -j REJECT
/sbin/iptables -A FORWARD -p tcp --dport 4242:4299 -j REJECT
/sbin/iptables -A FORWARD -p udp --dport 4242:4299 -j REJECT
/sbin/iptables -A FORWARD -p tcp --dport 6881:6999 -j REJECT
/sbin/iptables -A FORWARD -p udp --dport 6881:6999 -j REJECT
iptables -t filter -A INPUT -p tcp -i eth0 --destination-port 6881:6889 -j REJECT
iptables -t filter -A INPUT -p tcp -i lo --destination-port 6881:6889 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --destination-port 6881:6889 -j REJECT
iptables -t filter -A INPUT -p tcp -i eth0 --destination-port 6881:6999 -j REJECT
iptables -t filter -A INPUT -p tcp -i lo --destination-port 6881:6999 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --destination-port 6881:6999 -j REJECT
#iptables -t filter -A INPUT -p tcp --dports 6881:6889 -j DROP
#iptables -t filter -A INPUT -p tcp --dports 6881:6999 -j DROP
iptables -A OUTPUT -s 192.168.0.0/24 -p udp -j REJECT
iptables -A OUTPUT -s 127.0.0.1 -p udp -j ACCEPT
iptables -A INPUT -i eth0 -s 192.168.0.0/24 -p udp -j REJECT
iptables -A INPUT -i lo -p udp -j ACCEPT

#!/usr/bin/bash
# IP address that is allowed access
ips=("1.2.3.4" "5.6.7.8" "10.11.12.13")

# Interface name with public IP address
eth_name=enp2s0f0

# Interface name for Docker containers network
docker_iface_name=mlp_iface

# Testing a standard rule that makes containers available to the entire Internet
/usr/sbin/iptables -C DOCKER-USER -j RETURN 2>> /dev/null
if [[ $? -eq 0 ]]
then /usr/sbin/iptables -D DOCKER-USER -j RETURN
fi

# Checking for a rule that denies access to the container network
/usr/sbin/iptables -C DOCKER-USER -i $eth_name -o $docker_iface_name -j DROP 2>> /dev/null
if [[ $? -eq 1 ]]
then /usr/sbin/iptables -A DOCKER-USER -i $eth_name -o $docker_iface_name -j DROP
fi

# Checking the presence of rules for allowed IP addresses
for ip in ${ips[@]}; do
 /usr/sbin/iptables -C DOCKER-USER -s $ip/32 -i $eth_name -j RETURN 2>> /dev/null
 if [[ $? -eq 1 ]]
 then /usr/sbin/iptables -I DOCKER-USER 1 -s $ip -i $eth_name -j RETURN
 fi
done
exit 0

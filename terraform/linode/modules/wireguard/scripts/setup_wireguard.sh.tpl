#!/bin/bash
# <UDF name="wg_private_key" label="Private Key used by the Wireguard server bootstrapped by this script" />
#
# nimbus
# Linode Terraform
# Wireguard VPN Bootstrap script template
#

set -ex

# install wireguard VPN
apt-get update
apt-get install -y wireguard

# enable ip forwarding for VPN to allow clients to access hosts the server can access
sysctl -w net.ipv4.ip_forward=1

# setup config for wireguard VPN
mkdir -p /etc/wireguard
cat >/etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $${WG_PRIVATE_KEY}
Address = ${wg_server["address_ip"]}/${cidr_length}
ListenPort = ${wg_server["port"]}

PostUp = echo "$(date +%s) WireGuard server started"
PostDown = echo "$(date +%s) WireGuard server stopped"

# toggle iptables forwarding rules on VPN up/down
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE;
%{~ for src_port, dest in port_forwards ~}
 iptables -t nat -A PREROUTING -p tcp --dport ${src_port} -j DNAT --to-destination ${dest}; ip6tables -t nat -A PREROUTING -p tcp --dport ${src_port} -j DNAT --to-destination ${dest};
%{~ endfor ~}

PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE;
%{~ for src_port, dest in port_forwards ~}
 iptables -t nat -D PREROUTING -p tcp --dport ${src_port} -j DNAT --to-destination ${dest}; ip6tables -t nat -D PREROUTING -p tcp --dport ${src_port} -j DNAT --to-destination ${dest};
%{~ endfor ~}

%{ for public_key, address_ip in wg_peers ~}
[Peer]
PublicKey = ${public_key}
AllowedIPs =  ${address_ip}/32
%{ endfor ~}
EOF

# start wireguard VPN
systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

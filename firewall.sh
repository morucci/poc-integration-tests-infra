#!/bin/sh

dev=$(ip -4 r|awk '/^default via/ {print $5}')
iptables -t nat -A POSTROUTING -o $dev -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

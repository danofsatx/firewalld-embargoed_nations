#!/bin/bash

#####################################################
# block_embargoed.sh
# Author: Dan Mossor, danofsatx
#
# Script created to bring the Fedora Live Respins
# team into United States Export Law Compliance.
# The script makes the following assumtions:
#
# the zone files from http://www.ipdeny.com/ipblocks/
# are downloaded to a directory:
# all-zones.tar.gz is unpacked into ./ipv4/
# ipv6-all-zones.tar.gz is unpacked into ./ipv6/
#
# Note: North Korea does not have an IPv6 allocation.
#####################################################

COUNTRYv4="cu ir kp sd sy"
COUNTRYv6="cu ir sd sy"

# Create the master lists that everything will be added to
ipset create ipv4-embargoed_nations list:set
ipset create ipv6-embargoed_nations list:set

#build the ipsets
for i in $COUNTRYv4
  do ipset create $i-embargo hash:net
  for ip in `cat ipv4/$i.zone`
    do ipset add $i-embargo $ip
  done
ipset add ipv4-embargoed_nations $i-embargo
done

for i in $COUNTRYv6
  do ipset create $i-v6-embargo hash:net family inet6
  for ip in `cat ipv6/$i.zone`
    do ipset add $i-v6-embargo $ip
  done
ipset add ipv6-embargoed_nations $i-v6-embargo
done

# Build the direct rule for firewalld to drop the connections
# and make it permanent
firewall-cmd --direct --add-rule ipv4 raw PREROUTING_ZONES_SOURCE 0 -m set --match-set ipv4-embargoed_nations src -j DROP
firewall-cmd --direct --add-rule ipv6 raw PREROUTING_ZONES_SOURCE 0 -m set --match-set ipv6-embargoed_nations src -j DROP
firewall-cmd --runtime-to-permanent

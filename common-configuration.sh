#!/bin/bash

# a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
hostname --fqdn > /etc/hostname && hostname -F /etc/hostname
sed -ri 's/127\.0\.0\.1\s.*/127.0.0.1 localhost localhost.localdomain/' /etc/hosts
cp /usr/share/zoneinfo/UTC -f /etc/localtime

sudo subscription-manager repos --disable="*"
sudo subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.1-rpms"

sudo yum install -y deltarpm && \
sudo yum install -y ntp

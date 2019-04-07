#!/usr/bin/env sh

DIR=$(cd `dirname $0` && pwd)

# Install action
ln -Fs ${DIR}/actions_antizapret.conf /usr/local/opnsense/service/conf/actions.d/actions_antizapret.conf

# Reload config daemon
service configd restart

# Initially fetch data file
${DIR}/../antizapret.pl >/usr/local/etc/ipfw_antizapret.dat

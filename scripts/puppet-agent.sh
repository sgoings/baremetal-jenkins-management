#!/usr/bin/env bash

set -eo pipefail

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get --yes --force-yes install -f puppet

sudo service puppet stop

cat <<EOF | sudo tee /etc/puppet/puppet.conf 
[main]
server = puppet.goings.space
environment = production
runinterval = 30m

[agent]
waitforcert = 120

EOF

cat <<EOF | sudo tee /etc/default/puppet
# Defaults for puppet - sourced by /etc/init.d/puppet

# Enable puppet agent service?
# Setting this to "yes" allows the puppet agent service to run.
# Setting this to "no" keeps the puppet agent service from running.
START=yes

# Startup options
DAEMON_OPTS=""

EOF

sudo service puppet start

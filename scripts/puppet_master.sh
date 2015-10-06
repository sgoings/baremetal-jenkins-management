#!/usr/bin/env bash

set -eo pipefail

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get --yes --force-yes install -f puppetmaster-passenger

cat <<EOF | sudo tee /etc/puppet/puppet.conf
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates
dns_alt_names = puppet,puppet.goings.space

[master]
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
autosign = true

EOF

sudo service apache2 stop

sudo puppet cert clean --all
cat <<EOF | sudo tee /etc/puppet/autosign.conf
*.goings.space
*ec2.internal
EOF

sudo puppet master --verbose --no-daemonize &
sleep 10
sudo killall puppet || true

sudo puppet master

#!/bin/bash

echo $(hostname -f)


if [[ $(grep -c "# Local hosts" /etc/hosts) -eq 0 ]]; then 
	cat /vagrant/bootstrap/hosts >> /etc/hosts
fi

. /etc/lsb-release

sed -e "s/trusty/${DISTRIB_CODENAME}/" /vagrant/bootstrap/sources.list > /etc/apt/sources.list
DEB=$(echo "http://apt.puppetlabs.com/puppetlabs-release-trusty.deb" | sed -e "s/trusty/${DISTRIB_CODENAME}/")
wget $DEB -O /tmp/puppetlabs.deb
# dpkg -i /tmp/puppetlabs.deb

apt-get clean
apt-get update
apt-get -y install vim-nox language-pack-en git puppet
locale-gen UTF-8

cp /vagrant/easyenc.py /usr/local/bin/easyenc.py
chmod +x /usr/local/bin/easyenc.py

echo "#node_terminus = exec" >> /etc/puppet.conf
echo "#external_nodes = /usr/local/bin/easyenc.py /etc/puppet/easyenc.yaml" >> /etc/puppet.conf

# Install puppet:
#  sudo puppet apply -e "class{'puppet::repo::puppetlabs': } Class['puppet::repo::puppetlabs'] -> Package <| |> class { 'puppetdb': }  class { 'puppet::master': storeconfigs => true, environments => 'directory' }" --modulepath=/vagrant/puppet/modules

# for MOD in stephenrjohnson/puppet zack/r10k hunner/hiera; do sudo puppet module install $MOD; done
# sudo puppet apply r10k_installation.pp
# sudo -H r10k deploy environment -pv

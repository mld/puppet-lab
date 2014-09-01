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

# puppet module install --modulepath=/vagrant/puppet/modules puppetlabs-ruby
# sudo puppet apply --modulepath=/vagrant/puppet/modules -e "include ruby"
# puppet module install --modulepath=/vagrant/puppet/modules zack-r10k
# sudo puppet apply --modulepath=/vagrant/puppet/modules -e "class { 'r10k': remote => 'git@github.com:someuser/puppet.git', }"
#
# puppet modules requred for initial setup:
#  stephenrjohnson-puppet zack-r10k
# Install modules:
#  puppet module install --modulepath=/vagrant/puppet/modules <modulename>
# Install puppet:
#  sudo puppet apply -e "class{'puppet::repo::puppetlabs': } Class['puppet::repo::puppetlabs'] -> Package <| |> class { 'puppetdb': }  class { 'puppet::master': storeconfigs => true, environments => 'directory' }" --modulepath=/vagrant/puppet/modules
# Install r10k:
#  sudo puppet apply -e "class { 'r10k': remote => 'https://github.com/mld/puppet-lab-r10k.git', configfile => '/etc/puppet/r10k.yaml', manage_configfile_symlink => true, configfile_symlink => '/etc/r10k.yaml' }" --modulepath=/vagrant/puppet/modules
# Deploy with r10k
#  sudo r10k deploy environment
#
# sudo puppet apply /vagrant/puppet/r10k_installation.pp --modulepath=/vagrant/puppet/modules

# for MOD in stephenrjohnson/puppet zack/r10k hunner/hiera; do sudo puppet module install $MOD; done
# sudo puppet apply r10k_installation.pp
# sudo -H r10k deploy environment -pv

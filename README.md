# En laboration i puppet

## 1. Installation
I det här steget installerar vi en puppet master och två noder.

Krav på systemen:

* puppet (puppet master)
  * 2G RAM
  * 2 cores
  * 6G disk
  * Ubuntu 12.04 amd64
* node1
  * 1G RAM
  * 1 core
  * 4G disk
  * Ubuntu 12.04 amd64
* node2
  * 1G RAM
  * 1 core
  * 4G disk
  * Ubuntu 10.04 amd64

### puppet
Installera en puppetmastern.

#### Grundinstallation
```
client$ virt-viewer --connect qemu+ssh://<user>@kvm02.example.com/system <server> &
```
Har du inte tillgång till virt-viewer, använd en ssh-tunnel och vnc.annars ssh-tunnel+vnc. Ta reda på vilken vnc-display din server har genom 
```
kvm$ virsh vncdisplay <server>
```

#### Lägg in puppets paketarkiv
```
puppet$ wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
puppet$ sudo dpkg -i puppetlabs-release-precise.deb
```
#### Installera puppet-agenten och gör grundkonfiguration
```
puppet$ sudo apt-get install puppet
puppet$ sudo vim /etc/puppet/puppet.conf
```
 
#### Installera puppetmaster
```
puppet$ sudo apt-get install puppetmaster
puppet$ sudo vim /etc/puppet/puppet.conf
```
 
### node1 och node2
Installera bägge noderna.

#### Grundinstallation
```
client$ virt-viewer --connect qemu+ssh://<user>@kvm02.example.com/system <server> &
```
Har du inte tillgång till virt-viewer, använd en ssh-tunnel och vnc.annars ssh-tunnel+vnc. Ta reda på vilken vnc-display din server har genom 
```
kvm$ virsh vncdisplay <server>
```

#### Lägg in puppets paketarkiv
#### node1 (Ubuntu 12.04)
```
puppet$ wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
puppet$ sudo dpkg -i puppetlabs-release-precise.deb
```
#### node2 (Ubuntu 10.04)
```
puppet$ wget http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
puppet$ sudo dpkg -i puppetlabs-release-lucid.deb
```
#### Installera puppet-agenten och gör grundkonfiguration
```
puppet$ sudo apt-get install puppet
puppet$ sudo vim /etc/puppet/puppet.conf
```
 

## 2. resolv.conf

## 3. OpenSSH

# To be continued...

## Hiera

### hiera-gpg backend

## PuppetDB

## Puppetmaster som Intermedia-CA

## Puppet Dashboard

## Puppet och Kerberos/LDAP

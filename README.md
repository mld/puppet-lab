# En laboration i puppet

# 1. Installation
I det här steget installerar vi tre Ubuntu-servrar; en puppet-master och två noder med puppet-agenten.

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

## puppet
Installera en puppetmastern.

### Grundinstallation
```
client$ virt-viewer --connect qemu+ssh://<user>@kvm02.example.com/system <server> &
```
Har du inte tillgång till virt-viewer, använd en ssh-tunnel och vnc.annars ssh-tunnel+vnc. Ta reda på vilken vnc-display din server har genom 
```
kvm$ virsh vncdisplay <server>
```

### Lägg in puppets paketarkiv
```
puppet$ wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
puppet$ sudo dpkg -i puppetlabs-release-precise.deb
```
### Installera puppet-agenten och gör grundkonfiguration för mastern
__OBS__ Grundkonfiguration för mastern måste göras innan den startas första gången för att den interna CA:n ska bli rätt. Då puppetmastern startar automatiskt när den installeras så konfigurerar vi den i förväg.
```
puppet$ sudo apt-get update
puppet$ sudo apt-get install puppet
puppet$ sudo vim /etc/puppet/puppet.conf
```

__/etc/puppet/puppet.conf__ för puppetmaster:
```
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates

# behövs inte alltid, men är en fördel att ha. default är puppet.<domän>
server=puppet.x.lab.example.com
report=true
# Behöver normalt inte sättas, fqdn används default
certname=node1.x.lab.example.com
pluginsync = true

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY

# behövs inte, men kan vara trevligt om man vet att man har en standbyserver som man kan tänkas växla över till
dns_alt_names=puppet.lab.example.com
reports=log
```

__Valfritt:__ För att puppet-agenten ska starta automatiskt behöver även /etc/default/puppet ändras:
```
# Defaults for puppet - sourced by /etc/init.d/puppet

# Start puppet on boot?
START=yes

# Startup options
DAEMON_OPTS=""
```

### Installera puppetmaster
```
puppet$ sudo apt-get install puppetmaster
```



## node1 och node2
Installera bägge noderna.

### Grundinstallation
```
client$ virt-viewer --connect qemu+ssh://<user>@kvm02.example.com/system <server> &
```
Har du inte tillgång till virt-viewer, använd en ssh-tunnel och vnc.annars ssh-tunnel+vnc. Ta reda på vilken vnc-display din server har genom 
```
kvm$ virsh vncdisplay <server>
```

### Lägg in puppets paketarkiv
Initiera noderna med puppet och en grundkonfiguration.

### node1 (Ubuntu 12.04)
```
node1$ wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
node1$ sudo dpkg -i puppetlabs-release-precise.deb
node1$ sudo apt-get update
node1$ sudo apt-get install puppet
node1$ sudo vim /etc/puppet/puppet.conf
```
### node2 (Ubuntu 10.04)
```
node2$ wget http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
node2$ sudo dpkg -i puppetlabs-release-lucid.deb
node2$ sudo apt-get update
node2$ sudo apt-get install puppet
node2$ sudo vim /etc/puppet/puppet.conf
```
__/etc/puppet/puppet.conf__ för noder:
```
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates

# behövs inte alltid, men är en fördel att ha. default är puppet.<domän>
server=puppet.x.lab.example.com
report=true
# Behöver normalt inte sättas, fqdn används default
certname=node1.x.lab.example.com
pluginsync = true
```

__Valfritt:__ För att puppet-agenten ska starta automatiskt behöver även /etc/default/puppet ändras:
```
# Defaults for puppet - sourced by /etc/init.d/puppet

# Start puppet on boot?
START=yes

# Startup options
DAEMON_OPTS=""
```



# 2. resolv.conf
I den här delen ansluter vi noderna till puppet-mastern, börjar med en do-nothing-conf för puppet och lägger sedan till en modul som hanterar /etc/resolv.conf.

## Anslut noderna till puppetmastern

På node1 respektive node2, kör följande:
```
sudo puppet agent --no-daemonize --verbose --waitforcert=10
```
Det här skapar en privat nyckel för noden och i samarbete med mastern en csr, sen väntar klienten på att få tillbaka ett certifikat från mastern.

Exempelkörning:
```
node1$ sudo puppet agent --no-daemonize --verbose --waitforcert=10
Info: Creating a new SSL key for node1.lab.example.com
Error: Could not request certificate: Connection refused - connect(2)
Error: Could not request certificate: Connection refused - connect(2)
Error: Could not request certificate: Connection refused - connect(2)
Info: Caching certificate for ca
Info: Creating a new SSL certificate request for node1.lab.example.com
Info: Certificate Request fingerprint (SHA256): 41:74:15:CE:44:7B:52:06:11:69:98:FC:B7:53:F2:B7:BA:B2:F1:5B:4F:8F:A0:E1:FD:39:10:50:C8:C2:75:BC
Did not receive certificate

Did not receive certificate
Info: Caching certificate for node1.lab.example.com
Starting Puppet client version 3.0.1
Info: Caching certificate_revocation_list for ca
Info: Retrieving plugin
Using cached catalog
Error: Could not retrieve catalog; skipping run
```


På puppetmastern kommer du efteråt kunna se något liknande det här:
```
puppet$ puppet cert --list
  "node1.lab.example.com" (SHA256) 41:74:15:CE:44:7B:52:06:11:69:98:FC:B7:53:F2:B7:BA:B2:F1:5B:4F:8F:A0:E1:FD:39:10:50:C8:C2:75:BC
  "node2.lab.example.com" (SHA256) 51:84:25:AB:44:7B:52:06:11:69:98:FC:B7:53:F2:B7:BA:B2:F1:5B:4F:8F:A0:E1:FD:39:10:50:C8:C2:75:BC
```
Nästa steg är att signera nod-certifikaten:
```
puppet$ puppet cert --sign node1.lab.example.com
Signed certificate request for node1.lab.example.com
Removing file Puppet::SSL::CertificateRequest node1.lab.example.com at '/var/lib/puppet/ssl/ca/requests/node1.lab.example.com.pem'
```

Nu pratar förhoppningsvis bägge noderna med puppetmastern och vi är redo att göra något på riktigt!

## Skapa grundkonfiguration för noderna
__/etc/puppet/manifests/site.pp__:
```
$puppetserver = 'puppet.lab.example.com'

node 'puppet.lab.example.com' {

}
node 'node1.lab.example.com' {

}
node 'node2.lab.example.com' {

}

```

## Bygg resolvconf-modulen

__/etc/puppet/modules/resolvconf/manifests/init.pp__:
```
class resolvconf {

    package { 'resolvconf':
        ensure	=> purged
    }

    file { "/etc/resolv.conf":
        source	=> 'puppet:///modules/resolvconf/etc/resolv.conf',
        owner   => root,
        group   => root,
        mode    => 0644,
        ensure	=> file,
        require	=> Package['resolvconf'],
    }
}
```

__/etc/puppet/modules/resolvconf/files/etc/resolv.conf__:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
search lab.example.com
```

Inkludera resolvconf-modulen på en nod.
__/etc/puppet/manifests/site.pp:__
```
$puppetserver = 'puppet.lab.example.com'

node 'puppet.lab.example.com' {

}
node 'node1.lab.example.com' {
  include resolvconf
}
node 'node2.lab.example.com' {

}
```

Kör agenten en gång på node1 för att se att det fungerar:
```
node1$ sudo puppet agent --no-daemonize --verbose --onetime
Info: Retrieving plugin
Info: Caching catalog for node1.lab.example.com
Info: Applying configuration version '1352643134'
Info: FileBucket got a duplicate file {md5}a3833cde72f68a4da35d51db380b8978
Info: /Stage[main]/Resolvconf/File[/etc/resolv.conf]: Filebucketed /etc/resolv.conf to puppet with sum a3833cde72f68a4da35d51db380b8978
/Stage[main]/Resolvconf/File[/etc/resolv.conf]/content: content changed '{md5}a3833cde72f68a4da35d51db380b8978' to '{md5}84e65d653359f3bf2328139427d085b9'
Finished catalog run in 0.30 seconds

node1$ cat /etc/resolv.conf 
nameserver 8.8.8.8
nameserver 8.8.4.4
search lab.example.com
```

Nu kan du inkludera resolvconf-modulen på övriga noder också.



# 3. OpenSSH


# To be continued...

## Hiera

### hiera-gpg backend

## PuppetDB

## Puppetmaster som Intermedia-CA

## Puppet Dashboard

## Puppet och Kerberos/LDAP

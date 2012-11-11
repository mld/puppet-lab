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
Installera puppetmastern.

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

Man kan även lägga in ytterligare parametrar i /etc/puppet.conf, t ex:
```
    runinterval = 1800
    splaylimit = 1800
    splay = false
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

## Mer...

Testa även att göra om source-parametern för filen till en array, t ex:
```
source	=> ['puppet:///modules/resolvconf/etc/resolv.conf.$hostname', 'puppet:///modules/resolvconf/etc/resolv.conf']
```

# 3. OpenSSH

OpenSSH-modulen blir väldigt lik den för resolvconf, men vi låter den ta emot en parameter (rootlogin) för att hantera direktivet PermitRootLogin i /etc/sshd_config och väljer dessutom vilken mall vi ska utgå ifrån beroende på vilken distribution vi kör just nu.

Vi kommer använda oss av 
+ parameterized classes, se http://docs.puppetlabs.com/learning/modules2.html
+ templates, se http://docs.puppetlabs.com/learning/templates.html

## Modulen
__/etc/puppet/modules/openssh/manifests/init.pp__:
```
class openssh($rootlogin = 'without-password') {
	case $lsbdistcodename {
		'lucid': {
			$conf_template = 'sshd_config.lucid.erb'
		}
		'precise': {
			$conf_template = 'sshd_config.precise.erb'
		}
		default: {
			$conf_template = 'sshd_config.erb'
		}
	}

	file { "/etc/ssh/sshd_config":
		ensure => present,
		content => template("openssh/${conf_template}"),
		owner => "root",
		group => "secore",
		mode => "644",
		require => Package["openssh-server"],
		notify => Service["ssh"],
	}

	package { "openssh-server":
		ensure => latest,
	}

	service { 'ssh':
		name => "ssh",
		ensure => running,
		hasrestart => true,
		enable => true,
		require => Package['openssh-server'],
	}
}
```

__/etc/puppet/modules/openssh/templates/sshd_config.precise.erb__:
```
# Configuration for ssh server on Ubuntu Precise (12.04)
# See the sshd_config(5) manpage for details

Port 22
Protocol 2

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
UsePrivilegeSeparation yes

KeyRegenerationInterval 3600
ServerKeyBits 768

SyslogFacility AUTH
LogLevel INFO

LoginGraceTime 120
PermitRootLogin <%= rootlogin %>
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes

IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no

PermitEmptyPasswords no

ChallengeResponseAuthentication no

# Change to no to disable tunnelled clear text passwords
#PasswordAuthentication yes

X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes

AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

UsePAM yes
```

__/etc/puppet/modules/openssh/templates/sshd_config.lucid.erb__:
```
# Configuration for ssh server on Ubuntu Lucid (10.04)
# See the sshd_config(5) manpage for details

Port 22
Protocol 2

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
UsePrivilegeSeparation yes

KeyRegenerationInterval 3600
ServerKeyBits 768

SyslogFacility AUTH
LogLevel INFO

LoginGraceTime 120
PermitRootLogin <%= rootlogin %>
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes

IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no

PermitEmptyPasswords no

ChallengeResponseAuthentication no

# Change to no to disable tunnelled clear text passwords
#PasswordAuthentication yes

X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes

AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

UsePAM yes
```

__/etc/puppet/modules/openssh/templates/sshd_config.erb__:
```
# Default configuration for ssh server
# See the sshd_config(5) manpage for details

Port 22
Protocol 2

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
UsePrivilegeSeparation yes

KeyRegenerationInterval 3600
ServerKeyBits 768

SyslogFacility AUTH
LogLevel INFO

LoginGraceTime 120
PermitRootLogin <%= rootlogin %>
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes

IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no

PermitEmptyPasswords no

ChallengeResponseAuthentication no

# Change to no to disable tunnelled clear text passwords
#PasswordAuthentication yes

X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes

AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

UsePAM yes
```

## site.pp

Här har vi ett nytt sätt att anropa en modul/klass, eftersom vi valt att kunna skicka med parametrar:

```
$puppetserver = 'puppet.lab.example.com'

node 'puppet.lab.example.com' {

}
node 'node1.lab.example.com' {
  include resolvconf
  class { 'openssh': rootlogin => 'no' }
}
node 'node2.lab.example.com' {
  include resolvconf
  class { 'openssh': rootlogin => 'without-password' }
}
```

## Testa...

Kör puppet agent på noderna:
```
node1$ sudo puppet agent --no-daemonize --verbose --onetime
...

node2$ sudo puppet agent --no-daemonize --verbose --onetime
...
```

Kontrollera att du fått ut precise respektive lucid-confen på dom olika noderna.

Lägg till ytterligare en parameter i openssh-klassen, PasswordAuthentication. Testa...

# 4. Hiera
Hiera är ett verktyg för att på ett samlat sätt skicka in parametrar till noder, klasser och moduler. Från Puppet 3.0 följer det med automatiskt i puppetinstallationen. Läs mer om Hiera på http://puppetlabs.com/blog/first-look-installing-and-using-hiera/

Vi sätter upp hiera att hämta information i tre nivåer. Första nivån är om det finns en fil tillgänglig för ett unikt fqdn, t ex node1.lab.example.com.yaml. Nästa nivå är baserad på dist-namn, t ex precise eller lucid. Dom hämtas från lucid.yaml, precise.yaml, ...
Den tredje nivån är defaultvärden som ligger i common.yaml.

## Förberedelser

### Konfigurerara Hiera
__/etc/hiera.conf__:
```
---
:hierarchy:
    - %{fqdn}
    - %{lsbdistcodename}
    - common
:backends:
    - yaml
:yaml:
    :datadir: '/etc/puppet/hieradata'
```

### Lägg in data i hiera
__/etc/puppet/hieradata/common.yaml__:
```
---
root_login : 'no'
```

__/etc/puppet/hieradata/precise.yaml__:
```
---
root_login : 'without-password'
```

__/etc/puppet/hieradata/node2.lab.example.com.yaml__:
```
---
root_login : 'yes'
```

### Anpassa OpenSSH-modulen
Ändra första raden i init.pp så den använder hiera som defaultvärde.

__/etc/puppet/modules/openssh/manifests/init.pp__:
```
class openssh($rootlogin = hiera('root_login')) {
```

Testkör på noderna och se att hierarkin fungerar som den ska. Notera att i det här exemplet är deta från hiera default-värdet, och kan köras över från nod-definitionen!

## Gå vidare med Hiera...

+ Lägg till fler variabler för OpenSSH-modulen. 
+ Anpassa resolvconf-modulen så den tar namnservrar i form av en yaml-array från hiera.
+ Installera och experimentera med hiera-gpg. Se http://www.craigdunn.org/2011/10/secret-variables-in-puppet-with-hiera-and-gpg/

# Mycket mer att titta på

Här är ett par idéer på annat att testa och/eller se över om det över huvud taget är möjligt att bygga ihop.
## Custom facts i facter
+ http://docs.puppetlabs.com/guides/plugins_in_modules.html
+ http://docs.puppetlabs.com/guides/custom_facts.html

## PuppetDB
+ Installera, testa, utvärdera
Se http://docs.puppetlabs.com/puppetdb/1/index.html

## Puppet Dashboard
+ Installera, testa, utvärdera
  + Slut på support från Puppet Labs, men kommer troligen leva kvar länge
Se http://docs.puppetlabs.com/dashboard/

## Testa environments, både i Puppet och Hiera
Se 
+ http://docs.puppetlabs.com/guides/environment.html
+ http://puppetlabs.com/blog/first-look-installing-and-using-hiera/

## MCollective
+ Installera, testa, utvärdera
Se http://docs.puppetlabs.com/mcollective/index.html

# Mer långsiktigt, kanske...
## Puppetmaster som Intermedia-CA för en intern (eller extern?) CA
Det råder tveksamheter om det är möjligt i v3.x av Puppet, men det finns requests på att lösa det.

## Puppet och Kerberos/LDAP
+ Användarhanteringen - använda lokala användare, men utgå från LDAP, med puppet som distributionsform?
+ Använda Kerberos istället för SSL för autenticering mellan puppetmaster och agenter
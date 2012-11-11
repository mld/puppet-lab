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


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

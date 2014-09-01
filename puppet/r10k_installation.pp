class { 'r10k':
  sources           => {
    'puppet' => {
      'remote'  => 'git@bitbucket.org:mikaelld/r10kenv.git',
      'basedir' => "${::settings::confdir}/environments",
      'prefix'  => false,
    },
    'hiera' => {
      'remote'  => 'git@bitbucket.org:mikaelld/r10kenvhiera.git',
      'basedir' => "${::settings::confdir}/hiera",
      'prefix'  => false,
    }
  },
  purgedirs         => [
			"${::settings::confdir}/environments",
			"${::settings::confdir}/hiera"
			],
  manage_modulepath => true,
  modulepath        => "${::settings::confdir}/environments/\$environment/modules:/opt/puppet/share/puppet/modules",
}

class { 'hiera':
  hierarchy => [
    'node/%{clientcert}',
    'env/%{environment}',
    'global',
  ],
}

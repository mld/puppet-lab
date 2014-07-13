class puppetmaster {
	package { 'puppetmaster':
		provider => 'apt',
		ensure   => 'installed'
	}

	
}

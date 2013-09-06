class env {
	file {"/home/vagrant/.profile":
		ensure => present,
		owner  => vagrant,
		group  => vagrant,
		mode   => 0644,
		source => "/tmp/vagrant-puppet/manifests/files/skel/.profile",
	}
	file {"/home/vagrant/.bash_logout":
		ensure  => present,
		owner   => vagrant,
		group   => vagrant,
		mode    => 0644,
		content => "clear",
	}
	file {"/home/vagrant/tmp":
		ensure => directory,
		owner  => vagrant,
		group  => vagrant,
		mode   => 0755,
	}
	file {"/home/vagrant/workspace":
		ensure => link,
		target => "/vagrant",
	}
	file {"/etc/profile.d/cp-mv-rm.sh":
		ensure => present,
		owner  => root,
		group  => root,
		mode   => 0755,
		source => "/tmp/vagrant-puppet/manifests/files/profile.d/cp-mv-rm.sh",
	}
	file {"/usr/local/bin/puppet-run-manifests":
		ensure => present,
		owner  => root,
		group  => root,
		mode   => 0755,
		source => "/tmp/vagrant-puppet/manifests/files/skel/puppet-run-manifests.sh",
	}
}

class vim {
    
    $vim     = "vim"
	$vimpath = "/etc/vim"
	
	package {[ "$vim" , "$vim-puppet" ]: ensure => present}
	exec {"vim-addons install puppet": path => "/usr/bin"}
	exec {"update-alternatives --set editor /usr/bin/vim.basic":
		path    => "/usr/bin:/usr/sbin:/bin",
		unless  => "test /etc/alternatives/editor -ef /usr/bin/vim.basic",
		require => Package["$vim"],
	}
	file {"$vimpath/vimrc.local":
		ensure  => present,
		source  => "/tmp/vagrant-puppet/manifests/files/vim/vimrc.local",
		owner   => root,
		group   => root,
		mode    => 0644,
		require => Package["$vim"],
	}
}

class utils {
    $packages = [
        'whois',
        'lynx',
        'telnet',
        'wget',
        'curl',
        'tar',
        'zip',
        'unzip',
        'bzip2',
        'nmap',
        'git',
        'subversion',
        'build-essential',
	]
	package {$packages: ensure  => installed}
	package {"tzdata" : ensure  => latest   }
}

class apache {
	
    package {"apache2": ensure => present}
    service {"apache2":
        ensure  => running,
        require => Package["apache2"],
    }
	
    define apache::loadmodule () {
        exec {"/usr/sbin/a2enmod ${name}":
            unless  => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
        	require => Package["apache2"],
            notify  => Service["apache2"],
        }
    }
    apache::loadmodule{"rewrite":}
	
	file {"/etc/apache2/sites-available/default":
		ensure  => present,
		source  => "/tmp/vagrant-puppet/manifests/files/apache/default",
		owner   => root,
		group   => root,
		mode    => 0644,
        require => Package["apache2"],
		notify  => Service["apache2"],
	}
}

class php {
    $packages = [
		'libapache2-mod-php5',
		'php5',
		'php-apc',
		'php-pear',
		'php5-cli',
		'php5-curl',
		'php5-dbg',
		'php5-dev',
		'php5-gd',
		'php5-imagick',
		'php5-imap',
		'php5-ldap',
		'php5-mcrypt',
		'php5-memcache',
		'php5-memcached',
		'php5-mysql',
		'php5-odbc',
		'php5-pgsql',
		'php5-pspell',
		'php5-recode',
		'php5-sqlite',
		'php5-svn',
		'php5-sybase',
		'php5-xdebug',
		'php5-xmlrpc',
		'php5-xsl',
	]
	package{$packages: ensure  => installed}
	
	file {"/etc/php5/cli/php.ini":
		ensure  => present,
		owner   => root,
		group   => root,
		mode    => 0644,
		source  => "/tmp/vagrant-puppet/manifests/files/php/php.ini",
		require => Package[$packages],
	}
	file {"/etc/php5/apache2/php.ini":
		ensure  => present,
		owner   => root,
		group   => root,
		mode    => 0644,
		source  => "/tmp/vagrant-puppet/manifests/files/php/php.ini",
		notify  => Service["apache2"],
		require => Package[$packages],
	}
	file {"/etc/php.ini":
		ensure  => link,
		target  => "/etc/php5/apache2/php.ini",
		require => Package[$packages],
	}
}

class tools {
	
	# PEAR
	$pear1="pear chanel-update pear.php.net"
	$pear2="pear config-set auto_discover 1"
	$pear3="pecl chanel-update pecl.php.net"
    exec {$pear1:
		path   => "/usr/bin",
		before => Exec[$pear2],
	}
	exec {$pear2:
		path   => "/usr/bin",
		before => Exec[$pear3],
	}
	exec {$pear3:
		path   => "/usr/bin",
	}
	#ENDS PEAR
    
	# PHING
	$phing1="pear channel-discover pear.phing.info"
	$phing2="pear install --alldeps phing/phing"
	exec {$phing1:
		path    => "/usr/bin",
		onlyif  => "test ! -f /usr/bin/phing",
		require => Exec[$pear1],
		before  => Exec[$phing2],
	}
	exec {$phing2:
		path    => "/usr/bin",
		onlyif  => "test ! -f /usr/bin/phing",
		require => Exec[$phing1],
	}
	# ENDS PHING
}

stage {'preinstall': before => Stage['main']}
class apt_get_update { exec {'apt-get -y update': path => "/usr/bin" } }
class {'apt_get_update': stage => preinstall}

include env
include vim
include utils
include apache
include php
include tools

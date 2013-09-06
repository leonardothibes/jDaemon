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
        'lynx',
        'wget',
        'curl',
        'nmap',
        'git',
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
		'php5-cli',
		'php5-curl',
		'php5-memcache',
		'php5-memcached',
		'php5-mysql',
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

stage {'preinstall': before => Stage['main']}
class apt_get_update { exec {'apt-get -y update': path => "/usr/bin" } }
class {'apt_get_update': stage => preinstall}

include env
include vim
include utils
include apache
include php

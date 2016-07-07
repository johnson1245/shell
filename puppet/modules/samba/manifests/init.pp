#
# puppet class to install & configure samba
#

class samba::base {
	include samba::package
	include samba::service
}

class samba::package {
	$pkg = $sambaver ? {
		"3.4"	=> "samba3",
		default	=> "samba",
	}
	# ensure package is installed
	package { $pkg:
		ensure	=> installed,
	}
}

class samba::service {
	include samba::package
	$svc = $operatingsystem ? {
		"CentOS"	=> "smb",
		"Ubuntu"	=> "smbd",
		default		=> "samba",
	}
	service { $svc:
		enable		=> true,
		hasrestart	=> true,
		hasstatus	=> true,
		require		=> Class["samba::package"],
	}
}

define samba::user ( $password ) {
	exec { "smbpasswd $name":
		command		=> "echo '$password
$password' | smbpasswd -as $name",
	}
}

class samba::config {
	include samba::base
	$cfg = "/etc/samba/smb.conf"
	$templatedir = "/etc/puppet/modules/samba/templates"
	file { $cfg:
		ensure		=> file,
		mode		=> 644,
		owner		=> root,
		group		=> root,
		require		=> Class["samba::package"],
		notify		=> Class["samba::service"],
		content		=> template("samba/smb.conf.erb"),
	}
}

class samba::recycle {
	ulb { "empty-recycle-bin":
		source_class	=> "samba",
	}
	cron_job { "samba-empty-recycle-bin":
		interval	=> "weekly",
		script		=> "#!/bin/sh
/usr/local/bin/empty-recycle-bin
",
	}
}

define samba::recycle_custom ($args) {
	ulb { "empty-recycle-bin":
		source_class	=> "samba",
	}
	cron_job { "samba-empty-recycle-bin":
		interval	=> "weekly",
		script		=> "#!/bin/sh
/usr/local/bin/empty-recycle-bin $args
",
	}
}


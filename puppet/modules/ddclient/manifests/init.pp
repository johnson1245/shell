# puppet class to manage ddclient

class ddclient {
	include ddclient::package
	include ddclient::service
	$owner = $operatingsystem ? {
		CentOS	=> "ddclient",
		default	=> "root",
	}
	$group = $operatingsystem ? {
		CentOS	=> "ddclient",
		default	=> "root",
	}
}

class ddclient::package {
	$pkg = "ddclient"
	package { $pkg:
		ensure	=> installed,
	}
}

class ddclient::service {
	$svc = "ddclient"
	service { $svc:
		enable	=> true,
		require	=> Class["ddclient::package"],
	}
}

class ddclient::config {
	include ddclient
	$cfg = "/etc/ddclient.conf"
	$templatedir = "/etc/puppet/modules/ddclient/templates"
	file { $cfg:
		ensure	=> file,
		owner	=> $ddclient::owner,
		group	=> $ddclient::group,
		mode	=> 600,
		content	=> template("ddclient/ddclient.conf.erb"),
		notify	=> Class["ddclient::service"],
		require	=> Class["ddclient::package"],
	}
}

define ddclient::customconfig ( $template ) {
	include ddclient
	$cfg = "/etc/ddclient.conf"
	$templatedir = "/etc/puppet/modules/ddclient/templates"
	file { $cfg:
		ensure	=> file,
		owner	=> $ddclient::owner,
		group	=> $ddclient::group,
		mode	=> 600,
		content	=> template("ddclient/$template.erb"),
		notify	=> Class["ddclient::service"],
		require	=> Class["ddclient::package"],
	}
}


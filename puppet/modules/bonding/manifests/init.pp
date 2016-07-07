# puppet class to manage ethernet bonding

class bonding {
	include bonding::package
}

class bonding::package {
	$pkgs = $operatingsystem ? {
		CentOS	=> "iputils",
		default	=> "ifenslave",
	}

	package { $pkgs:
		ensure => installed
	}
}

# Only applicable to CentOS/RHEL - Debian/Ubuntu seem to do it automatically.
define bonding::module ( $interface = "bond0", $mode = 6, $interval = 100 ) {
	file { "/etc/modprobe.d/$interface.conf":
		ensure	=> file,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content	=> "# Managed by puppet on $servername - DO NOT EDIT HERE!
alias $interface bonding
options $interface miimon=$interval mode=$mode
",
	}
}

# Only applicable to CentOS/RHEL.
# WARNING: If you mess this up, you probably won't get the opportunity to fix it, because you'll be cut off from the system in question.
define bonding::ifcfg::slave ( $eth, $bond = "bond0" ) {
	file { "/etc/sysconfig/network-scripts/ifcfg-$eth":
		ensure	=> file,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content	=> "# Managed by puppet on $servername - DO NOT EDIT HERE!
DEVICE=$eth
BOOTPROTO=none
ONBOOT=yes
MASTER=$bond
SLAVE=yes
USERCTL=no
",
	}
}

# Only applicable to CentOS/RHEL.  Set VLAN to 0 to use the untagged interface.
# WARNING: If you mess this up, you probably won't get the opportunity to fix it, because you'll be cut off from the system in question.
# FIXME: IPv6
define bonding::ifcfg::vlan ( $vlan, $bootproto = "static", $ip, $netmask, $bond = "bond0", $comment = "" ) {
	$if = $vlan ? {
		0	=> "$bond",
		default	=> "$bond.$vlan",
	}
	$isvlan = $vlan ? {
		0	=> "no",
		default	=> "yes",
	}
	file { "/etc/sysconfig/network-scripts/ifcfg-$if":
		ensure	=> file,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content	=> "# Managed by puppet on $servername - DO NOT EDIT HERE!
# $comment
DEVICE=$if
BOOTPROTO=$bootproto
ONBOOT=yes
USERCTL=no
IPADDR=$ip
NETMASK=$netmask
VLAN=$isvlan
",
	}
}

# Only applicable to CentOS/RHEL.
define bonding::ifcfg::ppp ( $if = "ppp0", $eth, $username, $comment = "" ) {
	file { "/etc/sysconfig/network-scripts/ifcfg-$if":
		ensure	=> file,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content	=> "# Managed by puppet on $servername - DO NOT EDIT HERE!
# $comment
DEVICE=$if
ETH=$eth
NAME=DSL$if
PROVIDER=DSL$if
USER=$username

BOOTPROTO=dialup
CLAMPMSS=1412
CONNECT_POLL=6
CONNECT_TIMEOUT=0
DEFROUTE=yes
DEMAND=no
FIREWALL=NONE
LCP_FAILURE=3
LCP_INTERVAL=20
ONBOOT=yes
PEERDNS=no
PIDFILE=/var/run/pppoe-adsl.pid
PING=.
PPPOE_TIMEOUT=80
SYNCHRONOUS=no
TYPE=xDSL
USERCTL=no

",
	}
}


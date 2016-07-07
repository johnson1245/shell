# puppet class to configure SpamAssassin

class spamassassin {
	include spamassassin::package
	include spamassassin::service
	include spamassassin::ruleupdate
}

# install package
class spamassassin::package {
	$pkg = "spamassassin"
	package { $pkg:
		ensure		=> installed,
	}
}

# enable nightly rule updates
class spamassassin::ruleupdate {
	case $operatingsystem {
		centos: {
			cron_job { "spamassassin-rule-update":
				interval	=> daily,
				script		=> '#!/bin/sh
# Created by puppet - do not edit here
/usr/share/spamassassin/sa-update.cron
',
				require		=> Class["spamassassin::package"],	# I wonder if there's a way to set this once for the whole class...
			}
		}
		debian, ubuntu: {
			$file = "/etc/default/spamassassin"
			text::replace_lines { "$file CRON":
				file		=> $file,
				pattern		=> "^CRON=.*",
				replace		=> "CRON=1",
				optimise	=> true,
				require		=> Class["spamassassin::package"],	# I wonder if there's a way to set this once for the whole class...
			}
		}
	}
}

# enable service
class spamassassin::service {
	$svc = "spamassassin"
	service { $svc:
		enable		=> true,
		hasrestart	=> true,
		hasstatus	=> $operatingsystem ? {
			debian	=> false,
			ubuntu	=> false,
			centos	=> true,
			default	=> undef,
		},
		pattern		=> $operatingsystem ? {
			debian	=> spamd,
			ubuntu	=> spamd,
			default	=> undef,
		},
		require		=> Class["spamassassin::package"],	# I wonder if there's a way to set this once for the whole class...
	}
	case $operatingsystem {
		debian, ubuntu: {
			# on these operating systems, there is no standardised way to enable/disable a service :-(
			$file = "/etc/default/spamassassin"
			text::replace_lines { "$file ENABLE":
				file		=> $file,
				pattern		=> "^ENABLED=.*",
				replace		=> "ENABLED=1",
				optimise	=> true,
				notify		=> Service[$svc],
				require		=> Class["spamassassin::package"],	# I wonder if there's a way to set this once for the whole class...
			}
			# set the nice value on the daemon
			text::replace_add_line { "$file NICE":
				file		=> $file,
				pattern		=> '^#?NICE="--nicelevel .*"',
				line		=> 'NICE="--nicelevel 15"',
				notify		=> Service[$svc],
				require		=> Class["spamassassin::package"],	# I wonder if there's a way to set this once for the whole class...
			}
		}
	}
}

# this must be called to install a customised version of the spamassassin configuration
define spamassassin::config (
		$trusted_networks = [],
		$whitelist_from = []
		) {
	include spamassassin
	$templatedir = "/etc/puppet/modules/spamassassin/templates"
	$dir = $operatingsystem ? {
		centos		=> "/etc/mail/spamassassin",
		redhat		=> "/etc/mail/spamassassin",
		default		=> "/etc/spamassassin",
	}
	file { "$dir/local.cf":
		require		=> Class["spamassassin::package"],
		notify		=> Class["spamassassin::service"],
		ensure		=> file,
		owner		=> root,
		group		=> root,
		mode		=> 644,
		content		=> template("spamassassin/local.cf.erb"),
	}
}


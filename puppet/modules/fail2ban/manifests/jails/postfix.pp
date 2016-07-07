# Description:	fail2ban jail for postfix
# Author:	Paul Gear <puppet@libertysys.com.au>
# License:	GPLv3
# Copyright:	(c) 2010 Gear Consulting Pty Ltd <http://libertysys.com.au/>

class fail2ban::jails::postfix {
	fail2ban::jail { "postfix":
		port		=> 'smtp,ssmtp',
	}
	fail2ban::jail { "postfix-connection":
		findtime	=> 600,
		logpath		=> '/var/log/mail.log',
		maxretry	=> 5,
		port		=> 'smtp,ssmtp',
	}
	fail2ban::jail { "postfix-invalid-user":
		bantime		=> 43200,	# 12 hours
		findtime	=> 3600,
		logpath		=> '/var/log/mail.log',
		maxretry	=> 2,
		port		=> 'smtp,ssmtp',
	}
	fail2ban::jail { "postfix-postgrey":
		findtime	=> 3600,
		logpath		=> '/var/log/mail.log',
		maxretry	=> 5,
		port		=> 'smtp,ssmtp',
	}
	fail2ban::jail { "postfix-sasl":
		findtime	=> 3600,
		logpath		=> '/var/log/mail.log',
		maxretry	=> 3,
		port		=> 'smtp,ssmtp',
	}
	# remove old jail
	fail2ban::jail { "postfix-sasl-auth-failure":
		ensure		=> absent,
	}
}

class fail2ban::jails::postfix::unverified {
	fail2ban::jail { "postfix-unverified-address":
		ensure		=> absent,
	}
	fail2ban::jail { "postfix-unverified":
		findtime	=> 300,
		logpath		=> '/var/log/mail.log',
		maxretry	=> 3,
		port		=> 'smtp,ssmtp',
	}
}

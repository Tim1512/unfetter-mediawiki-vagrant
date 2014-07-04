# == Class: misc
#
# Provides various small enhancements to user experience: a color
# prompt, a helpful MOTD banner, bash aliases, and some commonly-used
# command-line tools, like 'ack' and 'curl'.
#
class misc {
    # This solves the 'stdin: not a tty' error message, which is caused
    # by a call to 'mesg n' in /root/.profile. Sadly it'll still appear
    # once, since profile is sourced before Puppet can run. That sucks,
    # because first impressions do count. Fix it and you get a cookie.
    exec { 'update profile':
        command => 'sed -i -e "s/^mesg n/tty -s \&\& mesg n/" /root/.profile',
        onlyif  => 'grep -q "^mesg n" /root/.profile',
    }

    file { [ '/var/lib/cloud', '/var/lib/cloud/instance' ]:
        ensure => directory,
    }

    file { '/var/lib/cloud/instance/locale-check.skip':
        ensure => present,
    }

    env::profile {
        'local':
            source => 'puppet:///modules/misc/locale.sh';
        'color':
            source => 'puppet:///modules/misc/color.sh';
        'check mediawiki-vagrant':
            source => 'puppet:///modules/misc/check-mediawiki-vagrant.sh';
    }

    # Setting up $GEM_HOME relative to $HOME was removed in favor of using
    # rbenv to isolate rubies and bundler to isolate gems
    env::profile { 'gem home':
        ensure => absent,
    }

    file { [
        '/etc/update-motd.d/10-help-text',
        '/etc/update-motd.d/50-landscape-sysinfo',
        '/etc/update-motd.d/51-cloudguest'
    ]:
        ensure => absent,
    }

    file { '/etc/logrotate.d/mediawiki-vagrant':
        source => 'puppet:///modules/misc/mediawiki-vagrant.logrotate',
    }

    file { '/usr/sbin/check_service_freshness':
        source => 'puppet:///modules/misc/check_service_freshness',
        mode   => '0755',
    }

    file { '/etc/update-motd.d/60-mediawiki-vagrant':
        ensure  => present,
        mode    => '0755',
        source  => 'puppet:///modules/misc/60-mediawiki-vagrant',
        notify  => Exec['update motd'],
    }

    exec { 'update motd':
        command     => 'run-parts --lsbsysinit /etc/update-motd.d > /run/motd',
        refreshonly => true,
    }

    # Small, nifty, useful things
    package { [ 'ack-grep', 'htop', 'curl' ]:
        ensure => present,
    }

    file { '/home/vagrant/.ackrc':
        ensure  => present,
        replace => false,
        owner   => 'vagrant',
        source  => 'puppet:///modules/misc/ackrc',
    }

    file { '/home/vagrant/.bash_aliases':
        ensure => present,
        mode   => '0755',
        source => 'puppet:///modules/misc/bash_aliases',
    }
}

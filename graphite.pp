# Standalone graphite server build manifest
# Vagrant puppet master (change ip to suite your environment)
host {'puppet':
  ensure => present,
  name   => 'puppet',
  ip     => '192.168.3.10',
}

# Node repositories
yumrepo {'epel-nodejs':
  descr    => 'node.js stack in development: runtime and several npm packages',
  baseurl  => 'http://repos.fedorapeople.org/repos/lkundrak/nodejs/epel-$releasever/$basearch/',
  enabled  => 1,
  gpgcheck => 0,
}

yumrepo {'epel-nodejs-sources':
  descr    => 'node.js stack in development: runtime and several npm packages - Source',
  baseurl  => 'http://repos.fedorapeople.org/repos/lkundrak/nodejs/epel-$releasever/SRPMS/',
  enabled  => 0,
  gpgcheck => 0,
}

# EPEL repositories
package {'epel-release':
  ensure   => installed,
  source   => 'http://mirror.symnds.com/distributions/fedora-epel/6/i386/epel-release-6-8.noarch.rpm',
  provider => rpm,
}
yumrepo {'epel':
  descr          => 'Extra Packages for Enterprise Linux 6 - $basearch',
  mirrorlist     => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
  failovermethod => priority,
  enabled        => 1,
  gpgcheck       => 1,
  gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6',
}
yumrepo {'epel-debuginfo':
  descr          => 'Extra Packages for Enterprise Linux 6 - $basearch - Debug',
  mirrorlist     => 'https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch',
  failovermethod => priority,
  enabled        => 0,
  gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6',
  gpgcheck       => 1,
}
yumrepo {'epel-source':
  descr          => 'Extra Packages for Enterprise Linux 6 - $basearch - Source',
  mirrorlist     => 'https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch',
  failovermethod => priority,
  enabled        => 0,
  gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6',
  gpgcheck       => 1,
}

# Packages available via EPEL
package {['mod_python',
          'mod_wsgi',
          'Django',
          'django-tagging',
          'python-twisted',
          'python-simplejson',
          'python-txamqp',
          'pycairo',
          'python-ldap',
          'python-memcached',
          'python-sqlite2',
          'httpd',
          'httpd-tools',
          'mod_ssl',
          'apr',
          'apr-util',
          'apr-util-ldap',
          'memcache',
          'bitmap',
          'bitmap-fonts']:
  ensure => installed,
}

# Packages for Statsd
package {'zlib-static':
  ensure => installed,
# available from nodejs repository/channel
package {'nodejs':
  ensure => installed,
}
package {'nodejs-express':
  ensure => installed,
}

# Graphite's Meat & Taters
package {['graphite-web','python-whisper','python-carbon']:
  ensure => installed,
}
# TODO: Create augeas lenses for /etc/carbon/storage-schemas.conf
#  Cribbed from http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas
#  Usage:
#  graphite::carbon::schema {'1min_for_1day':
#    priority   => 0,
#    pattern    => '^carbon\.',
#    retentions => '60s:1d',
#  }
#define graphite::carbon::schema ( $name = $title, $priority, $retentions, $pattern ) {
#  # include graphite
#  # include graphite::params
#  $key = "$name/$pattern/$retention"
#  $confdir = $::graphite::carbon::params::confdir
#  $context = "files/${::graphite::carbon::params::confdir}/storage-schemas.conf"
#  $path_list = "name[.=\"${name}\"][./pattern=\"${pattern}\" and ./retentions=\"${retentions}\"]"
#  $path_exact = "name[.=\"${name}\"][./pattern=\"${pattern}\" and ./retentions=\"${retentions}\"]"
#
#  augeas {"carbon/$key":
#    context => $context,
#    onlyif  => "match $path_exact size != 1",
#    changes => [
#      "set dir[last()]/name $name",
#      "set dir[last()]/pattern $pattern",
#      "set dir[last()]/retentions $retentions",
#    ],
#  }
#}

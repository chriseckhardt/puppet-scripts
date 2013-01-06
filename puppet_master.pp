# Quick stand-alone for vagrant CentOS 6 puppet masters
# Puppet Labs Repositories
package {'puppetlabs-release':
  ensure   => installed,
  source   => 'http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm',
  provider => rpm,
}
yumrepo {'puppetlabs-products':
  descr    => 'Puppet Labs Products El 6 - $basearch',
  baseurl  => 'http://yum.puppetlabs.com/el/6/products/$basearch',
  gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  enabled  => 1,
  gpgcheck => 1,
}
yumrepo {'puppetlabs-deps':
  descr    => 'Puppet Labs Dependencies El 6 - $basearch',
  baseurl  => 'http://yum.puppetlabs.com/el/6/dependencies/$basearch',
  gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  enabled  => 1,
  gpgcheck => 1,
}
yumrepo {'puppetlabs-devel':
  descr    => 'Puppet Labs Devel El 6 - $basearch',
  baseurl  => 'http://yum.puppetlabs.com/el/6/devel/$basearch',
  gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  enabled  => 0,
  gpgcheck => 1,
}
yumrepo {'puppetlabs-products-source':
  descr          => 'Puppet Labs Products El 6 - $basearch - Source',
  baseurl        => 'http://yum.puppetlabs.com/el/6/products/SRPMS',
  gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  failovermethod => priority,
  enabled        => 0,
  gpgcheck       => 1,
}
yumrepo {'puppetlabs-deps-source':
  descr    => 'Puppet Labs Source Dependencies El 6 - $basearch - Source',
  baseurl  => 'http://yum.puppetlabs.com/el/6/dependencies/SRPMS',
  gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  enabled  => 0,
  gpgcheck => 1,
}
yumrepo {'puppetlabs-devel-source':
  descr    => 'Puppet Labs Devel El 6 - $basearch - Source',
  baseurl  => 'http://yum.puppetlabs.com/el/6/devel/SRPMS',
  gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  enabled  => 0,
  gpgcheck => 1,
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

# Puppet, puppet-server, hiera
package {['puppet',
          'puppet-server',
          'hiera',
          'rubygem-json']:
  ensure => latest,
}

# Apache proxy packages
package {['httpd',
          'httpd-devel',
          'mod_ssl',
          'ruby-devel',
          'rubygems',
          'rubygem-rack',
          'rubygem-passenger',
          'mod_passenger']:
  ensure => latest,
}

# configure the things
file {'/etc/puppet/puppet.conf':
  ensure => file,
  owner  => 'puppet',
  mode   => '0640',
  notify => Service['puppetmaster'],
}

host {'puppet':
  ensure       => present,
  name         => 'puppet',
  host_aliases => ['localhost','localhost.localdomain',
    'localhost4','localhost4.localdomain4'],
  ip           => '127.0.0.1',
}

# Run the things
service {'puppetmaster':
  ensure  => running,
  require => Package['puppet-server'],
}

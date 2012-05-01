class zfs {

  include zfs::scrubber

  case $::operatingsystem {
    'FreeBSD': {
      package{ 'sysutils/zfs-stats': ensure => present, }
    }
    'Solaris': {
      # Yes, I am installing them in /usr/sbin/ because Solaris doesn't
      # have a /usr/local by default, nor does it's $PATH for things.
      file{
        '/usr/sbin/arc_summary.pl':
          ensure => present,
          mode   => '0755',
          owner  => 'root',
          source => 'puppet:///modules/zfs/arc_summary.pl';
        '/usr/sbin/arcstat.pl':
          ensure => present,
          mode   => '0755',
          owner  => 'root',
          source => 'puppet:///modules/zfs/arcstat.pl',
      }
    }
    default: { fail( "Sorry, ZFS isn't done for ${::operatingsystem}." ) }
  }

}

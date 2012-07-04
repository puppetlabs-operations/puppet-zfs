class zfs {

  include zfs::scrubber

  case $::operatingsystem {
    'FreeBSD': {
      package{ 'sysutils/zfs-stats' :}
      service{ 'zfs':
        enable => true,
      }
    }
    'Solaris': {
      file{
        '/usr/local/sbin/arc_summary.pl':
          ensure => present,
          mode   => '0755',
          owner  => 'root',
          source => 'puppet:///modules/zfs/arc_summary.pl';
        '/usr/local/sbin/arcstat.pl':
          ensure => present,
          mode   => '0755',
          owner  => 'root',
          source => 'puppet:///modules/zfs/arcstat.pl',
      }
    }
    default: { fail( "Sorry, ZFS isn't done for ${::operatingsystem}." ) }
  }

}

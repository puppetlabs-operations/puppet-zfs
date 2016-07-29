# Provide the zfs python library and scripts for supporting send/recv
class zfs::pip (
  $ensure  = latest,
  $repo    = undef,
  $include = false,
) {
  if $include == true {
    python::pip { 'zfs':
      ensure       => $ensure,
      install_args => $repo,
    }
  } else {
    file { '/usr/local/bin/zfs_snapshot':
      owner  => 'root',
      group  => 'root',
      mode   => '0555',
      source => 'puppet:///modules/zfs/zfs_snapshot.py',
    }
  }
}

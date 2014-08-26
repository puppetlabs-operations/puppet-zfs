class zfs::vol::get_quota {

  file { '/usr/bin/zfs_get_quota':
    source => 'puppet:///modules/zfs/zfs_get_quota',
    owner  => 'root',
    group  => '0',
    mode   => '0750'
  }
}

class zfs::vol::get_share {

  file { '/usr/bin/zfs_get_share':
    source => 'puppet:///modules/zfs/zfs_get_share',
    owner  => 'root',
    group  => '0',
    mode   => '0750'
  }
}

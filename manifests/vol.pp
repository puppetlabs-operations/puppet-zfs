# Create zfs volumes within a parent volume
define zfs::vol (
  $parent = undef,
  $path   = '/usr/bin:/usr/sbin',
  $quota  = undef
) {

  if $parent {
    $vol_name = "$parent/$title"
  }
  else {
    $vol_name = $title
  }

  $create_zfs_vol = "zfs create $vol_name"
  $set_zfs_quota  = "zfs set quota=$quota $vol_name"

  Exec {
    path => $path
  }

  exec { $create_zfs_vol:
    unless => "ls /$vol_name"
  }

  if $quota {
    include zfs::vol::get_quota
    exec { $set_zfs_quota:
      unless  => "zfs_get_quota $vol_name $quota",
      require => [ Exec[$create_zfs_vol], Class[zfs::vol::get_quota] ]
    }
  }
}

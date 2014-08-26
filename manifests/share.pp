# A class for managing ZFS shares
define zfs::share (
  $parent    = undef,
  $path      = '/usr/bin:/usr/sbin',
  $share_nfs = 'true',
  $share
) {

  if $parent {
    $vol_name = "$parent/$title"
  }
  else {
    $vol_name = $title
  }

  $set_zfs_share = "zfs set share=\"$share\" $vol_name"

  Exec {
    path => $path
  }

  if ( $share_nfs == 'true' ) {

    include zfs::vol::get_share

    zfs { $vol_name:
      sharenfs => 'on'
    }

    exec { $set_zfs_share:
      unless  => "zfs_get_share $vol_name $share",
      require => [ Zfs[$vol_name], Class[zfs::vol::get_share] ]
    }
  }
  else {
    zfs { $vol_name:
      sharenfs => 'off'
    }
  }
}

# A class for managing ZFS shares
define zfs::share (
  $share,
  $parent    = undef,
  $path      = '/usr/bin:/usr/sbin',
) {

  if $parent {
    $vol_name = "${parent}/${title}"
  }
  else {
    $vol_name = $title
  }

  $set_zfs_share = "zfs set share=\"${share}\" ${vol_name}"

  include zfs::vol::get_share

  exec { $set_zfs_share:
    unless  => "zfs_get_share ${vol_name} ${share}",
    path    => $path,
    require => [ Zfs[$vol_name], Class[zfs::vol::get_share] ]
  }
}

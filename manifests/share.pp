# A class for managing ZFS shares
define zfs::share (
# $share,
# $parent      = undef,
  $ensure      = present,
  $allow_ip    = undef,
  $full_share  = undef,
  $share_title = undef,
  $protocol    = 'nfs',
  $security    = [ 'sys', 'default', 'none' ],
  $permissions = 'rw',
  $zpool       = undef,
  $zvol        = $title,
  $path        = '/usr/bin:/usr/sbin',
) {

  include zfs::vol::get_share

  if $zpool {
    $vol_name = "${zpool}/${zvol}"
  }
  else {
    $vol_name = $zvol
  }

  if $share_title {
    $share_name = $share_title
  }
  else {
    $share_name = "${zpool}_${zvol}"
  }

  if ( is_array($allow_ip) ) {
    $addresses = inline_template("<%= allow_ip.join(':@') %>")
  }
  else {
    $addresses = $allow_ip
  }

  # Build commands
  $share_base   = "name=${share_name},path=/${vol_name}"
  $share_prot   = "prot=${protocol}"
  $share_sec    = "sec=${security}"
  $share_perm   = "${permissions}=@${addresses}"
  $base_command = "${share_base},${share_prot}"

  if ( is_array($security) ) {
    case $security {
      /(?=(.*sys))(?=(.*default))/: {
        $share_command = "${base_command},sec=sys,${share_perm},sec=default,${share_perm}"
      }
      /(?=(.*sys))(?=(.*none))/: {
        $share_command = "${base_command},sec=sys,${share_perm},sec=none,${share_perm}"
      }
      /(?=(.*default))(?=(.*none))/: {
        $share_command = "${base_command},sec=default,${share_perm},sec=none,${share_perm}"
      }
      /(?=(.*sys))(?=(.*default))(?=(.*none))/: {
        $share_command = "${base_command},sec=sys,${share_perm},sec=default,${share_perm},sec=none,${share_perm}"
      }
    }
  }
  else {
    $share_command = "${base_command},${share_sec},${share_perm}"
  }

  if ( $full_share == undef ) {
    $share = $share_command
  }
  else {
    $share = $full_share
  }

  $unset_zfs_share = "zfs set -c share=${share_name} ${vol_name}"
  $set_zfs_share   = "zfs set share=${share} ${vol_name}"

  if ! defined(Zfs[$vol_name]) {
    zfs { $vol_name:
      sharenfs => 'on',
    }
  }

  Exec {
    unless => "zfs_get_share ${vol_name} ${share}",
    path   => $path,
    require => [ Zfs[$vol_name], Class[zfs::vol::get_share] ],
  }

  case $ensure {
    absent: {
      exec { $unset_zfs_share: }
    }
    default: {
      exec {
        $unset_zfs_share:;
        $set_zfs_share:
          require => Exec[$unset_zfs_share]
      }
    }
  }
}

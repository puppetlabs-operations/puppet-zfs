# A class for managing ZFS shares
define zfs::share (
  $allow_ip,
  $ensure      = present,
  $zpool       = undef,
  $full_share  = undef,
  $share_title = undef,
  $zvol        = $title,
  $protocol    = 'nfs',
  $permissions = 'rw',
  $security    = [ 'sys', 'default', 'none' ],
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

  if ( is_array($protocol) ) {
    case $protocol {
      /(?=(.*nfs))(?=(.*smb))/: {
        $share_prot = 'prot=nfs,prot=smb'
      }
      default: {
        fail( '$protocol array is invalid' )
      }
    }
  }
  else {
    $share_prot = "prot=${protocol}"
  }

  # Build commands
  $set_share    = 'zfs set share'
  $unset_share  = 'zfs set -c share'
  $share_base   = "name=${share_name},path=/${vol_name}"
  $share_sec    = "sec=${security}"
  $share_perm   = "${permissions}=@${addresses}"
  $base_command = "${share_base},${share_prot}"

  if ( is_array($security) ) {
    case $security {
      /(?=(.*sys))(?=(.*default))(?=(.*none))/: {
        $share_command = "${base_command},sec=sys,${share_perm},sec=default,${share_perm},sec=none,${share_perm}"
      }
      /(?=(.*sys))(?=(.*default))/: {
        $share_command = "${base_command},sec=sys,${share_perm},sec=default,${share_perm}"
      }
      /(?=(.*sys))(?=(.*none))/: {
        $share_command = "${base_command},sec=sys,${share_perm},sec=none,${share_perm}"
      }
      /(?=(.*default))(?=(.*none))/: {
        $share_command = "${base_command},sec=default,${share_perm},sec=none,${share_perm}"
      }
      default: {
        fail('Security array is invalid')
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

  $unset_zfs_share = "${unset_share}=${share_base} ${vol_name}"
  $set_zfs_share   = "${set_share}=${share} ${vol_name}"

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

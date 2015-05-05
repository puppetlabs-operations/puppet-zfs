# A class for managing ZFS shares
define zfs::share (
  $ensure         = present,
  $allow_ip_read  = undef,
  $allow_ip_write = undef,
  $security_read  = undef,
  $security_write = undef,
  $zpool          = undef,
  $full_share     = undef,
  $share_title    = undef,
  $zvol           = $title,
  $protocol       = 'nfs',
  $permissions    = 'rw',
  $security       = [ 'sys', 'default', 'none' ],
  $path           = '/usr/bin:/usr/sbin',
) {

  if $allow_ip_read {
    if is_array($allow_ip_read) {
      $allow_ip_read_join = join($allow_ip_read, ':@')
      $allow_ips_read = "@${allow_ip_read_join}"
    }
    else {
      $allow_ips_read = "@${allow_ip_read}"
    }
  }

  if $allow_ip_write {
    if is_array($allow_ip_write) {
      $allow_ip_write_join = join($allow_ip_write, ':@')
      $allow_ips_write = "@${allow_ip_write_join}"
    }
    else {
      $allow_ips_write = "@${allow_ip_write}"
    }
  }

  if $security_read {
    if $allow_ip_read {
      if is_array($security_read) {
        each($security_read) |$s| {
          if $s =~ /^(sys|default|none)$/ {
            exec { "zfs set share ${s}":
              


  zfs set share.nfs.sec.none.ro="@10.32.22.32/32" target
  zfs set share.nfs.sec.none.ro="@10.32.22.32/32" target

  include zfs::vol::get_share

  if ( is_array($permissions) ) {
    fail( 'An array of permissions is not supported' )
  }

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
    case $zpool {
      undef: {
        $share_name = regsubst($vol_name, '/', '_')
      }
      /\//: {
        $zpool_split = inline_template("<%= @zpool.split('/').join('_') %>")
        $share_name  = $zpool_split
      }
      default: {
        $share_name = "${zpool}_${zvol}"
      }
    }
  }

  if ( is_array($allow_ip) ) {
    $addresses = join($allow_ip, ':@')
  }
  else {
      case $allow_ip {
        /(^\*$)/: {
          $addresses = '*'
        }
        default: {
          $addresses = "@${allow_ip}"
          }
        }
      }

  if ( is_array($protocol) ) {
    case $protocol {
      /(?=(.*nfs))(?=(.*smb))/: {
        $share_prot     = 'prot=nfs'
        $share_prot_smb = ",prot=smb,guestok=true,${permissions}=*"
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
  $share_perm   = "${permissions}=${addresses}"
  $base_command = "${share_base},${share_prot}"
  $sec_sys      = "sec=sys,${share_perm}"
  $sec_default  = "sec=default,${share_perm}"
  $sec_none     = "sec=none,${share_perm}"

  if ( is_array($security) ) {
    case $security {
      /(?=(.*sys))(?=(.*default))(?=(.*none))/: {
        $share_command = "${base_command},${sec_sys},${sec_default},${sec_none}"
      }
      /(?=(.*sys))(?=(.*default))/: {
        $share_command = "${base_command},${sec_sys},${sec_default}"
      }
      /(?=(.*sys))(?=(.*none))/: {
        $share_command = "${base_command},${sec_sys},${sec_none}"
      }
      /(?=(.*default))(?=(.*none))/: {
        $share_command = "${base_command},${sec_default},${sec_none}"
      }
      default: {
        fail('Security array is invalid')
      }
    }
  }
  else {
    $share_command = "${base_command},${share_sec},${share_perm}${share_prot_smb}"
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

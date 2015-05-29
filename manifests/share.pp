# A class for managing ZFS shares
define zfs::share (
  $allow_ip    = undef,
  $ensure      = present,
  $zpool       = undef,
  $full_share  = undef,
  $share_title = undef,
  $zvol        = $title,
  $protocol    = 'nfs',
  $permissions = 'rw',
  $security    = [ 'sys', 'default', 'none' ],
  $path        = '/usr/bin:/usr/sbin',
  $purge       = false
) {

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
    case $vol_name {
      /\//: {
        $share_name = regsubst($vol_name, '/', '_', 'G')
      }
      default: {
        $share_name = $vol_name
      }
    }
  }

  if ( is_array($allow_ip) ) {
    $addresses = inline_template("@<%= allow_ip.join(':@') %>")
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

  if $full_share {
    $share = $full_share
  }
  else {
    $share = $share_command
  }

  $unset_zfs_share = "${unset_share}=${share_base} ${vol_name}"
  $set_zfs_share   = "${set_share}=${share} ${vol_name}"

  if ( $full_share or $allow_ip ) {

    Exec {
      unless => "zfs_get_share ${vol_name} ${share}",
      path   => $path,
      require => File['/usr/bin/zfs_get_share']# Comes from get_share class
    }

    case $ensure {
      absent: {
        exec { $unset_zfs_share: }
      }
      default: {
        if $purge {
          exec {
            $unset_zfs_share:;
            $set_zfs_share:
              require => Exec[$unset_zfs_share]
          }
        }
        else {
          exec { $set_zfs_share: }
        }
      }
    }
  }
  else {
    warn('No ip has been set via allow_ip or full_share, so no share will be set')
  }
}

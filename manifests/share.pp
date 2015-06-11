# A class for managing ZFS shares
define zfs::share (
  $ensure                = present,
  $destructive           = false,
  $zvol                  = $title,
  $protocol              = 'nfs',
  $security              = [ 'sys', 'default', 'none' ],
  $path                  = '/usr/bin:/usr/sbin',
  $allow_ip_read         = undef,
  $allow_ip_write        = undef,
  $zpool                 = undef,
  $full_share            = undef,
  $share_title           = undef,
  $anon_user_id          = undef,
  $nosub                 = undef
) {

  include zfs::vol::get_share

  if $zpool {
    $vol_name = "${zpool}/${zvol}"
  } else {
    $vol_name = $zvol
  }

  if $share_title {
    $share_name = $share_title
  } else {
    $share_name = regsubst($vol_name, '/', '_', 'G')
  }

  if $allow_ip_read {
    $allow_ips_read_a = any2array($allow_ip_read)
    $allow_ips_read_j = join($allow_ips_read_a, ':@')
    $allow_read_cmd = "ro=@${allow_ips_read_j}"
  }

  if $allow_ip_write == '*' {
    $allow_ips_write = $allow_ip_write
  }
  elsif $allow_ip_write {
    $allow_ips_write_a = any2array($allow_ip_write)
    $allow_ips_write_j = join($allow_ips_write_a, ':@')
    $allow_ips_write   = "@${allow_ips_write_j}"
  }

  if $allow_ips_write {
    $allow_write_cmd = "rw=${allow_ips_write}"
  }

  if ( is_array($protocol) ) {
    case $protocol {
      /(?=(.*nfs))(?=(.*smb))/: {
        $share_prot     = 'prot=nfs'
        $share_prot_smb = ',prot=smb,guestok=true,rw=*'
      }
      default: {
        fail( '$protocol array is invalid' )
      }
    }
  }
  else {
    $share_prot = "prot=${protocol}"
  }

  if $anon_user_id {
    $anon_user = "anon=${anon_user_id}"
  }

  if $nosub {
    $nosub_c = 'nosub=true'
  }

  # Build commands
  $set_share    = 'zfs set share'
  $unset_share  = 'zfs set -c share'
  $share_base   = "name=${share_name},path=/${vol_name}"
  $share_sec    = "sec=${security}"
  $share_perm   = "rw=${allow_ips_write}"
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
    $share_base_a = [
      $share_base,
      $share_prot,
      $anon_user,
      $nosub_c,
      $share_sec,
      $allow_read_cmd,
      $allow_write_cmd,
      $share_prot_smb
    ]
    $share_remove_e = delete_undef_values($share_base_a)
    $share_command  = join($share_remove_e, ',')
  }

  if $full_share {
    $share = $full_share
  } else {
    $share = $share_command
  }

  $unset_zfs_share = "${unset_share}=name=${share_name} ${vol_name}"
  $set_zfs_share   = "${set_share}=${share} ${vol_name}"

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
      if $destructive {
        exec {
          $unset_zfs_share:;
          $set_zfs_share:
            require => Exec[$unset_zfs_share]
        }
      } else {
        exec { $set_zfs_share: }
      }
    }
  }
}

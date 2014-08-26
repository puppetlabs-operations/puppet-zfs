# Define type for creating snapshots on specific volumes at a specified time
define zfs::snapshot (
  $hour   = '1',
  $minute = '0',
  $rhour  = '1',
  $rmin   = '4',
  $zfs    = '/usr/sbin/zfs',
  $rotate = 'true',
  $keep   = '8',
  $user   = 'root',
  $target   #path before title
) {

  $date     = '$(/usr/bin/date +\%Y-\%m-\%d-\%H-\%M)'
  $snapshot = "$zfs snapshot $target/$title@$date"

  cron { "$title-snapshot":
    command => $snapshot,
    user    => 'root',
    hour    => $hour,
    minute  => $minute
  }

  if ( $rotate == 'true' ) {
    zfs::rotate { "$target/$title":
      rotate_hour   => $rhour,
      rotate_minute => $rmin,
      keep          => $keep,
      user          => $user,
    }
  }
}

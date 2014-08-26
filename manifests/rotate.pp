# Define for rotating ZFS snapshots
define zfs::rotate (
  $rotate_hour   = '0',
  $rotate_minute = '1',
  $zfs           = '/usr/sbin/zfs',
  $xargs         = '/usr/bin/xargs',
  $tac           = '/usr/bin/tac',
  $grep          = '/usr/bin/grep',
  $tail          = '/usr/bin/tail',
  $user          = 'root',
  $keep,
  $target        = $title
) {

  $list_snapshot = "$zfs list -r -t snapshot -o name $target"

  $rotate_snapshot = "$list_snapshot | $tac | $grep -iv name | $tail +$keep | $xargs -L 1 zfs destroy"

  cron { "$title-rotate-snapshot":
    command => $rotate_snapshot,
    user    => $user,
    hour    => $rotate_hour,
    minute  => $rotate_minute
  }
}

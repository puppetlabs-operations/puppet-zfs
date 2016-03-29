# Provide a interface for scheduling zfs scrub operations
define zfs::scrub (
  $month    = undef,
  $monthday = 15,
  $hour     = 0,
  $minute   = 0
) {
  cron { "${name}_scrub":
    command  => "/usr/sbin/zpool scrub ${name}",
    user     => 'root',
    month    => $month,
    monthday => $monthday,
    hour     => $hour,
    minute   => $minute
  }
}

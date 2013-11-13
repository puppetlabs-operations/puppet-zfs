class zfs::scrubber {

  cron { 'zfs_scrubber':
    command     => 'for x in $( zpool list -H | cut -f 1 ); do zpool scrub "${x}" ; done',
    user        => 'root',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
    hour        => '3',
    minute      => '33',
    weekday     => '6',
  }
}

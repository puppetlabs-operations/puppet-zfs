# Define type for creating snapshots on specific volumes at a specified time
define zfs::snapshot (
  $target,  #path before title
  $hour   = '1',
  $minute = '0',
  $rhour  = '1', #toremove
  $rmin   = '4', #toremove
  $zfs    = '/usr/sbin/zfs', #toremove
  $path   = '/usr/local/bin',
  $rotate = true,
  $keep   = '8',
  $user   = 'root',
) {

  include ::zfs::pip

  $volume = "${target}/${title}"
  $snap = "${path}/zfs_snapshot --volume ${volume}"
  if $rotate {
    $rotation = "--keep ${keep}"
    $command  = join([$snap, $rotation], ' ')
  } else {
    $command = $snap
  }

  cron { "${title}-snapshot":
    command     => $command,
    user        => 'root',
    hour        => $hour,
    minute      => $minute,
  }
}

#!/usr/bin/env python
"""
Create and rotate zfs snapshots
"""

import subprocess
import time
import argparse
import os
import sys
import glob


def str2bool(v):
    return str(v.lower()) in ("yes", "true", "t", "1")

def get_args():
    """
    Get arguments
    """
    parse = argparse.ArgumentParser(description='ZFS snapshot helper')
    parse.register('type', 'bool', str2bool)
    parse.add_argument('-V', '--volume',
                       help='Volume to create snapshot for',
                       required=True,
                       type=str)
    parse.add_argument('-k', '--keep',
                       help='Rotate any snapshots beyond this number',
                       type=int)
    parse.add_argument('-t', '--snapshot_title',
                       help='Snapshot title. Defaults to local date/time.',
                       type=str)
    parse.add_argument('-S', '--take_snapshot',
                       help='Enable or disable snapshot creation. Default: True',
                       action='store',
                       type=bool,
                       default=True)

    args = parse.parse_args()
    return args

def maintenance_mode():
    home = os.environ['HOME']
    file_exists = os.path.isfile('{}/.maintenance_mode'.format(home))
    if file_exists:
        return True
    else:
        return False

def take_snapshot(volume, title=None):
    """
    Create a zfs snapshot with todays date
    """
    if title:
        title = title
    else:
        title = time.strftime("%Y-%m-%d-%H-%M", time.localtime())
    snapshot_title = volume + '@' + title
    devnull = open(os.devnull, 'r+b', 0)
    snapshot = subprocess.call(['/usr/sbin/zfs', 'snapshot', snapshot_title], stdout=devnull, stderr=devnull)
    if snapshot == 0:
        return True
    else:
        return False

def rotate_snapshot(volume, keep):
    """
    Rotate snapshots. Keep the number specified in keep.

    This rotates snapshots above the number in keep. It determines this based on the count provided.
    """
    output = subprocess.check_output(['/usr/sbin/zfs', 'list', '-r', '-t', 'snapshot', '-o', 'name', volume])
    if output:
        snapshots = output.strip().split('\n')[1:]
        snapshots.reverse()
        to_remove = snapshots[keep:]
        if len(to_remove):
            for snapshot in to_remove:
                subprocess.check_output(['/usr/sbin/zfs', 'destroy', snapshot])
            return 'Destroyed {} snapshots'.format(len(to_remove))
        else:
            return False
    else:
        return False

def check_sync(volume, tries=4320):
    attempts = 0
    while attempts < tries:
        if len(glob.glob('/{}/*.lock'.format(volume))):
            attempts = attempts + 1
            time.sleep(10)
        else:
            return False
    print 'Gave up after {} attempts'.format(attempts)
    return True

def main():
    args = get_args()
    if maintenance_mode():
        sys.exit(1)
    if check_sync(args.volume):
        sys.exit(2)
    if args.take_snapshot:
        if take_snapshot(args.volume, args.snapshot_title):
            print 'Created snapshot'
    if args.keep >= 0:
        rotate = rotate_snapshot(args.volume, args.keep)
        if rotate:
            print rotate

if __name__ == '__main__':
    main()

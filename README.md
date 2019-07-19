# manageBE - Manage ZFS-based Boot Environments for FreeBSD 8

Original code by cryx:
<http://anonsvn.h3q.com/projects/freebsd-patches/browser/manageBE> (Link
defunct.)  This code can be found in the `manageBE` file.

Modifications (bug fixes, inherited properties, space usage reporting) by
me, available in the manageBE.new file for comparison.

cryx' code was written for FreeBSD 8, and I started using it around the time of
FreeBSD 8.2 in late 2011; at least I think, memory is a bit hazy!  It was about
six months earlier than the creation of
[`beadm`](https://www.freshports.org/sysutils/beadm/) if I remember correctly.
Once I discovered `beadm` in January 2013 I switched to it, thus rendering this
script obsolete for my use.

One thing I did like about `manageBE` was its ability to automate FreeBSD
patching and upgrades.  After I stopped using `manageBE` I wrote an
alternative, `beupdate`, which can be found in its own repo.

Also included in this repo is the script that I originally used to set up my
server in a way that would be compatible with `manageBE`: `setupzfs.sh`.  It
was modified for FreeBSD 9.0: `setupzfsbe9.sh`.  Further modifications were
made once I switched to `beadm`: `setupzfsbe9-new.sh`.  It was split off into
its own repo for further development in January 2013.


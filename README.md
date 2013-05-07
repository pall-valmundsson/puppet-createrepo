# createrepo module #

[![Build Status](https://travis-ci.org/pall-valmundsson/puppet-createrepo.png)](https://travis-ci.org/pall-valmundsson/puppet-createrepo)

# What it is and what it isn't #

This is module creates yum repositories and metadata caches.
It also manages a cronjob to update the repodata.

It *doesn't*:
- manage the directoy tree up to the root of the repository
- manage a HTTP server for repository clients

# Example #

```
createrepo { 'yumrepo':
    repository_dir => '/var/yumrepos/yumrepo',
    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
}
```

# Status #
Beta. Tested on CentOS/RHEL 6 with Puppet 2.7.

# Regarding checksums #
Older versions of yum do not support some later default checksum types. From the ```createrepo``` man page:
```
Choose  the  checksum  type used in repomd.xml and for packages in the metadata.  The default is now
"sha256" (if python has hashlib). The older default was "sha", which is actually "sha1", however explicitly
using "sha1" doesn’t work on older (3.0.x) versions of yum, you need to specify "sha".
```
```createrepo``` provides a checksum_type parameter to change the checksum type.

# Parameters #

repository_dir
--------------
The path to the base directory of the repository. Here, or in subdirectories
you store the .rpm files

- *Default*: ```/var/yumrepos/${name}```

repo_cache_dir
--------------
Path to a checksum directory. Makes updates to repository much faster.
- *Default*: ```/var/cache/yumrepos/${name}```

repo_owner
----------
Owner of the repository directory.
- *Default*: ```root```

repo_group
----------
Group of the repository directory.
- *Default*: ```root```

cron_minute
-----------
Minute parameter for cron metadata update job.
- *Default*: ```*/1```

cron_hour
---------
Hour parameter for cron metadata update job.
- *Default*: ```*```

checksum_type
-------------
Sets the checksum type for repomd.xml. This needs to be set to ```sha``` if ```createrepo``` is defined on a RHEL/CentOS 6 host and is accessed by RHEL/CentOS 5 or earlier clients.
- *Default*: ```undef```

# Issues #
Please log tickets and issues in the modules [GitHub issue tracker](https://github.com/pall-valmundsson/puppet-createrepo/issues)

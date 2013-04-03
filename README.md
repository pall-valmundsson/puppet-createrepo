# createrepo module #

[![Build Status](https://travis-ci.org/pall-valmundsson/puppet-createrepo.png)](https://travis-ci.org/pall-valmundsson/puppet-createrepo)

This is module creates yum repositories and metadata caches.
It also manages a cronjob to update the repodata.

# Status #
Beta. Works on CentOS/RHEL 6 with Puppet 2.7.

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


Example
-------
```
createrepo { 'yumrepo':
    repository_dir => '/var/yumrepos/yumrepo',
    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
}
```

Please log tickets and issues at our [Projects site](https://github.com/pall-valmundsson/puppet-createrepo)

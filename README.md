#createrepo

[![Puppet Forge](http://img.shields.io/puppetforge/v/palli/createrepo.svg)](https://forge.puppetlabs.com/palli/createrepo)  [![Build Status](https://travis-ci.org/pall-valmundsson/puppet-createrepo.png)](https://travis-ci.org/pall-valmundsson/puppet-createrepo)

##What it is and what it isn't

It does:
- create yum repositories and it metadata caches
- create a script to update the repository (handy for post hooks)
- optionally manage a cronjob to update the repository on a schedule

It *doesn't*:

- manage the directoy tree up to the root of the repository
- manage a HTTP server for repository clients

##Example usage

```puppet
    createrepo { 'yumrepo':
        repository_dir => '/var/yumrepos/yumrepo',
        repo_cache_dir => '/var/cache/yumrepos/yumrepo'
    }
```

##Status
Beta. Tested on CentOS/RHEL 6 with Puppet 2.7.

##Regarding checksums
Older versions of yum do not support some later default checksum types. From the ```createrepo``` man page:


    Choose  the  checksum  type used in repomd.xml and for packages in the metadata.  The default is now
    "sha256" (if python has hashlib). The older default was "sha", which is actually "sha1", however explicitly
    using "sha1" doesn’t work on older (3.0.x) versions of yum, you need to specify "sha".


```createrepo``` provides a checksum_type parameter to change the checksum type.

##Parameters

###repository_dir

The path to the base directory of the repository. Here, or in subdirectories
you store the .rpm files

- *Default*: ```/var/yumrepos/${name}```

###repo_cache_dir

Path to a checksum directory. Makes updates to repository much faster.

- *Default*: ```/var/cache/yumrepos/${name}```

###repo_owner

Owner of the repository directory.

- *Default*: ```root```

###repo_group

Group of the repository directory.

- *Default*: ```root```

###enable_cron

Enable regular repository updates via cron or Puppet.

- *Default*: ```true```

###cron_minute

Minute parameter for cron metadata update job.

- *Default*: ```*/1```

###cron_hour

Hour parameter for cron metadata update job.

- *Default*: ```*```

###changelog_limit

Number of changelog entries to import into metadata.

- *Default*: ```5```

###checksum_type

Sets the checksum type for repomd.xml. This needs to be set to ```sha``` if ```createrepo``` is defined on a RHEL/CentOS 6 host and is accessed by RHEL/CentOS 5 or earlier clients.

- *Default*: ```undef```

###update_file_path

Location of the repository update script file.

- *Default*: ```/usr/local/bin/createrepo-update-${name}```

###suppress_cron_stdout

Redirect stdout output from cron to /dev/null.

- *Default*: ```false```

###suppress_cron_stderr

Redirect stderr output from cron to /dev/null.

- *Default*: ```false```

###groupfile

Yum repository groupfile. Creates the repository metadata with supplied group information.

- *Default*: ```undef```

##Running tests

This project contains tests for both [rspec-puppet](http://rspec-puppet.com/) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) to verify functionality. For in-depth information please see their respective documentation.

Quickstart:

    gem install bundler
    bundle install
    bundle exec rake spec
    bundle exec rspec spec/acceptance
    RS_DEBUG=yes bundle exec rspec spec/acceptance

##Issues
Please log tickets and issues in the modules [GitHub issue tracker](https://github.com/pall-valmundsson/puppet-createrepo/issues)

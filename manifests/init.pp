# == Define: createrepo
#
# createrepo creates yum repositories.
#
# === Parameters
#
# [*repository_dir*]
#   The path to the base directory of the repository. Here, or in subdirectories
#   you store the .rpm files. Default: /var/yumrepos/${name}
#
# [*repo_cache_dir*]
#   Path to a checksum directory. Makes updates to repository much faster.
#   Default: /var/cache/yumrepos/${name}
#
# [*repo_owner*]
#   Owner of the repository directory. Default: 'root'
#
# [*repo_group*]
#   Group of the repository directory. Default: 'root'
#
# [*enable_cron*]
#   Enable automatic repository updates by cron. If disabled,
#   Puppet will update repository on each run. Default: true
#
# [*cron_minute*]
#   Minute parameter for cron metadata update job. Default: '*/1'
#
# [*cron_hour*]
#   Hour parameter for cron metadata update job. Default: '*'
#
# [*changelog_limit*]
#   Import only last N changelog entries from rpm into metadata. Default: 5
#
# [*checksum_type*]
#   For compatibility with older versions of yum.
#
# === Variables
#
# None.
#
# === Examples
#
#  createrepo { 'yumrepo':
#    repository_dir => '/var/yumrepos/yumrepo',
#    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
#  }
#
# === Authors
#
# Author Name <pall.valmundsson@gmail.com>
#
# === Copyright
#
# Copyright 2012, 2013 Pall Valmundsson, unless otherwise noted.
#
define createrepo (
    $repository_dir  = "/var/yumrepos/${name}",
    $repo_cache_dir  = "/var/cache/yumrepos/${name}",
    $repo_owner      = 'root',
    $repo_group      = 'root',
    $enable_cron     = true,
    $cron_minute     = '*/1',
    $cron_hour       = '*',
    $changelog_limit = 5,
    $checksum_type   = undef,
) {
    file { [$repository_dir, $repo_cache_dir]:
        ensure => directory,
        owner  => $repo_owner,
        group  => $repo_group,
        mode   => '0775',
    }

    if ! defined(Package['createrepo']) {
        package { 'createrepo':
            ensure => present,
        }
    }

    if $changelog_limit =~ /^\d+$/ {
        $_arg_changelog = " --changelog-limit ${changelog_limit}"
    } else {
        $_arg_changelog = ''
    }

    if $checksum_type {
        $_arg_checksum = " --checksum ${checksum_type}"
    } else {
        $_arg_checksum = ''
    }

    $cmd = '/usr/bin/createrepo'
    $arg = "--cachedir ${repo_cache_dir}${_arg_changelog}${_arg_checksum}"
    $createrepo_create = "${cmd} ${arg} --database ${repository_dir}"
    $createrepo_update = "${cmd} ${arg} --update ${repository_dir}"

    exec { "createrepo-${name}":
        command => $createrepo_create,
        user    => $repo_owner,
        group   => $repo_group,
        creates => "${repository_dir}/repodata",
        require => [
            Package['createrepo'],
            File[$repository_dir],
            File[$repo_cache_dir],
        ],
    }

    if $enable_cron == true {
        cron { "update-createrepo-${name}":
            command => $createrepo_update,
            user    => $repo_owner,
            minute  => $cron_minute,
            hour    => $cron_hour,
            require => Exec["createrepo-${name}"],
        }
    } else {
        exec { "update-createrepo-${name}":
            command => $createrepo_update,
            user    => $repo_owner,
            group   => $repo_group,
            require => Exec["createrepo-${name}"],
        }
    }
}

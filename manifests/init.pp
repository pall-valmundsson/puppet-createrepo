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
# [*repo_mode*]
#   Mode of the repository directory. Default: '0775'
#
# [*repo_recurse*]
#   Enable recursive managing of the repository directory. Default: false
#
# [*repo_seltype*]
#   Set the SELinux type for the repo directory.
#
# [*enable_cron*]
#   Enable automatic repository updates by cron. If disabled,
#   Puppet will update repository on each run. Default: true
#
# [*cron_minute*]
#   Minute parameter for cron metadata update job. Default: '*/10'
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
# [*update_file_path*]
#   Location of repo update script.
#
# [*suppress_cron_stdout*]
#   Redirect stdout output from cron to /dev/null.
#
# [*suppress_cron_stderr*]
#   Redirect stderr output from cron to /dev/null.
#
# [*groupfile*]
#   Provide a groupfile, e.g. comps.xml
#
# [*workers*]
#   Number of workers to spawn to read RPMs.
#
# [*timeout*]
#   Exec timeout for createrepo commands.
#
# [*manage_repo_dirs*]
#   Manage the repository directory. If false the repository and cache
#   directories must be created manually/externally.
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
# Páll Valmundsson <pall.valmundsson@gmail.com>
#
# === Copyright
#
# Copyright 2012-2017 Páll Valmundsson, unless otherwise noted.
#
define createrepo (
    $repository_dir       = "/var/yumrepos/${name}",
    $repo_cache_dir       = "/var/cache/yumrepos/${name}",
    $repo_owner           = 'root',
    $repo_group           = 'root',
    $repo_mode            = '0775',
    $repo_recurse         = false,
    $repo_seltype         = 'httpd_sys_content_t',
    $enable_cron          = true,
    $cron_minute          = '*/10',
    $cron_hour            = '*',
    $changelog_limit      = 5,
    $checksum_type        = undef,
    $update_file_path     = undef,
    $suppress_cron_stdout = false,
    $suppress_cron_stderr = false,
    $groupfile            = undef,
    $workers              = undef,
    $timeout              = 300,
    $manage_repo_dirs     = true
) {
    if $update_file_path != undef {
        $real_update_file_path = $update_file_path
    }
    else {
        $adjusted_name = regsubst($name, '/', '-', 'G')
        $real_update_file_path = "/usr/local/bin/createrepo-update-${adjusted_name}"
    }
    validate_absolute_path($repository_dir)
    validate_absolute_path($repo_cache_dir)
    validate_string($repo_owner)
    validate_string($repo_group)
    unless is_integer($timeout) {
        fail('timeout is not an integer')
    }


    validate_bool($manage_repo_dirs)
    if $manage_repo_dirs {
        file { $repository_dir:
            ensure  => directory,
            owner   => $repo_owner,
            group   => $repo_group,
            mode    => $repo_mode,
            recurse => $repo_recurse,
            seltype => $repo_seltype,
        }
        file { $repo_cache_dir:
            ensure => directory,
            owner  => $repo_owner,
            group  => $repo_group,
            mode   => '0775',
        }
    }

    if ! defined(Package['createrepo']) {
        package { 'createrepo':
            ensure => present,
        }
    }

    case $::osfamily {
        'RedHat':{
            if is_integer($changelog_limit) {
                $_arg_changelog = " --changelog-limit ${changelog_limit}"
            } else {
                $_arg_changelog = ''
            }

            if $checksum_type {
                $_arg_checksum = " --checksum ${checksum_type}"
            } else {
                $_arg_checksum = ''
            }
        }
        default:{
            # createrepo distributed with some OS don't have these options
            $_arg_checksum  = ''
            $_arg_changelog = ''
        }
    }

    validate_bool($suppress_cron_stdout, $suppress_cron_stderr)
    if $suppress_cron_stdout {
        $_stdout_suppress = ' 1>/dev/null'
    } else {
        $_stdout_suppress = ''
    }
    if $suppress_cron_stderr {
        $_stderr_suppress = ' 2>/dev/null'
    } else {
        $_stderr_suppress = ''
    }

    if $groupfile {
        validate_string($groupfile)
        $_arg_groupfile = " --groupfile ${groupfile}"
    } else {
        $_arg_groupfile = ''
    }

    if $workers {
      $_arg_workers = " --workers ${workers}"
    } else {
      $_arg_workers = ''
    }

    $cmd = '/usr/bin/createrepo'
    $_arg_cachedir = "--cachedir ${repo_cache_dir}"
    $arg = "${_arg_cachedir}${_arg_changelog}${_arg_checksum}${_arg_groupfile}${_arg_workers}"
    $cron_output_suppression = "${_stdout_suppress}${_stderr_suppress}"
    $createrepo_create = "${cmd} ${arg} --database ${repository_dir}"
    $createrepo_update = "${cmd} ${arg} --update ${repository_dir}"

    exec { "createrepo-${name}":
        command => $createrepo_create,
        user    => $repo_owner,
        group   => $repo_group,
        creates => "${repository_dir}/repodata",
        timeout => $timeout,
        require => [
            Package['createrepo'],
            File[$repository_dir],
            File[$repo_cache_dir],
        ],
    }

    validate_bool($enable_cron)
    if $enable_cron == true {
        cron { "update-createrepo-${name}":
            command => "${createrepo_update}${cron_output_suppression}",
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
            timeout => $timeout,
            require => Exec["createrepo-${name}"],
        }
    }

    validate_absolute_path($real_update_file_path)
    file { $real_update_file_path:
        ensure  => 'present',
        owner   => $repo_owner,
        group   => $repo_group,
        mode    => '0755',
        content => template('createrepo/createrepo-update.erb'),
    }
}

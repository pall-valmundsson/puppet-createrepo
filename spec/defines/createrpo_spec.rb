require 'spec_helper'

describe 'createrepo', :type => :define do
    context "On RedHat OS" do
        let :facts do
            { :osfamily => 'RedHat' }
        end
        let :title do
            'testyumrepo'
        end

        let :default_params do
        {
            :repository_dir => '/var/yumrepos/testyumrepo',
            :repo_cache_dir => '/var/cache/yumrepos/testyumrepo',
            :repo_owner     => 'root',
            :repo_group     => 'root',
            :cron_minute    => '*/1',
            :cron_hour      => '0',
        }
        end

        [{
            :repository_dir => '/var/yum/repo',
            :repo_cache_dir => '/var/cache/yum/repo',
            :repo_owner     => 'yum',
            :repo_group     => 'yum',
            :cron_minute    => '10',
            :cron_hour      => '1',
         },
        ].each do |param_set|

            describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do

                let :param_hash do
                    default_params.merge(param_set)
                end

                let :params do
                    param_set
                end

                it do
                    should contain_file(param_hash[:repository_dir]).with({
                        'ensure' => 'directory',
                        'owner'  => param_hash[:repo_owner],
                        'group'  => param_hash[:repo_group],
                        'mode'   => '0775',
                    })
    
                    should contain_file(param_hash[:repo_cache_dir]).with({
                        'ensure' => 'directory',
                        'owner'  => param_hash[:repo_owner],
                        'group'  => param_hash[:repo_group],
                        'mode'   => '0775',
                    })
    
                    should contain_cron("update-createrepo-#{title}").with({
                        'command' => "/usr/bin/createrepo --update --cachedir #{param_hash[:repo_cache_dir]} #{param_hash[:repository_dir]}",
                        'user'    => param_hash[:repo_owner],
                        'minute'  => param_hash[:cron_minute],
                        'hour'    => param_hash[:cron_hour],
                    })

                    should contain_exec("createrepo #{title} in #{param_hash[:repository_dir]}").with({
                        'command' => "createrepo --database --changelog-limit 5 --cachedir #{param_hash[:repo_cache_dir]} #{param_hash[:repository_dir]}",
                        'user'    => param_hash[:repo_owner],
                        'group'   => param_hash[:repo_group],
                        'creates' => "#{param_hash[:repository_dir]}/repodata",
                        'require' => ['Package[createrepo]', "File[#{param_hash[:repository_dir]}]"]
                    })
                end
            end
        end
    end
end

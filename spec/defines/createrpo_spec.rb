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
            :repository_dir  => '/var/yumrepos/testyumrepo',
            :repo_cache_dir  => '/var/cache/yumrepos/testyumrepo',
            :repo_owner      => 'root',
            :repo_group      => 'root',
            :enable_cron     => true,
            :cron_minute     => '*/1',
            :cron_hour       => '*',
            :changelog_limit => '5',
        }
        end

        [{},
         {
            :repository_dir  => '/var/yum/repo',
            :repo_cache_dir  => '/var/cache/yum/repo',
            :repo_owner      => 'yum',
            :repo_group      => 'yum',
            :enable_cron     => false,
            :cron_minute     => '10',
            :cron_hour       => '1',
            :changelog_limit => false,
            :checksum_type   => 'sha1',
         },
        ].each do |param_set|

            describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do

                let :param_hash do
                    default_params.merge(param_set)
                end

                let :params do
                    param_hash
                end

                let :command_base do
                    "/usr/bin/createrepo --cachedir #{param_hash[:repo_cache_dir]}" \
                        "#{param_hash[:changelog_limit] == false ? "" : " --changelog-limit #{param_hash[:changelog_limit]}"}" \
                        "#{param_hash.has_key?(:checksum_type) == false ? "" : " --checksum #{param_hash[:checksum_type]}"}"
                end

                it "installs package" do
                    should contain_package('createrepo')
                end

                it "creates directories" do
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
                end

                it "creates repository" do 
                    should contain_exec("createrepo-#{title}").with({
                        'command' => "#{command_base} --database #{param_hash[:repository_dir]}",
                        'user'    => param_hash[:repo_owner],
                        'group'   => param_hash[:repo_group],
                        'creates' => "#{param_hash[:repository_dir]}/repodata",
                        'require' => ['Package[createrepo]', "File[#{param_hash[:repository_dir]}]", "File[#{param_hash[:repo_cache_dir]}]"]
                    })
                end

                it "updates repository" do
                    if param_hash[:enable_cron] == true
                        should contain_cron("update-createrepo-#{title}").with({
                            'command' => "#{command_base} --update #{param_hash[:repository_dir]}",
                            'user'    => param_hash[:repo_owner],
                            'minute'  => param_hash[:cron_minute],
                            'hour'    => param_hash[:cron_hour],
                            'require' => "Exec[createrepo-#{title}]"
                        })
                    else
                        should contain_exec("update-createrepo-#{title}").with({
                            'command' => "#{command_base} --update #{param_hash[:repository_dir]}",
                            'user'    => param_hash[:repo_owner],
                            'group'   => param_hash[:repo_group],
                            'require' => "Exec[createrepo-#{title}]"
                        })
                    end
                end

                describe "includes update script" do
                    it "file" do
                        should contain_file("/usr/local/bin/createrepo-update-#{title}").with({
                            'ensure' => 'present',
                            'owner'  => param_hash[:repo_owner],
                            'group'  => param_hash[:repo_group],
                            'mode'   => '0755',
                        })
                    end
                    
                    it "content" do
                        should contain_file("/usr/local/bin/createrepo-update-#{title}") \
                            .with_content(/.*\$\(whoami\) != '#{param_hash[:repo_owner]}'.*/) \
                            .with_content(/.*You really should be #{param_hash[:repo_owner]}.*/) \
                            .with_content(/.*#{command_base} --update #{param_hash[:repository_dir]}.*/)
                    end
                end

            end
        end
    end
end

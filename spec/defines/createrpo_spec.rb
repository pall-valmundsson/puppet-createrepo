require 'spec_helper'

# Uses rspec shared examples from spec/support/createrepo_shared_examples.rb

describe 'createrepo', :type => :define do
    let :title do
        'testyumrepo'
    end
    context "On RedHat OS" do
        let :facts do
            { :osfamily => 'RedHat' }
        end

        # The createrepo command is :osfamily specific
        describe "it uses createrepo to" do
            it "create repository with correct command" do 
                should contain_exec("createrepo-#{title}").with({
                    'command' => "/usr/bin/createrepo --cachedir /var/cache/yumrepos/testyumrepo --changelog-limit 5 --database /var/yumrepos/testyumrepo",
                })
            end

            it "update repository with correct command" do
                should contain_cron("update-createrepo-#{title}").with({
                    'command' => "/usr/bin/createrepo --cachedir /var/cache/yumrepos/testyumrepo --changelog-limit 5 --update /var/yumrepos/testyumrepo",
                })
            end
        end

        describe "it ensures that the update script" do
            # The createrepo update command is :osfamily specific
            it "has the correct command" do
                should contain_file("/usr/local/bin/createrepo-update-#{title}") \
                    .with_content(/.*\/usr\/bin\/createrepo --cachedir \/var\/cache\/yumrepos\/testyumrepo --changelog-limit 5 --update \/var\/yumrepos\/testyumrepo.*/)
            end
        end

        it_works_like "when using default parameters"
        it_works_like "when owner and group are provided"
        it_works_like "when repository_dir and repository_cache_dir are provided"
        it_works_like "when enable_cron", "/usr/bin/createrepo --cachedir /var/cache/yumrepos/testyumrepo --changelog-limit 5 --update /var/yumrepos/testyumrepo"
        it_works_like "when suppressing cron output"
        it_works_like "when cron schedule is modified"
        it_works_like "when supplying invalid parameters"
        it_works_like "when groupfile is provided"
        it_works_like "when workers is set"
        it_works_like "when exec timeout is provided"
        it_works_like "when directory should not be managed"
        it_works_like "when repo directory mode is changed"
        it_works_like "when repo directory recurse is changed"

        context "works with changelog limit modifications" do
            let :params do
                {
                    :changelog_limit => 20,
                }
            end
            it_behaves_like "createrepo command changes", /^\/usr\/bin\/createrepo .* --changelog-limit 20 .*$/
        end

        context "works when specifying checksum type" do
            let :params do
                {
                    :checksum_type => 'sha1',
                }
            end
            it_behaves_like "createrepo command changes", /^\/usr\/bin\/createrepo .* --checksum sha1 .*$/
        end
    end

    context "On Debian OS" do
        let :facts do
            { :osfamily => 'Debian' }
        end

        # The createrepo command is :osfamily specific
        it "creates repository" do 
            should contain_exec("createrepo-#{title}").with({
                'command' => "/usr/bin/createrepo --cachedir /var/cache/yumrepos/testyumrepo --database /var/yumrepos/testyumrepo",
            })
        end

        it "updates repository" do
            should contain_cron("update-createrepo-#{title}").with({
                'command' => "/usr/bin/createrepo --cachedir /var/cache/yumrepos/testyumrepo --update /var/yumrepos/testyumrepo",
            })
        end

        # The createrepo update command is :osfamily specific
        it "update script has correct command" do
            should contain_file("/usr/local/bin/createrepo-update-#{title}") \
                .with_content(/.*\/usr\/bin\/createrepo --cachedir \/var\/cache\/yumrepos\/testyumrepo --update \/var\/yumrepos\/testyumrepo.*/)
        end

        it_works_like "when using default parameters"
        it_works_like "when owner and group are provided"
        it_works_like "when repository_dir and repository_cache_dir are provided"
        it_works_like "when enable_cron", "/usr/bin/createrepo --cachedir /var/cache/yumrepos/testyumrepo --update /var/yumrepos/testyumrepo"
        it_works_like "when suppressing cron output"
        it_works_like "when cron schedule is modified"
        it_works_like "when supplying invalid parameters"
        it_works_like "when groupfile is provided"
        it_works_like "when workers is set"
        it_works_like "when exec timeout is provided"
        it_works_like "when directory should not be managed"
        it_works_like "when repo directory mode is changed"
        it_works_like "when repo directory recurse is changed"

        context "works with changelog limit modifications" do
            let :params do
                {
                    :changelog_limit => 20,
                }
            end
            it_behaves_like "createrepo command changes", /^\/usr\/bin\/createrepo .* (?!--changelog-limit).*$/
        end

        context "works when specifying checksum type" do
            let :params do
                {
                    :checksum_type => 'sha1',
                }
            end
            it_behaves_like "createrepo command changes", /^\/usr\/bin\/createrepo .* (?!--checksum).*$/
        end
    end
end

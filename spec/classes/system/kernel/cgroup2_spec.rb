# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::system::kernel::cgroup2' do
  let(:ubuntu_20_04) do
    {
      os: {
        'distro' => {
          'release' => {
            'full' => '20.04',
            'major' => '20.04'
          },
          'description' => 'Ubuntu 20.04.3 LTS',
          'id' => 'Ubuntu',
          'codename' => 'focal'
        },
        'release' => {
          'full' => '20.04',
          'major' => '20.04'
        },
        'architecture' => 'amd64',
        'name' => 'Ubuntu',
        'hardware' => 'x86_64',
        'family' => 'Debian',
        'selinux' => {
          'enabled' => false
        },
      },
      operatingsystemmajrelease: '20.04',
      operatingsystemrelease: '20.04',
      lsbdistrelease: '20.04',
      lsbmajdistrelease: '20.04',
      architecture: 'amd64',
      lsbdistcodename: 'focal',
      lsbdistid: 'Ubuntu',
      lsbdistdescription: 'Ubuntu 20.04.3 LTS',
      kernelversion: '5.4.0',
      kernelmajversion: '5.4',
      kernelrelease: '5.4.0-90-generic',
      operatingsystem: 'Ubuntu',
      osfamily: 'Debian',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'when ubuntu system' do
        let(:facts) do
          os_facts.merge(ubuntu_20_04)
        end

        it {
          is_expected.to contain_file('/etc/default/grub.d/60-cgroup-v2.cfg')
            .with_content(%r{systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory swapaccount=1})
            .with_content(%r{^GRUB_CMDLINE_LINUX=})
            .that_notifies('Exec[kubeinstall-update-grub]')
        }

        it {
          is_expected.to contain_exec('kubeinstall-update-grub')
            .with_command('update-grub')
        }
      end
    end
  end
end

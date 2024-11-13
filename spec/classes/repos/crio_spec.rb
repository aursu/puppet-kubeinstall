# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::repos::crio' do
  let(:pre_condition) { 'include kubeinstall' }

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
          is_expected.to contain_file('/etc/apt/sources.list.d/cri-o.list')
            .with_content(%r{deb \[signed-by=/etc/apt/trusted.gpg.d/cri-o-v1.31-apt-keyring.gpg\] https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.31/deb/  /})
            .that_notifies('Class[apt::update]')
        }
      end
    end
  end
end

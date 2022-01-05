# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::install' do
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

      case os
      when %r{ubuntu}
        it {
          is_expected.to contain_package('kubectl')
            .with_ensure('1.23.1-00')
        }
        it {
          is_expected.to contain_package('kubeadm')
            .with_ensure('1.23.1-00')
        }
      when %r{centos-7}
        it {
          is_expected.to contain_package('kubectl')
            .with_ensure('1.23.1-0')
        }
        it {
          is_expected.to contain_package('kubeadm')
            .with_ensure('1.23.1-0')
        }
      end

      context 'when exact versions' do
        let(:params) do
          {
            kubernetes_version: '1.22.4',
            kubeadm_version: '1.23.1',
          }
        end

        it {
          is_expected.to contain_package('kubectl')
            .with_ensure('1.22.4')
        }

        it {
          is_expected.to contain_package('kubeadm')
            .with_ensure('1.23.1')
        }

        context 'when ubuntu system' do
          let(:facts) do
            os_facts.merge(ubuntu_20_04)
          end

          it {
            is_expected.to contain_package('kubectl')
              .with_ensure('1.22.4*')
          }

          it {
            is_expected.to contain_package('kubeadm')
              .with_ensure('1.23.1*')
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::runtime::docker' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when 'centos-7-x86_64'
        it {
          is_expected.to contain_package('docker')
            .with_name('docker-ce')
        }

        it {
          is_expected.to contain_package('containerd.io')
            .with_name('containerd.io')
        }
      end

      it {
        is_expected.to contain_file('/etc/docker')
          .with_ensure('directory')
      }
    end
  end
end

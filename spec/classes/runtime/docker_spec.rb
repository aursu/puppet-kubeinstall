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
            .with_ensure('19.03.11-3.el7')
        }

        it {
          is_expected.to contain_package('containerd.io')
            .with_name('containerd.io')
            .with_ensure('1.2.13-3.2.el7')
        }
      else
      end
    end
  end
end

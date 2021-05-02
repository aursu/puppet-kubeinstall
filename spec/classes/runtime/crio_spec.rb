# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::runtime::crio' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_service('crio')
          .that_requires('Package[docker]')
      }

      it {
        is_expected.to contain_package('docker')
          .that_notifies('Exec[kubeadm-reset]')
      }

      it {
        is_expected.to contain_package('cri-o')
          .that_requires('Exec[kubeadm-reset]')
      }

      it {
        is_expected.to contain_service('crio')
          .that_requires('Package[cri-o]')
      }
    end
  end
end

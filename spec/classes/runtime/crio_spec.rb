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
        is_expected.to contain_file('/etc/crio/crio.conf')
          .that_requires('Package[cri-o]')
      }

      it {
        is_expected.to contain_service('crio')
          .that_requires('Package[cri-o]')
      }

      it {
        is_expected.to contain_service('crio')
          .that_subscribes_to('File[/etc/crio/crio.conf]')
      }
    end
  end
end

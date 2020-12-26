# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::service' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    os_facts[:os]['selinux'] = { 'enabled' => false }

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      # this check is major for service class
      it {
        is_expected.to contain_service('kubelet')
          .that_subscribes_to('Package[kubelet]')
      }
    end
  end
end

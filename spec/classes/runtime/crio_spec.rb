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
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::calico::veth_mtu' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          mtu: 1430,
        }
      end

      it { is_expected.to compile }
    end
  end
end

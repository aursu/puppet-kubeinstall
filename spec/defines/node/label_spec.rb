# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::node::label' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:title) { 'env' }
  let(:params) do
    {
      value: 'prod',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_exec('kubectl label node kubec-01.domain.tld env=prod --overwrite')
          .with_unless('kubectl get nodes --selector=env=prod,kubernetes.io/hostname=kubec-01.domain.tld | grep -w kubec-01.domain.tld')
      }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::kubectl::apply' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:title) { 'namevar' }
  let(:params) do
    {
      kind: 'PersistentVolume',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_exec('kubectl apply -f /etc/kubectl/manifests/persistentvolumes/namevar.yaml')
          .with_onlyif('test -f /etc/kubectl/manifests/persistentvolumes/namevar.yaml')
      }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::directory_structure' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_file('/etc/kubectl')
          .with_ensure('directory')
      }

      it {
        is_expected.to contain_file('/etc/kubectl/manifests')
          .with_ensure('directory')
      }
    end
  end
end

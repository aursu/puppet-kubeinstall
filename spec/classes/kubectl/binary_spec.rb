# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::kubectl::binary' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          version: '1.28.2',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_exec('install-kubectl')
          .with_command('curl -L https://dl.k8s.io/release/v1.28.2/bin/linux/amd64/kubectl -o kubectl-1.28.2')
          .with_creates('/usr/local/bin/kubectl-1.28.2')
      }

      it {
        is_expected.to contain_file('/usr/local/bin/kubectl')
          .with_source('file:///usr/local/bin/kubectl-1.28.2')
          .that_requires('Exec[install-kubectl]')
      }
    end
  end
end

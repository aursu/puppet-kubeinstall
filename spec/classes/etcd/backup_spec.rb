# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::etcd::backup' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'repository' => '/var/backups/etcd/restic',
          'password' => 'test-repo-password',
        }
      end

      it { is_expected.to compile }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::repos' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          kuberel: '1.27',
        }
      end

      it { is_expected.to compile }

      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.to contain_file('/etc/apt/sources.list.d/kubernetes.list')
            .with_content(%r{^deb \[signed-by=/etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg\] https://pkgs.k8s.io/core:/stable:/v1.27/deb/  /})
        }
      end
    end
  end
end

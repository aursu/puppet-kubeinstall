# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::kubeadm::join_config' do
  let(:pre_condition) { 'include kubeinstall' }
  let(:params) do
    {
      'token'             => 'o9o8vw.fe02deotcm0dv8z5',
      'ca_cert_hash'      => 'sha256:63cfe60bdc6d53e4a163448c069a3a78bf33486948efcae2b6eab85d3dac61fa',
      'apiserver_address' => '172.16.100.49',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when %r{centos}
        it {
          is_expected.to contain_file('/etc/kubernetes/kubeadm-join.conf')
            .with_content(%r{cgroup-driver: systemd$})
        }
      end
    end
  end
end

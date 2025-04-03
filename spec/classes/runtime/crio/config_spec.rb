# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::runtime::crio::config' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/crio/crio.conf')
          .with_content(%r{^selinux = true})
      }

      context 'when cgroup driver cgroupfs' do
        let(:params) do
          {
            cgroup_driver: 'cgroupfs',
          }
        end

        it {
          is_expected.to contain_file('/etc/crio/crio.conf')
            .with_content(%r{conmon_cgroup = "pod"})
            .with_content(%r{cgroup_manager = "cgroupfs"})
        }
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::runtime::containerd::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {}
      end

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_exec('containerd config default')
          .with_command('containerd config default > /etc/containerd/config.toml')
      }

      context 'when content setup' do
        let(:params) do
          super().merge(
            set_content: true,
          )
        end

        it {
          is_expected.to contain_file('/etc/containerd/config.toml')
            .with_content(%r{default_runtime_name = "runc"})
        }
      end
    end
  end
end

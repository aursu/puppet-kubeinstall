# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::install::node' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    os_facts[:os]['selinux'] = { 'enabled' => false }

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_service('kubelet')
          .that_requires('Package[cri-o]')
      }

      it {
        is_expected.to contain_service('kubelet')
          .that_requires('Service[crio]')
      }

      context 'when runtime is Docker' do
        let(:pre_condition) do
          <<-PRECOND
          class { 'kubeinstall':
            container_runtime => 'docker',
          }
          PRECOND
        end

        it {
          is_expected.to contain_service('kubelet')
            .that_requires('Package[docker]')
        }

        it {
          is_expected.to contain_service('kubelet')
            .that_requires('Kmod::Load[br_netfilter]')
        }
      end
    end
  end
end

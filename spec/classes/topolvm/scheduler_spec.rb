# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::topolvm::scheduler' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:config_content) do
    <<-YAMLDATA
---
apiVersion: kubescheduler.config.k8s.io/v1beta3
kind: KubeSchedulerConfiguration
leaderElection:
  leaderElect: true
clientConnection:
  kubeconfig: /etc/kubernetes/scheduler.conf
extenders:
- urlPrefix: "http://127.0.0.1:9251"
  filterVerb: "predicate"
  prioritizeVerb: "prioritize"
  nodeCacheCapable: false
  weight: 1
  managedResources:
  - name: "topolvm.io/capacity"
    ignoredByScheduler: true
YAMLDATA
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_file('/var/lib/kubelet/plugins/topolvm.io/scheduler')
          .with(
            ensure: 'directory',
            recurse: true,
          )
      }

      context 'when manage scheduler config' do
        let(:params) do
          {
            manage_config: true,
          }
        end

        it {
          is_expected.to contain_file('/var/lib/kubelet/plugins/topolvm.io/scheduler/scheduler-config.yaml')
            .with_content(config_content)
        }
      end
    end
  end
end

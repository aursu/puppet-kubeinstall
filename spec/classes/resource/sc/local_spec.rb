# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::resource::sc::local' do
  let(:pre_condition) { 'include kubeinstall' }
  let(:object_content) do
    <<-YAMLDATA
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
allowVolumeExpansion: false
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAMLDATA
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('local-storage')
          .with_path('/etc/kubectl/manifests/storageclasses/local-storage.yaml')
          .with_content(object_content)
      }
    end
  end
end

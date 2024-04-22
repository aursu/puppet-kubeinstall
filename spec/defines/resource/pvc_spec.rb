# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::resource::pvc' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:pvc_object_content) do
    <<-YAMLDATA
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data0-minio-pool-0-1
spec:
  accessModes:
  - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 100Gi
YAMLDATA
  end

  let(:title) { 'data0-minio-pool-0-1' }
  let(:params) do
    {
      volume_storage: '100Gi',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('data0-minio-pool-0-1')
          .with_path('/etc/kubectl/manifests/persistentvolumeclaims/data0-minio-pool-0-1.yaml')
          .with_content(pvc_object_content)
      }
    end
  end
end

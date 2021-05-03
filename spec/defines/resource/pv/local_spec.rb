# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::resource::pv::local' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:pv_object_content) do
    <<-YAMLDATA
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: kube-01-local-pv
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: "/mnt/disks/vdb1"
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - kube-01.domain.tld
YAMLDATA
  end

  let(:title) { 'kube-01-local-pv' }
  let(:params) do
    {
      volume_storage: '100Gi',
      path: '/mnt/disks/vdb1',
      hostname: 'kube-01.domain.tld',
      storage_class_name: 'local-storage',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('kube-01-local-pv')
          .with_path('/etc/kubectl/manifests/persistentvolumes/kube-01-local-pv.yaml')
          .with_content(pv_object_content)
      }
    end
  end
end

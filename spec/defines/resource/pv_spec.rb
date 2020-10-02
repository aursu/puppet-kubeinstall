# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::resource::pv' do
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
YAMLDATA
  end

  let(:title) { 'kube-01-local-pv' }
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
        is_expected.to contain_file('kube-01-local-pv')
          .with_path('/etc/kubernetes/manifests/persistentvolumes/kube-01-local-pv.yaml')
          .with_content(pv_object_content)
      }
    end
  end
end

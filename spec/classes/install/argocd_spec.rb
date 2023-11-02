# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::install::argocd' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:service_content) do
    <<-YAMLDATA
---
apiVersion: v1
kind: Service
metadata:
  name: argocd-server-static
  namespace: argocd
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server-static
    app.kubernetes.io/part-of: argocd
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: argocd-server
  ports:
  - name: https
    port: 443
    protocol: TCP
    nodePort: 30200
    targetPort: 8080
YAMLDATA
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {}
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_exec('kubectl create namespace argocd')
          .with_unless('kubectl get namespace argocd')
      }

      it {
        is_expected.to contain_exec('argocd-install')
          .with_command(%r{kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2\.[0-9]+\.[0-9]+/manifests/install.yaml})
          .with_unless(%r{kubectl get -n argocd deployment.apps/argocd-server -o jsonpath='\{.spec.template.spec.containers\[\?\(@.name == \"argocd-server\"\)\].image\}' | grep v2\.[0-9]*\.[0-9]+})
          .that_requires('Kubeinstall::Resource::Ns[argocd]')
      }

      context 'when service is exposed' do
        let(:params) do
          super().merge(
            expose: true,
          )
        end

        it {
          is_expected.to contain_file('argocd-server-static')
            .with_path('/etc/kubectl/manifests/services/argocd-server-static.yaml')
            .with_content(service_content)
            .that_requires('Exec[argocd-install]')
        }

        it {
          is_expected.to contain_exec('kubectl apply -f /etc/kubectl/manifests/services/argocd-server-static.yaml')
            .that_subscribes_to('File[argocd-server-static]')
        }
      end
    end
  end
end

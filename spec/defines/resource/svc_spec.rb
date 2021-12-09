# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::resource::svc' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:svc_object_content) do
    <<-YAMLDATA
---
apiVersion: v1
kind: Service
metadata:
  name: namevar
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: namevar
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8080
YAMLDATA
  end

  let(:title) { 'namevar' }
  let(:params) do
    {
      ports: [
        {
          name: 'http',
          port: 80,
          protocol: 'TCP',
          targetPort: 8080,
        },
        {
          name: 'https',
          port: 443,
          protocol: 'TCP',
          targetPort: 8080,
        },
      ],
      selector: {
        'app.kubernetes.io/name' => 'namevar',
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('namevar')
          .with_path('/etc/kubectl/manifests/services/namevar.yaml')
          .with_content(svc_object_content)
      }

      context 'when apply is use' do
        let(:params) do
          super().merge(
            apply: true,
          )
        end

        it {
          is_expected.to contain_exec('kubectl apply -f /etc/kubectl/manifests/services/namevar.yaml')
            .that_subscribes_to('File[namevar]')
        }
      end
    end
  end
end

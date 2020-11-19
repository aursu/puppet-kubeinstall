# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::resource::secret' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('namevar')
          .with_path('/etc/kubernetes/manifests/secrets/namevar.yaml')
          .with_content(%r{^  name: namevar$})
          .with_content(%r{^type: Opaque$})
      }

      context "when data in use" do
        let(:title) { 'secret-sa-sample' }
        let(:params) do
          {
            metadata: {
              annotations: {
                'kubernetes.io/service-account.name' => 'sa-name',
              }
            },
            type: 'kubernetes.io/service-account-token',
            data: {
              extra: 'YmFyCg==',
            }
          }
        end

        it {
          is_expected.to contain_file('secret-sa-sample')
            .with_path('/etc/kubernetes/manifests/secrets/secret-sa-sample.yaml')
            .with_content(%r{^[ ]{2}name: secret-sa-sample$})
            .with_content(%r{^[ ]{2}annotations:\n[ ]{4}kubernetes.io/service-account.name: sa-name$})
            .with_content(%r{^type: kubernetes.io/service-account-token$})
            .with_content(%r{^data:\n[ ]{2}extra: YmFyCg==$})
        }
      end

      context "when raw_data in use" do
        let(:title) { 'secret-sa-sample' }
        let(:params) do
          {
            raw_data: {
              extra: "bar\n",
            }
          }
        end

        it {
          is_expected.to contain_file('secret-sa-sample')
            .with_path('/etc/kubernetes/manifests/secrets/secret-sa-sample.yaml')
            .with_content(%r{^data:\n[ ]{2}extra: YmFyCg==$})
        }
      end

      context "when string_data in use" do
        let(:title) { 'secret-basic-auth' }
        let(:params) do
          {
            type: 'kubernetes.io/basic-auth',
            string_data: {
              username: 'admin',
              password: 't0p-Secret',
            }
          }
        end

        it {
          is_expected.to contain_file('secret-basic-auth')
            .with_path('/etc/kubernetes/manifests/secrets/secret-basic-auth.yaml')
            .with_content(%r{^type: kubernetes.io/basic-auth$})
            .with_content(%r{^stringData:\n[ ]{2}username: admin\n[ ]{2}password: t0p-Secret$})
        }
      end
    end
  end
end

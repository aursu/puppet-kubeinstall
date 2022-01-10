# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::helm::chart' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.and_raise_error(%r{Helm chart is not defined properly}) }

      context 'when installation by chart reference' do
        let(:pre_condition) do
          <<-PRECOND
          include kubeinstall
          kubeinstall::helm::repo { 'rook-release':
            url => 'https://charts.rook.io/release',
          }
          PRECOND
        end
        let(:title) { 'rook-release/rook-ceph' }

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('helm install rook-release/rook-ceph --generate-name')
            .with_unless(["helm list -o json | grep '\"chart\":\"rook-ceph' | grep '\"name\":\"rook-ceph-'"])
            .that_requires('Kubeinstall::Helm::Repo[rook-release]')
        }

        context 'when namespace specified' do
          let(:pre_condition) do
            <<-PRECOND
            include kubeinstall
            kubeinstall::helm::repo { 'rook-release':
              url => 'https://charts.rook.io/release',
            }
            kubeinstall::resource::ns { 'rook-ceph': }
            PRECOND
          end
          let(:params) do
            {
              namespace: 'rook-ceph',
            }
          end

          it {
            is_expected.to contain_exec('helm install rook-release/rook-ceph --generate-name --namespace rook-ceph')
              .with_unless(["helm list -o json --namespace rook-ceph | grep '\"chart\":\"rook-ceph' | grep '\"name\":\"rook-ceph-'"])
              .that_requires('Kubeinstall::Resource::Ns[rook-ceph]')
          }

          context 'and requested to create it' do
            let(:pre_condition) do
              <<-PRECOND
              include kubeinstall
              kubeinstall::helm::repo { 'rook-release':
                url => 'https://charts.rook.io/release',
              }
              PRECOND
            end
            let(:params) { super().merge(create_namespace: true) }

            it {
              is_expected.to contain_exec('helm install rook-release/rook-ceph --generate-name --namespace rook-ceph --create-namespace')
                .with_unless(["helm list -o json --namespace rook-ceph | grep '\"chart\":\"rook-ceph' | grep '\"name\":\"rook-ceph-'"])
            }
          end
        end

        context 'when release name specified' do
          let(:params) do
            {
              release_name: 'rook-ceph',
            }
          end

          it {
            is_expected.to contain_exec('helm install rook-ceph rook-release/rook-ceph')
              .with_unless(["helm list -o json | grep '\"chart\":\"rook-ceph' | grep '\"name\":\"rook-ceph\"'"])
          }
        end

        context 'when values in a YAML file specified' do
          let(:params) do
            {
              release_name: 'rook-ceph',
              values: 'values.yaml',
            }
          end

          it {
            is_expected.to contain_exec('helm install rook-ceph rook-release/rook-ceph -f values.yaml')
          }

          context 'when values in multiple YAML files specified' do
            let(:params) { super().merge(values: ['values.yaml', 'override.yaml']) }

            it {
              is_expected.to contain_exec('helm install rook-ceph rook-release/rook-ceph -f values.yaml -f override.yaml')
            }
          end
        end
      end

      context 'when installation by repo_name' do
        let(:pre_condition) do
          <<-PRECOND
          include kubeinstall
          kubeinstall::helm::repo { 'rook-release':
            url => 'https://charts.rook.io/release',
          }
          PRECOND
        end
        let(:title) { 'rook-ceph' }
        let(:params) do
          {
            repo_name: 'rook-release',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('helm install rook-release/rook-ceph --generate-name')
            .with_unless(["helm list -o json | grep '\"chart\":\"rook-ceph' | grep '\"name\":\"rook-ceph-'"])
        }
      end

      context 'when installation by repo_url' do
        let(:pre_condition) { 'include kubeinstall' }
        let(:title) { 'rook-ceph' }
        let(:params) do
          {
            repo_url: 'https://charts.rook.io/release',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('helm install rook-ceph --repo https://charts.rook.io/release --generate-name')
            .with_unless(["helm list -o json | grep '\"chart\":\"rook-ceph' | grep '\"name\":\"rook-ceph-'"])
        }
      end
    end
  end
end

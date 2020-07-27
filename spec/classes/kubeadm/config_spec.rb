# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::kubeadm::config' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/kubernetes/kubeadm-init.conf')
          .with_content(%r{advertiseAddress: 172.16.100.49})
      }

      it {
        is_expected.to contain_file('/etc/kubernetes/kubeadm-init.conf')
          .with_content(%r{bindPort: 6443})
      }

      it {
        is_expected.to contain_file('/etc/kubernetes/kubeadm-init.conf')
          .with_content(%r{name: kubec-01.domain.tld})
      }

      context 'check token validity' do
        let(:params) do
          {
            bootstrap_token: 'secret',
          }
        end

        it {
          is_expected.to compile.and_raise_error(%r{parameter 'bootstrap_token' expects an undef value or a match for Pattern})
        }

        context 'when valid' do
          let(:params) do
            {
              bootstrap_token: 'abcdef.0123456789abcdef',
            }
          end

          it {
            is_expected.to contain_file('/etc/kubernetes/kubeadm-init.conf')
              .with_content(%r{token: abcdef.0123456789abcdef})
          }
        end
      end

      context 'check token ttl validity' do
        context 'with wronng pattern' do
          let(:params) do
            {
              token_ttl: '24h90m0s',
            }
          end

          it {
            is_expected.to compile.and_raise_error(%r{parameter 'token_ttl' expects a match for Pattern})
          }
        end

        context 'when empty' do
          let(:params) do
            {
              token_ttl: '',
            }
          end

          it {
            is_expected.to compile.and_raise_error(%r{parameter 'token_ttl' expects a String\[2\] value, got String})
          }
        end

        context 'when valid' do
          let(:params) do
            {
              bootstrap_token: 'abcdef.0123456789abcdef',
              token_ttl: '24h',
            }
          end

          it {
            is_expected.to contain_file('/etc/kubernetes/kubeadm-init.conf')
              .with_content(%r{ttl: 24h$})
          }
        end
      end
    end
  end
end

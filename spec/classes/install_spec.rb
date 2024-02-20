# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::install' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when %r{ubuntu}
        it {
          is_expected.to contain_package('kubectl')
            .with_ensure('1.29.2-1.1')
        }
        it {
          is_expected.to contain_package('kubeadm')
            .with_ensure('1.29.2-1.1')
        }
      else
        it {
          is_expected.to contain_package('kubectl')
            .with_ensure('1.29.2')
        }
        it {
          is_expected.to contain_package('kubeadm')
            .with_ensure('1.29.2')
        }
      end

      context 'when exact versions' do
        let(:params) do
          {
            kubernetes_version: '1.22.4',
            kubeadm_version: '1.24.1',
          }
        end

        it { is_expected.to compile }

        case os
        when %r{ubuntu}
          it {
            is_expected.to contain_package('kubectl')
              .with_ensure('1.22.4-1.1')
          }

          it {
            is_expected.to contain_package('kubeadm')
              .with_ensure('1.24.1-1.1')
          }
        else
          it {
            is_expected.to contain_package('kubectl')
              .with_ensure('1.22.4')
          }

          it {
            is_expected.to contain_package('kubeadm')
              .with_ensure('1.24.1')
          }
        end
      end
    end
  end
end

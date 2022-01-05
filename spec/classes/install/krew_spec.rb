# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::install::krew' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_archive('krew-linux_amd64.tar.gz')
          .with_source(%r{https://github.com/kubernetes-sigs/krew/releases/download/v[0-9.]+/krew-linux_amd64\.tar\.gz})
      }

      context 'when version less than 0.4.2' do
        let(:params) do
          {
            version: '0.4.0',
          }
        end

        it {
          is_expected.to contain_archive('krew.tar.gz')
            .with_source('https://github.com/kubernetes-sigs/krew/releases/download/v0.4.0/krew.tar.gz')
        }
      end
    end
  end
end

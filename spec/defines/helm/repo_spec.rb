# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::helm::repo' do
  let(:pre_condition) { 'include kubeinstall' }

  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.and_raise_error(%r{URL of chart repository must be provided}) }

      context 'when install repo' do
        let(:title) { 'rook-release' }
        let(:params) do
          {
            url: 'https://charts.rook.io/release',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('helm repo add rook-release https://charts.rook.io/release --force-update')
            .with_unless('helm repo list -o json | grep -w rook-release | grep https://charts.rook.io/release')
        }
      end

      context 'when remove repo' do
        let(:title) { 'rook-release' }
        let(:params) do
          {
            ensure: 'absent',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('helm repo remove rook-release')
            .with_onlyif('helm repo list -o json | grep -w rook-release')
        }
      end
    end
  end
end

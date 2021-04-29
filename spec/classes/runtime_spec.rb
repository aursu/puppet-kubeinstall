# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::runtime' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'when CRI-O' do
        let(:params) do
          {
            container_runtime: 'cri-o',
          }
        end

        it { is_expected.to compile }
      end
    end
  end
end

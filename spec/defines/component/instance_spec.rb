# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::component::instance' do
  let(:pre_condition) { 'include kubeinstall' }
  let(:title) { 'kubectl' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::install::node' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    os_facts[:os]['selinux'] = { 'enabled' => false }

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end

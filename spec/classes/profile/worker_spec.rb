# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::profile::worker' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(stype: 'worker') }

      it { is_expected.to compile }
    end
  end
end

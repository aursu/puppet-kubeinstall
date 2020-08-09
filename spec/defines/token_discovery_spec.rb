# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::token_discovery' do
  let(:pre_condition) { 'include kubeinstall' }
  let(:title) { 'o9o8vw.fe02deotcm0dv8z5' }
  let(:params) do
    {
      'ca_cert_hash' => 'sha256:63cfe60bdc6d53e4a163448c069a3a78bf33486948efcae2b6eab85d3dac61fa',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end

require 'spec_helper'

describe Puppet::Type.type(:kubeadm_token) do
  let(:resource) { described_class.new(name: 'default') }

  context 'check default values' do
    it 'set default TTL to 24h0m0s' do
      expect(resource[:ttl]).to eq('24h0m0s')
    end
  end
end

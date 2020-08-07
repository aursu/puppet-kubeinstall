require 'spec_helper'

describe Puppet::Type.type(:kubeadm_token).provider(:kubeadm) do
  let(:tokens) do
    <<-KUBEADM_OUTPUT
    apiVersion: output.kubeadm.k8s.io/v1alpha1
    description: bootstrap token
    expires: "2020-08-08T08:08:21Z"
    groups:
    - system:bootstrappers:kubeadm:default-node-token
    kind: BootstrapToken
    token: 2tw5sb.kbwcjn7fmzhot9qk
    usages:
    - authentication
    - signing
    ---
    apiVersion: output.kubeadm.k8s.io/v1alpha1
    description: bootstrap token
    expires: "2020-08-08T09:03:45Z"
    groups:
    - system:bootstrappers:kubeadm:default-node-token
    kind: BootstrapToken
    token: ggw2gp.7x23mp98p5otun9y
    usages:
    - authentication
    - signing
    ---
    apiVersion: output.kubeadm.k8s.io/v1alpha1
    description: bootstrap token
    expires: "2020-08-06T10:17:41Z"
    groups:
    - system:bootstrappers:kubeadm:default-node-token
    kind: BootstrapToken
    token: gis4bs.zpg834trop4z38ya
    usages:
    - authentication
    - signing
    ---
    apiVersion: output.kubeadm.k8s.io/v1alpha1
    description: bootstrap token
    groups:
    - system:bootstrappers:kubeadm:default-node-token
    kind: BootstrapToken
    token: rsrcto.meqk4luaz14nx82v
    usages:
    - authentication
    - signing
    ---
    apiVersion: output.kubeadm.k8s.io/v1alpha1
    description: bootstrap token
    expires: "2020-08-06T10:07:14Z"
    groups:
    - system:bootstrappers:kubeadm:default-node-token
    kind: BootstrapToken
    token: vhd9hm.yojlxb99342dzcdo
    usages:
    - authentication
    ---
    apiVersion: output.kubeadm.k8s.io/v1alpha1
    description: bootstrap token
    expires: "2020-08-06T10:19:32Z"
    groups:
    - system:bootstrappers:worker
    - system:bootstrappers:ingres
    kind: BootstrapToken
    token: z95iwb.gmriuaidatq9dzdn
    usages:
    - authentication
    - signing
    KUBEADM_OUTPUT
  end

  let(:resource_name) { 'default' }
  let(:resource) do
    Puppet::Type.type(:kubeadm_token).new(
      name: resource_name,
      ensure: :present,
      provider: 'kubeadm',
    )
  end
  let(:provider) do
    provider = subject
    provider.resource = resource
    provider
  end

  before(:each) do
    allow(described_class).to receive(:which).with('kubeadm').and_return('/bin/kubeadm')
    # Fix current time
    allow(DateTime).to receive(:now).with(no_args).and_return(DateTime.new(2020, 8, 6, 9, 3, 45))
  end

  describe 'self.instances' do
    it 'returns an array of tokens' do
      allow(Puppet::Util::Execution).to receive(:execute)
        .with('/bin/kubeadm token list -o yaml')
        .and_return(tokens)

      available_tokens = described_class.instances

      expect(available_tokens[0].properties).to eq(
        auth_extra_groups: ['system:bootstrappers:kubeadm:default-node-token'],
        bootstrap_authentication: true,
        bootstrap_signing: true,
        description: 'bootstrap token',
        ensure: :present,
        id: 'ggw2gp',
        name: 'default',
        provider: :kubeadm,
        secret: '7x23mp98p5otun9y',
        ttl: '48h0m0s',
      )

      expect(available_tokens[1].properties).to eq(
        auth_extra_groups: ['system:bootstrappers:kubeadm:default-node-token'],
        bootstrap_authentication: true,
        bootstrap_signing: true,
        description: 'bootstrap token',
        ensure: :present,
        id: '2tw5sb',
        name: 'bootstrap-token-2tw5sb',
        provider: :kubeadm,
        secret: 'kbwcjn7fmzhot9qk',
        ttl: '47h4m36s',
      )

      expect(available_tokens[2].properties).to eq(
        auth_extra_groups: [
          'system:bootstrappers:worker',
          'system:bootstrappers:ingres',
        ],
        bootstrap_authentication: true,
        bootstrap_signing: true,
        description: 'bootstrap token',
        ensure: :present,
        id: 'z95iwb',
        name: 'bootstrap-token-z95iwb',
        provider: :kubeadm,
        secret: 'gmriuaidatq9dzdn',
        ttl: '1h15m47s',
      )

      expect(available_tokens[3].properties).to eq(
        auth_extra_groups: ['system:bootstrappers:kubeadm:default-node-token'],
        bootstrap_authentication: true,
        bootstrap_signing: true,
        description: 'bootstrap token',
        ensure: :present,
        id: 'gis4bs',
        name: 'bootstrap-token-gis4bs',
        provider: :kubeadm,
        secret: 'zpg834trop4z38ya',
        ttl: '1h13m56s',
      )

      expect(available_tokens[4].properties).to eq(
        auth_extra_groups: ['system:bootstrappers:kubeadm:default-node-token'],
        bootstrap_authentication: true,
        bootstrap_signing: false,
        description: 'bootstrap token',
        ensure: :present,
        id: 'vhd9hm',
        name: 'bootstrap-token-vhd9hm',
        provider: :kubeadm,
        secret: 'yojlxb99342dzcdo',
        ttl: '1h3m29s',
      )

      expect(available_tokens[5].properties).to eq(
        auth_extra_groups: ['system:bootstrappers:kubeadm:default-node-token'],
        bootstrap_authentication: true,
        bootstrap_signing: true,
        description: 'bootstrap token',
        ensure: :present,
        id: 'rsrcto',
        name: 'bootstrap-token-rsrcto',
        provider: :kubeadm,
        secret: 'meqk4luaz14nx82v',
        ttl: 0,
      )
    end
  end

  describe '#create' do
    let(:resource) do
      Puppet::Type.type(:kubeadm_token).new(
        name: resource_name,
        ensure: :present,
        provider: 'kubeadm',
      )
    end

    describe 'when no tokens available' do
      it 'creates new token' do
        expect(Puppet::Util::Execution).to receive(:execute)
          .with('/bin/kubeadm token create --ttl 24h0m0s --usages authentication --usages signing')
        provider.create
      end
    end
  end
end

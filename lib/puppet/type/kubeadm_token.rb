require 'puppet/parameter/boolean'

# https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/
Puppet::Type.newtype(:kubeadm_token) do
  @doc = 'Bootstrap tokens are a simple bearer token that is meant to be used when creating new clusters or joining new nodes to an existing cluster'

  ensurable do
    desc 'Create or remove token.'

    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.delete
    end

    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'Token Name'

    newvalues(%r{^(bootstrap-token-)?[a-z0-9]{6}$}, 'default')

    munge do |value|
      value.to_s
    end
  end

  newproperty(:id) do
    desc 'Token ID'

    newvalues(%r{^[a-z0-9]{6}$})

    defaultto do
      @resource[:name].split('-').last unless @resource[:name].to_s == 'default'
    end
  end

  newproperty(:secret) do
    desc 'Token Secret'

    newvalues(%r{^[a-z0-9]{6}$})
  end

  newproperty(:ttl) do
    desc 'Controls the expiry of the token'

    newvalues(%r{^([0-9]+h)?([1-5]?[0-9]m)?([1-5]?[0-9]s)?$}, 0, '0')

    defaultto '24h0m0s'

    validate do |value|
      next if value.to_s == '0'
      raise ArgumentError, _('TTL parameter could not be empty') if value.empty?
    end

    munge do |value|
      case value
      when '0'
        0
      else
        value
      end
    end

    # we do not try to sync  it
    def insync?(_is)
      true
    end
  end

  newproperty(:auth_extra_groups, array_matching: :all) do
    desc 'Extra groups to authenticate the token as'

    newvalues(%r{^system:bootstrappers:[a-z0-9:-]{0,255}[a-z0-9]$})
  end

  newparam(:bootstrap_authentication, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Indicates that the token can be used to authenticate to the API server as a bearer token'

    defaultto true
  end

  newparam(:bootstrap_signing, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Indicates that the token may be used to sign the cluster-info ConfigMap'

    defaultto true
  end

  newproperty(:description) do
    desc 'Human readable description'
  end

  validate do
    id = self[:id]
    secret = self[:secret]
    return true if id && secret

    raise Puppet::Error, 'Both Token ID and Token Secret must be provided' if id || secret
  end
end

require 'shellwords'
require 'date'
require 'yaml'

Puppet::Type.type(:kubeadm_token).provide(:kubeadm) do
  @doc = 'Kubernetes bootstrap token provider'

  mk_resource_methods

  commands kubeadm: 'kubeadm'

  if command('kubeadm')
    confine true: begin
                    kubeadm('version')
                  rescue Puppet::ExecutionFailure
                    false
                  else
                    true
                  end
  end

  # Look up the current status.
  def properties
    @property_hash = { ensure: :absent } if @property_hash.empty?
    @property_hash.dup
  end

  def self.provider_command
    command(:kubeadm)
  end

  def self.kubeadm_command(bin = nil)
    cmd = Puppet::Util.which(bin) if bin
    @cmd = cmd ? cmd : provider_command
    @cmd
  end

  def self.kubeadm_caller(subcommand, *args)
    kubeadm_command unless @cmd

    cmdline = Shellwords.join(args)

    cmd = [@cmd, subcommand, cmdline].compact.join(' ')
    env = { 'KUBECONFIG' => '/etc/kubernetes/admin.conf' }

    Puppet::Util.withenv(env) do
      cmdout = Puppet::Util::Execution.execute(cmd)
      return nil if cmdout.nil?
      return nil if cmdout.empty?
      return cmdout
    end
  rescue Puppet::ExecutionFailure => detail
    Puppet.debug "Execution of #{@cmd} command failed: #{detail}"
    false
  end

  def self.provider_subcommand
    'token'
  end

  def self.provider_create(*args)
    kubeadm_caller(provider_subcommand, 'create', *args)
  end

  def self.provider_delete(*args)
    kubeadm_caller(provider_subcommand, 'delete', *args)
  end

  def self.get_list_array(subcommand, *moreargs)
    kubeadm_command unless @cmd

    args = ['list', '-o', 'yaml']
    args += moreargs

    cmdout = kubeadm_caller(subcommand, *args)
    return [] unless cmdout

    entity_list = cmdout.split('---').map do |e|
      YAML.safe_load(e)
    rescue Psych::SyntaxError
      false
    end

    entity_list.select { |e| e.is_a?(Hash) && e.any? }
  end

  def self.provider_list
    get_list_array(provider_subcommand)
      .sort_by { |e| (e['expires']) ? DateTime.parse(e['expires']) : DateTime.new(0) }
      .reverse
  end

  def self.add_instance(entity = {})
    @instances = [] unless @instances

    # name
    token = entity['token']
    @default_token ||= token

    id, secret = token.split('.', 2)
    entity_name = (@default_token == token) ? 'default' : "bootstrap-token-#{id}"

    if entity['expires']
      expiration = DateTime.parse(entity['expires'])
      current = DateTime.now
      duration = ((expiration - current) * 24 * 60 * 60).to_i

      hours = duration / 3600
      mins = duration % 3600 / 60
      secs = duration % 3600 % 60
      ttl = "#{hours}h#{mins}m#{secs}s"
    else
      ttl = 0
    end

    @instances << new(name: entity_name,
                      ensure: :present,
                      id: id,
                      secret: secret,
                      auth_extra_groups: entity['groups'],
                      description: entity['description'],
                      bootstrap_authentication: entity['usages'].include?('authentication'),
                      bootstrap_signing: entity['usages'].include?('signing'),
                      ttl: ttl,
                      provider: name)
  end

  def self.delete_instance(id)
    @instances.reject! { |i| i.id == id }
  end

  def self.instances
    return @instances if @instances

    kubeadm_command

    provider_list.each { |entity| add_instance(entity) }

    @instances || []
  end

  def self.prefetch(resources)
    entities = instances
    # rubocop:disable Lint/AssignmentInCondition
    resources.each_key do |entity_name|
      if provider = entities.find { |entity| entity.name == entity_name }
        resources[entity_name].provider = provider
      end
    end
    # rubocop:enable Lint/AssignmentInCondition
  end

  def create
    id       = @resource.value(:id)
    secret   = @resource.value(:secret)
    desc     = @resource.value(:description)
    duration = @resource.value(:ttl)
    groups   = @resource.value(:auth_extra_groups)

    groups =  case groups
              when nil, :absent, 'absent'
                nil
              else
                [groups].flatten
              end

    @property_hash[:description]       = desc     if desc
    @property_hash[:ttl]               = duration if duration
    @property_hash[:auth_extra_groups] = groups   if groups

    args = []
    args += ['--description', desc] if desc
    args += ['--ttl', duration] if duration
    # if auth_extra_groups is not set then kubeadm use default system:bootstrappers:kubeadm:default-node-token
    # therefore authentication usage is always set true
    args += ['--usages', 'authentication']
    args += ['--usages', 'signing'] if @resource.bootstrap_signing?

    if groups
      groups.each { |g| args += ['--groups', g] }
    end
    args += ["#{id}.#{secret}"] if id && secret

    cmdout = self.class.provider_create(*args)
    return unless cmdout

    id, secret = cmdout.split('.')
    return unless id && secret

    @property_hash[:id]              = id
    @property_hash[:secret]          = secret
    @property_hash[:name]            = "bootstrap-token-#{id}"
    @property_hash[:ensure]          = :present
  end

  def delete
    self.class.provider_delete(@property_hash[:id])
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end

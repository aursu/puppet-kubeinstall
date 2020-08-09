Puppet::Functions.create_function(:'kubeinstall::discovery_hosts', Puppet::Functions::InternalFunction) do
  dispatch :discovery_hosts_title do
    scope_param
    param 'String', :lookup_type
    optional_param 'Array', :equery
  end

  dispatch :discovery_hosts_param do
    scope_param
    param 'String', :lookup_type
    param 'String', :lookup_param
    optional_param 'Array', :equery
  end

  dispatch :discovery_hosts_list do
    scope_param
    param 'String', :lookup_type
    param 'Array[String]', :lookup_param
    optional_param 'Array', :equery
  end

  def exported_collector_collect(scope, lookup_type, equery = nil)
    resources = scope.compiler.resources.select { |r| r.type == lookup_type && r.exported? }

    # it makes no sense without PuppetDB
    # TODO: create YAML backend for Rspec tesing based on
    #       https://github.com/puppetlabs/puppet/blob/master/acceptance/tests/language/exported_resources.rb
    found = if Puppet[:storeconfigs]
              Puppet::Resource.indirection.search(lookup_type, host: scope.compiler.node.name, filter: equery, scope: scope)
            else
              []
            end

    found_resources = found.map { |x| x.is_a?(Puppet::Parser::Resource) ? x : x.to_resource(scope) }

    found_resources.each do |item|
      unless scope.findresource(item.resource_type, item.title)
        resources << item
      end
    end

    resources
  end

  # param [Array] equery an array representation of the query (exported query)
  def discovery_hosts_title(scope, lookup_type, equery = nil)
    resources = exported_collector_collect(scope, lookup_type, equery)
    resources.map { |r| r.title.to_s }
  end

  # param [Array] equery an array representation of the query (exported query)
  def discovery_hosts_param(scope, lookup_type, lookup_param, equery = nil)
    resources = exported_collector_collect(scope, lookup_type, equery)

    p = lookup_param.to_sym
    resources.reject { |r| r[p].nil? }.map { |r| r[p].to_s }
  end

  def discovery_hosts_list(scope, lookup_type, lookup_param, equery = nil)
    resources = exported_collector_collect(scope, lookup_type, equery)

    p = lookup_param.map { |n| n.to_sym }
    resources.reject { |r| r[p].nil? }.map do |r|
      p.map { |n| (n == :title) ? r.title.to_s : r[n].to_s }
    end
  end
end

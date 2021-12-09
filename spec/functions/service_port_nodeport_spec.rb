require 'spec_helper'

ports1_1 = [
  {
    'name' => 'console',
    'nodePort' => 31000,
    'port' => 9090,
    'protocol' => 'TCP',
    'targetPort' => 9090,
  },
]

describe 'kubeinstall::service_port_nodeport' do
  it {
    is_expected.to run.with_params(
      {
        'protocol' => 'UDP',
        'port' => 53,
        'targetPort' => 9376,
      },
      'NodePort',
    ).and_return({})
  }

  it {
    is_expected.to run.with_params(ports1_1[0], 'ClusterIP').and_return({})
  }

  it {
    is_expected.to run.with_params(ports1_1[0], 'NodePort').and_return({ 'nodePort' => 31000 })
  }
end

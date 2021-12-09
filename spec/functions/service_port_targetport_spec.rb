require 'spec_helper'

ports1 = [
  {
    'protocol' => 'UDP',
    'port' => 53,
    'targetPort' => 9376,
  },
]

ports1_1 = [
  {
    'name' => 'console',
    'nodePort' => 31000,
    'port' => 9090,
    'protocol' => 'TCP',
    'targetPort' => 9090,
  },
]

ports1_2 = [
  {
    'name' => 'minio',
    'nodePort' => 30000,
    'port' => 9000,
    'protocol' => 'TCP',
  },
]

describe 'kubeinstall::service_port_targetport' do
  it {
    is_expected.to run.with_params(ports1[0]).and_return({ 'targetPort' => 9376 })
  }

  it {
    is_expected.to run.with_params(ports1[0], 'None').and_return({})
  }

  it {
    is_expected.to run.with_params(ports1_1[0], '10.97.159.34').and_return({ 'targetPort' => 9090 })
  }

  it {
    is_expected.to run.with_params(ports1_2[0]).and_return({ 'targetPort' => 9000 })
  }

  it {
    is_expected.to run.with_params(ports1_2[0], '10.97.159.34').and_return({ 'targetPort' => 9000 })
  }
end

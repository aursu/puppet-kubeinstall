require 'spec_helper'

ports1 = [
  {
    'protocol' => 'TCP',
    'port' => 80,
    'targetPort' => 9376,
  },
]

ports1_1 = [
  {
    'name' => 'http',
    'protocol' => 'TCP',
    'port' => 80,
    'targetPort' => 9376,
  },
]

ports2 = [
  {
    'name' => 'http',
    'protocol' => 'TCP',
    'port' => 80,
    'targetPort' => 9376
  },
  {
    'name' => 'https',
    'protocol' => 'TCP',
    'port' => 443,
    'targetPort' => 9377
  },
]

ports2_1 = [
  {
    'name' => 'http',
    'protocol' => 'TCP',
    'port' => 80,
    'targetPort' => 9376
  },
  {
    'protocol' => 'TCP',
    'port' => 443,
    'targetPort' => 9377
  },
]

ports2_2 = [
  {
    'name' => 'http',
    'protocol' => 'TCP',
    'port' => 80,
    'targetPort' => 9376
  },
  {
    'name' => 'http',
    'protocol' => 'TCP',
    'port' => 443,
    'targetPort' => 9377
  },
]

describe 'kubeinstall::service_port_name' do
  it {
    is_expected.to run.with_params(ports1, ports1[0]).and_return({})
  }

  it {
    is_expected.to run.with_params(ports1_1, ports1_1[0]).and_return({ 'name' => 'http' })
  }

  it {
    is_expected.to run.with_params(ports2, ports2[0]).and_return({ 'name' => 'http' })
  }

  it {
    is_expected.to run.with_params(ports2, ports2[1]).and_return({ 'name' => 'https' })
  }

  it {
    is_expected.to run.with_params(ports2_1, ports2_1[1]).and_raise_error(%r{Optional if only one ServicePort is defined on this service})
  }

  it {
    is_expected.to run.with_params(ports2_2, ports2_2[1]).and_raise_error(%r{All ports within a ServiceSpec must have unique names})
  }
end

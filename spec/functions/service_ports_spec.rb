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
    'name' => 'console',
    'nodePort' => 31000,
    'port' => 9090,
    'protocol' => 'TCP',
    'targetPort' => 9090,
  },
  {
    'name' => 'minio',
    'nodePort' => 30000,
    'port' => 9000,
    'protocol' => 'TCP',
  },
]

describe 'kubeinstall::service_ports' do
  it {
    is_expected.to run.with_params(ports1, { 'type' => 'ClusterIP' }).and_return(ports1)
  }

  it {
    is_expected.to run.with_params(ports1_1, { 'type' => 'ClusterIP' }).and_return(ports1_1)
  }

  it {
    is_expected.to run.with_params(ports2_1, { 'type' => 'ClusterIP' }).and_raise_error(%r{Optional if only one ServicePort is defined on this service})
  }

  it {
    is_expected.to run.with_params(ports2_2, { 'type' => 'ClusterIP' }).and_return(
      [
        {
          'name' => 'console',
          'port' => 9090,
          'protocol' => 'TCP',
          'targetPort' => 9090,
        },
        {
          'name' => 'minio',
          'port' => 9000,
          'protocol' => 'TCP',
          'targetPort' => 9000,
        },
      ],
    )
  }

  it {
    is_expected.to run.with_params(ports2_2, { 'type' => 'NodePort' }).and_return(
      [
        {
          'name' => 'console',
          'nodePort' => 31000,
          'port' => 9090,
          'protocol' => 'TCP',
          'targetPort' => 9090,
        },
        {
          'name' => 'minio',
          'nodePort' => 30000,
          'port' => 9000,
          'protocol' => 'TCP',
          'targetPort' => 9000,
        },
      ],
    )
  }

  it {
    is_expected.to run.with_params(ports2_2, { 'type' => 'NodePort', 'cluster_ip' => 'None' }).and_return(
      [
        {
          'name' => 'console',
          'nodePort' => 31000,
          'port' => 9090,
          'protocol' => 'TCP',
        },
        {
          'name' => 'minio',
          'nodePort' => 30000,
          'port' => 9000,
          'protocol' => 'TCP',
        },
      ],
    )
  }
end

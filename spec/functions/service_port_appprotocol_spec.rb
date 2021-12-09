require 'spec_helper'

describe 'kubeinstall::service_port_appprotocol' do
  it {
    is_expected.to run.with_params(
      {
        'protocol' => 'UDP',
        'port' => 53,
        'targetPort' => 9376,
      },
    ).and_return({})
  }

  it {
    is_expected.to run.with_params(
      {
        'name' => 'console',
        'nodePort' => 31000,
        'port' => 9090,
        'protocol' => 'TCP',
        'targetPort' => 9090,
        'appProtocol' => 'https',
      },
    ).and_return({ 'appProtocol' => 'https' })
  }
end

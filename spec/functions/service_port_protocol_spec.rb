require 'spec_helper'

describe 'kubeinstall::service_port_protocol' do
  it {
    is_expected.to run.with_params(
      {
        'protocol' => 'UDP',
        'port' => 53,
        'targetPort' => 9376,
      },
    ).and_return({ 'protocol' => 'UDP' })
  }

  it {
    is_expected.to run.with_params(
      {
        'name' => 'http',
        'port' => 80,
        'targetPort' => 9376,
      },
    ).and_return({ 'protocol' => 'TCP' })
  }
end

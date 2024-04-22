require 'spec_helper'

describe 'Kubeinstall::LabelSelector' do
  it do
    is_expected.to allow_value(
      {
        'matchLabels' => {
          'release' => 'stable',
        },
        'matchExpressions' => [
          {
            'key' => 'environment',
            'operator' => 'In',
            'values' => ['dev'],
          },
        ],
      },
    )
  end

  it do
    is_expected.to allow_value(
      {
        'matchLabels' => {
          'component' => 'redis',
        },
        'matchExpressions' => [
          {
            'key' => 'tier',
            'operator' => 'In',
            'values' => ['cache'],
          },
          {
            'key' => 'environment',
            'operator' => 'NotIn',
            'values' => ['dev'],
          },
        ],
      },
    )
  end

  it do
    is_expected.to allow_value(
      {
        'matchExpressions' => [
          {
            'key' => 'topology.kubernetes.io/zone',
            'operator' => 'In',
            'values' => ['antarctica-east1', 'antarctica-west1'],
          },
        ],
      },
    )
  end

  it do
    is_expected.to allow_value(
      {
        'matchExpressions' => [
          {
            'key' => 'tenant',
            'operator' => 'Exists',
          },
        ],
      },
    )
  end

  it do
    is_expected.to allow_value(
      {
        'matchLabels' => {
          'app' => 'web-store',
        },
      },
    )
  end
end

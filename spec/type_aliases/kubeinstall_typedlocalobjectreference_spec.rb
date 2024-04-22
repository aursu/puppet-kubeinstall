require 'spec_helper'

describe 'Kubeinstall::TypedLocalObjectReference' do
  it {
    is_expected.to allow_value(
      {
        'name' => 'existing-src-pvc-name',
        'kind' => 'PersistentVolumeClaim',
      },
    )
  }

  it {
    is_expected.to allow_value(
      {
        'name'     => 'example-name',
        'kind'     => 'ExampleDataSource',
        'apiGroup' => 'example.storage.k8s.io',
      },
    )
  }

  it {
    is_expected.to allow_value(
      {
        'name'     => 'existing-src-pvc-name',
        'kind'     => 'PersistentVolumeClaim',
        'apiGroup' => 'core',
      },
    )
  }

  it {
    is_expected.not_to allow_value(
      {
        'name' => 'example-name',
        'kind' => 'ExampleDataSource',
      },
    )
  }
end

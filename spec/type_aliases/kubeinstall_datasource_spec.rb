require 'spec_helper'

describe 'Kubeinstall::DataSource' do
  # PersistentVolumeClaim in core implied
  it {
    is_expected.to allow_value(
      {
        'name' => 'existing-src-pvc-name',
        'kind' => 'PersistentVolumeClaim',
      },
    )
  }

  # VolumeSnapshot in its correct API group
  it {
    is_expected.to allow_value(
      {
        'name'     => 'new-snapshot-test',
        'kind'     => 'VolumeSnapshot',
        'apiGroup' => 'snapshot.storage.k8s.io',
      },
    )
  }

  # PersistentVolumeClaim in core explicitly
  it {
    is_expected.to allow_value(
      {
        'name'     => 'existing-src-pvc-name',
        'kind'     => 'PersistentVolumeClaim',
        'apiGroup' => 'core',
      },
    )
  }

  # any
  it {
    is_expected.not_to allow_value(
      {
        'name'     => 'example-name',
        'kind'     => 'ExampleDataSource',
        'apiGroup' => 'example.storage.k8s.io',
      },
    )
  }

  # non-PersistentVolumeClaim in core
  it {
    is_expected.not_to allow_value(
      {
        'name' => 'example-name',
        'kind' => 'ExampleDataSource',
      },
    )
  }

  # PersistentVolumeClaim not in core
  it {
    is_expected.not_to allow_value(
      {
        'name'     => 'existing-src-pvc-name',
        'kind'     => 'PersistentVolumeClaim',
        'apiGroup' => 'snapshot.storage.k8s.io',
      },
    )
  }

  # VolumeSnapshot in wrong API group
  it {
    is_expected.not_to allow_value(
      {
        'name'     => 'new-snapshot-test',
        'kind'     => 'VolumeSnapshot',
        'apiGroup' => 'core'
      },
    )
  }

  # VolumeSnapshot in empty API group
  it {
    is_expected.not_to allow_value(
      {
        'name'     => 'new-snapshot-test',
        'kind'     => 'VolumeSnapshot',
        'apiGroup' => ''
      },
    )
  }
end

require 'spec_helper'

describe 'Kubeinstall::DataSourceRef' do
  # PersistentVolumeClaim in core implied
  it {
    is_expected.to allow_value(
      {
        'name' => 'existing-src-pvc-name',
        'kind' => 'PersistentVolumeClaim',
      },
    )
  }

  # PersistentVolumeClaim in core implicitly with namespace
  it {
    is_expected.to allow_value(
      {
        'name'      => 'existing-src-pvc-name',
        'kind'      => 'PersistentVolumeClaim',
        'namespace' => 'minio',
      },
    )
  }

  # VolumeSnapshot in its correct API group
  it {
    is_expected.to allow_value(
      {
        'name'     => 'new-snapshot-test',
        'kind'     => 'VolumeSnapshot',
        'apiGroup' => 'snapshot.storage.k8s.io'
      },
    )
  }

  # VolumeSnapshot in its correct API group with namespace
  it {
    is_expected.to allow_value(
      {
        'name'      => 'new-snapshot-test',
        'kind'      => 'VolumeSnapshot',
        'apiGroup'  => 'snapshot.storage.k8s.io',
        'namespace' => 'minio',
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

  # VolumeSnapshot in wrong API group (must not!!)
  it {
    is_expected.not_to allow_value(
      {
        'name'     => 'new-snapshot-test',
        'kind'     => 'VolumeSnapshot',
        'apiGroup' => 'core'
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

  # VolumeSnapshot in empty API group
  it {
    is_expected.not_to allow_value(
      {
        'name'     => 'new-snapshot-test',
        'kind'     => 'VolumeSnapshot',
        'apiGroup' => '',
      },
    )
  }
end

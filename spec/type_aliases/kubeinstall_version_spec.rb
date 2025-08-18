require 'spec_helper'

describe 'Kubeinstall::Version' do
  # Test allowed versions
  it { is_expected.to allow_value('1.29.10') }
  it { is_expected.to allow_value('1.30.9') }
  it { is_expected.to allow_value('1.30.14') }
  it { is_expected.to allow_value('1.33.4') }

  # Test rejected version
  it { is_expected.not_to allow_value('1.30.15') }

  # Test some edge cases to ensure the pattern works correctly
  it { is_expected.not_to allow_value('1.30.16') }
  it { is_expected.not_to allow_value('1.29.15') }
  it { is_expected.not_to allow_value('1.33.5') }

  # Test invalid formats
  it { is_expected.not_to allow_value('1.29') }
  it { is_expected.not_to allow_value('1.29.10.1') }
  it { is_expected.not_to allow_value('invalid') }
  it { is_expected.not_to allow_value('') }
end

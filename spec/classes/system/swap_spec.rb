# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::system::swap' do
  on_supported_os.each do |os, os_facts|
    unless os_facts[:memory]
      os_facts[:memory] = {
        'swap' => {
          'available' => '17.70 GiB',
          'available_bytes' => 19000193024,
          'capacity' => '0%',
          'total' => '17.70 GiB',
          'total_bytes' => 19000193024,
          'used' => '0 bytes',
          'used_bytes' => 0,
        },
        'system' => {
          'available' => '31.12 GiB',
          'available_bytes' => 33416249344,
          'capacity' => '11.55%',
          'total' => '35.18 GiB',
          'total_bytes' => 37779361792,
          'used' => '4.06 GiB',
          'used_bytes' => 4363112448,
        },
      }
    end

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_exec('swapoff -a')
      }
    end
  end
end

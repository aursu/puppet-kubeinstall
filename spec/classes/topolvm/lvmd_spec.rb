# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::topolvm::lvmd' do
  let(:pre_condition) { 'include kubeinstall' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_file('/etc/topolvm/lvmd.yaml')
          .with_content(%r{^\s*socket-name: "/run/topolvm/lvmd.sock"$})
          .with_content(%r{^\s*device-classes: \[\]$})
      }

      context 'when config specified with device classes' do
        let(:params) do
          {
            device_classes: [
              {
                'name'        => 'ssd',
                'volumeGroup' => 'myvg1',
                'isDefault'   => true,
                'spareGB'     => 10,
              },
              {
                'name'        => 'ssd-thin',
                'volumeGroup' => 'myvg1',
                'type'        => 'thin',
                'thinPool'    => {
                  'name' => 'thinpool',
                  'overprovisionRatio' => 10.0,
                },
              },
            ]
          }
        end

        it {
          is_expected.to contain_file('/etc/topolvm/lvmd.yaml')
            .with_content(%r{^\s*socket-name: "/run/topolvm/lvmd.sock"$})
            .with_content(%r{volume-group: myvg1})
            .with_content(%r{default: true})
            .with_content(%r{spare-gb: 10})
            .with_content(%r{overprovision-ratio: 10.0})
        }
      end
    end
  end
end

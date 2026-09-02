# frozen_string_literal: true

require 'spec_helper'

describe 'kubeinstall::repos::cleanup' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      debian = os.match?(%r{^(ubuntu|debian)-})

      it { is_expected.to compile.with_all_deps }

      context 'with default parameters' do
        if debian
          # The cri-o source carries the release in its name, and which release
          # a host was built on varies, so it is matched rather than named.
          it {
            is_expected.to contain_tidy('kubic-apt-sources')
              .with_path('/etc/apt/sources.list.d')
              .with_matches(['devel:kubic:libcontainers*'])
              .with_recurse(1)
          }

          it {
            is_expected.to contain_file('/etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg')
              .with_ensure('absent')
          }

          it { is_expected.not_to contain_tidy('kubic-yum-repos') }
        else
          it {
            is_expected.to contain_tidy('kubic-yum-repos')
              .with_path('/etc/yum.repos.d')
              .with_matches(['devel_kubic_libcontainers_stable*'])
              .with_recurse(1)
          }

          it { is_expected.not_to contain_tidy('kubic-apt-sources') }
          it { is_expected.not_to contain_file('/etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg') }
        end
      end

      # A host genuinely running cri-o older than 1.28.2 still has these
      # declared for real by kubeinstall::repos::crio, so the cleanup has to be
      # switchable off rather than unconditional.
      context 'when kubic cleanup is disabled' do
        let(:params) { { 'kubic' => false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_tidy('kubic-apt-sources') }
        it { is_expected.not_to contain_tidy('kubic-yum-repos') }
        it { is_expected.not_to contain_file('/etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg') }
      end
    end
  end
end

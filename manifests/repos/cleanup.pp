# @summary Remove package repositories this module no longer uses
#
# Puppet removes only what it is told to remove: a repository that a manifest
# once declared and no longer declares is not cleaned up, it is simply forgotten
# and left on disk forever. This class is where those forgotten repositories are
# named so they actually go.
#
# ## The kubic repositories
#
# CRI-O used to be packaged in openSUSE's `devel:kubic:libcontainers:stable`
# project. That is discontinued: packaging moved to the cri-o project's own
# repositories, and `kubeinstall::repos::crio` follows it — `isv:/cri-o:/stable`
# from 1.33.0, `pkgs.k8s.io/addons:/cri-o:/stable` from 1.28.2, and kubic only
# in the `else` branch for anything older.
#
# So on any host built when cri-o was older than 1.28.2, the kubic sources are
# still on disk while the module now declares an entirely different repository.
# Measured on this estate: hosts carried
# `devel:kubic:libcontainers:stable.list` and, on some,
# `devel:kubic:libcontainers:stable:cri-o:1.28.list`, alongside the live
# `isv:/cri-o:/stable:/v1.33` source.
#
# ⚠ **This is not cosmetic.** The kubic packages carry **epoch 100**, chosen so
# they always beat the distribution's. Epoch dominates Debian version
# comparison, so `100:2.48-1` outranks noble's `1:2.66-5ubuntu2.4`: apt will not
# replace them, dependencies are satisfied on epoch alone while the library is
# actually older than the binaries linked against it, and one of the packages
# involved is `libpam-cap` — a stale PAM module under a different glibc is one
# of the few reliable ways to lose SSH authentication on a running host. Two
# hosts here are already in that state and cannot be upgraded to 24.04 until it
# is cleared.
#
# The 22.04 flavour of the repository also **404s for 24.04**, so a host that
# has been through a release upgrade is carrying a source that cannot resolve.
#
# ℹ **Removing the repository does not remove packages already installed from
# it.** That is deliberate: downgrading `libcap2`, `libcap2-bin` and
# `libpam-cap` back to the distribution version is a separate, gated operation
# that has to be verified against SSH and systemd before an OS upgrade. What
# this class does is stop the source feeding any *new* epoch-100 package onto a
# host, and stop `apt update` reaching for a repository nothing wants.
#
# @param kubic
#   Remove the `devel:kubic:libcontainers` sources and their keyring. Default
#   `true`; set `false` on a host still genuinely running cri-o older than
#   1.28.2, where `kubeinstall::repos::crio` declares them for real.
#
# @example Default, from the Kubernetes node profile
#   include kubeinstall::repos::cleanup
#
# @example Keep them on a host still on an old cri-o
#   class { 'kubeinstall::repos::cleanup':
#     kubic => false,
#   }
class kubeinstall::repos::cleanup (
  Boolean $kubic = true,
) {
  if $kubic {
    case $facts['os']['family'] {
      'Debian': {
        # The cri-o source carries the release in its name -
        # `...:cri-o:1.28.list` on one host, absent on another - so the versioned
        # one is matched rather than named. `tidy` is the right tool here: a
        # `file` resource cannot glob, and the alternative is enumerating every
        # cri-o release the estate has ever run.
        tidy { 'kubic-apt-sources':
          path    => '/etc/apt/sources.list.d',
          matches => ['devel:kubic:libcontainers*'],
          recurse => 1,
        }

        # Not shared with anything: the newer repositories ship their own
        # `cri-o-v<release>-apt-keyring.gpg`.
        file { '/etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg':
          ensure => absent,
        }
      }
      'RedHat': {
        tidy { 'kubic-yum-repos':
          path    => '/etc/yum.repos.d',
          matches => ['devel_kubic_libcontainers_stable*'],
          recurse => 1,
        }
      }
      default: {}
    }
  }
}

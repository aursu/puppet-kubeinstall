# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @param chart_name
#   chart reference (eg rook-release/rook-ceph) or chart name (eg rook-ceph)
#   If provided as chart name then `repo_name` must be set.
#   If provided as chart reference then repo name from reference will have
#   higher priority over `repo_name`
#
# @param repo_name
#   Helm repository name. If specified then `chart_name` could contain only
#   chart name
#
# @param release_name
#   corresponds to NAME parameter ofr command `helm install`
#
# @example
#   kubeinstall::helm::chart { 'namevar': }
define kubeinstall::helm::chart (
  String  $chart_name       = $name,
  Optional[String[1]]
          $repo_name        = undef,
  Optional[String]
          $release_name     = undef,
  String[1]
          $namespace        = 'default',
  Boolean $create_namespace = false,
  Optional[Stdlib::HTTPUrl]
          $repo_url         = undef,
  Stdlib::Unixpath
          $cwd              = '/root',
  Optional[String]
          $chart_version    = undef,
  Variant[Kubeinstall::Path, Array[Kubeinstall::Path]]
          $values           = [],
  Hash[String, String]
          $set_values       = {},
) {

  # There are five different ways you can express the chart you want to install:
  # 1. By chart reference: helm install mymaria example/mariadb
  # 2. By path to a packaged chart: helm install mynginx ./nginx-1.2.3.tgz
  # 3. By path to an unpacked chart directory: helm install mynginx ./nginx
  # 4. By absolute URL: helm install mynginx https://example.com/charts/nginx-1.2.3.tgz
  # 5. By chart reference and repo url: helm install --repo https://example.com/charts/ mynginx nginx

  $chart_info = split($chart_name, '/')
  if $chart_info[0] =~ String[1] and $chart_info[1] =~ String[1] {
    # chart reference
    $chart_ref = $chart_name
    $repo = $chart_info[0]
    $chart = $chart_info[1]
    $repo_param = undef
  }
  else {
    if $repo_name {
      $chart_ref = "${repo_name}/${chart_name}"
      $repo = $repo_name
      $repo_param = undef
    }
    elsif $repo_url {
      $chart_ref = $chart_name
      $repo  = undef
      $repo_param = " --repo ${repo_url}"
    }
    else {
      fail('Helm chart is not defined properly.')
    }
    $chart = $chart_name
  }

  if $release_name {
    $release_param = undef
    $release = "${release_name} "
  }
  else {
    $release_param = ' --generate-name'
    $release = undef
  }

  if $namespace == 'default' {
    $namespace_param = undef
    $namespace_create = undef
  }
  else {
    $namespace_param = " --namespace ${namespace}"
    if $create_namespace {
      $namespace_create = ' --create-namespace'
    }
    else {
      $namespace_create = undef
    }
  }

  if $values =~ String {
    $values_array = [ $values ]
  }
  else {
    $values_array = $values
  }
  $values_param = $values_array.reduce(undef) |$memo, $value| { "${memo} -f ${value}" }

  $set_params = $set_values.reduce(undef) |$memo, $value| { "${memo} --set ${value[0]}=${value[1]}" }

  if $chart_version {
    $version_param = " --version ${chart_version}"
  }
  else {
    $version_param = undef
  }

  $exec_command = "helm install ${release}${chart_ref}${repo_param}${release_param}${namespace_param}${namespace_create}${version_param}${values_param}${set_params}"

  if $release_name {
    $unless_command = [
      "helm list -o json${namespace_param} | grep '\"chart\":\"${chart}' | grep '\"name\":\"${release_name}\"'"
    ]
  }
  else {
    $unless_command = [
      "helm list -o json${namespace_param} | grep '\"chart\":\"${chart}' | grep '\"name\":\"${chart}-'"
    ]
  }

  exec { $exec_command:
    path        => '/usr/local/bin:/usr/bin:/bin',
    cwd         => $cwd,
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    unless      => $unless_command,
  }

  if $repo {
    Kubeinstall::Helm::Repo[$repo] -> Exec[$exec_command]
  }

  if $namespace_param {
    unless $namespace_create {
      Kubeinstall::Resource::Ns[$namespace] -> Exec[$exec_command]
    }
  }
}

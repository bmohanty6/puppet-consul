# == Class: consul
#
# Installs, configures, and manages consul
#
# === Parameters
#
# [*version*]
#   Specify version of consul binary to download.
#
# [*join_cluster*]
#   Specify the hostname or IP of a known consul node, likely the original.  Defaults to 'UNSET'
#
# [*config_hash*]
#   Use this to populate the JSON config file for consul.
#
# [*install_method*]
#   Defaults to `url` but can be `package` if you want to install via a system package.
#
# [*package_name*]
#   Only valid when the install_method == package. Defaults to `consul`.
#
# [*package_ensure*]
#   Only valid when the install_method == package. Defaults to `latest`.
#
# [*ui_package_name*]
#   Only valid when the install_method == package. Defaults to `consul_ui`.
#
# [*ui_package_ensure*]
#   Only valid when the install_method == package. Defaults to `latest`.
#
# [*extra_options*]
#   Extra arguments to be passed to the consul agent
#
# [*init_style*]
#   What style of init system your system uses.
#
# [*purge_config_dir*]
#   Purge config files no longer generated by Puppet
class consul (
  $manage_user       = true,
  $user              = 'consul',
  $manage_group      = true,
  $purge_config_dir  = true,
  $group             = 'consul',
  $join_cluster      = false,
  $join_wan          = false,
  $bin_dir           = '/usr/local/bin',
  $arch              = $consul::params::arch,
  $version           = $consul::params::version,
  $install_method    = $consul::params::install_method,
  $download_url      = "https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_${arch}.zip",
  $package_name      = $consul::params::package_name,
  $package_ensure    = $consul::params::package_ensure,
  $ui_download_url   = "https://releases.hashicorp.com/consul/${version}/consul_${version}_web_ui.zip", 
  $ui_package_name   = $consul::params::ui_package_name,
  $ui_package_ensure = $consul::params::ui_package_ensure,
  $config_dir        = '/etc/consul',
  $extra_options     = '',
  $config_hash       = {},
  $service_enable    = true,
  $service_ensure    = 'running',
  $init_style        = $consul::params::init_style,
) inherits consul::params {

  validate_bool($purge_config_dir)
  validate_bool($manage_user)
  validate_hash($config_hash)

  if $config_hash['data_dir'] {
    $data_dir = $config_hash['data_dir']
  }

  if $config_hash['ui_dir'] {
    $ui_dir = $config_hash['ui_dir']
  }

  if ($ui_dir and ! $data_dir) {
    warning('data_dir must be set to install consul web ui')
  }

  class { 'consul::install': } ->
  class { 'consul::config':
    purge => $purge_config_dir
  } ~>
  class { 'consul::run_service': } ->
  Class['consul']

}

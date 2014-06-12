#
# This base Puppetfile can be used to download
# the base deps for simple openstack deployments.
#


# let people override to use https
git_protocol=ENV['git_protocol'] || 'git'
# make selection of version configurable
# it defaults to nil (which will use master)
openstack_version=ENV['openstack_version']

unless ['havana', 'icehouse', nil].include?(openstack_version)
  abort("Only havana, and icehouse are currently supported")
end

openstack_module_branch = openstack_version ? "stable/#{openstack_version}" : 'master'

branch_name     = 'master'
mysql_branch    = '2.2.x'
rabbitmq_branch = '2.x'

base_url = "#{git_protocol}://github.com"

###### module under development #####

# this following modules are still undergoing their initial development
# and have not yet been ported to CiscoSystems.

mod 'bodepd/scenario_node_terminus',
  :git => 'https://github.com/bodepd/scenario_node_terminus'
mod 'puppetlabs/postgresql',
  :git => "#{base_url}/puppetlabs/puppetlabs-postgresql",
  :ref => '2.5.0'
mod 'puppetlabs/puppetdb',
  :git => "#{base_url}/puppetlabs/puppetlabs-puppetdb",
  :ref => '2.0.0'
mod 'puppetlabs/vcsrepo',
  :git => "#{base_url}/puppetlabs/puppetlabs-vcsrepo",
  :ref => '0.1.2'
mod 'ripienaar/ruby-puppetdb',
  :git => "#{base_url}/ripienaar/ruby-puppetdb"
mod 'ripienaar/catalog-diff',
  :git => "#{base_url}/ripienaar/puppet-catalog-diff",
  :ref => 'master'
mod 'puppetlabs/firewall',
  :git => "#{base_url}/puppetlabs/puppetlabs-firewall",
  :ref => '0.4.0'
mod 'stephenjohrnson/puppet',
  :git => "#{base_url}/stephenrjohnson/puppetlabs-puppet",
  :ref => '0.0.18'

###### stackforge openstack modules #####

[
  'cinder',
  'glance',
  'keystone',
  'horizon',
  'nova',
  'neutron',
  'swift',
  'tempest',
  'heat',
  'ceilometer',
  'vswitch',
].each do |module_name|
  mod "stackforge/#{module_name}",
    :git => "#{base_url}/stackforge/puppet-#{module_name}",
    :ref => openstack_module_branch
end

# things that I am temporarily hosting
[
  'openstacklib',
  'openstack_extras'
].each do |module_name|
  mod "stackforge/#{module_name}",
    :git => "#{base_url}/bodepd/puppet-#{module_name}",
    :ref => openstack_module_branch
end

##### Puppet Labs modules #####

[
  'apt',
  'stdlib',
  'xinetd',
  'ntp',
  'rsync',
  'inifile',
  'mongodb',
  'mysql',
  'rabbitmq',
  'apache',
  'concat'
].each do |module_name|
  begin
    ref = eval("#{module_name}_branch")
  rescue NameError
    ref = 'master'
  end
  mod "puppetlabs/#{module_name}",
    :git => "#{base_url}/puppetlabs/puppetlabs-#{module_name}",
    :ref => ref
end

##### modules with other upstreams #####

mod 'saz/memcached',
  :git => "#{base_url}/saz/puppet-memcached",
  :ref => 'master'
mod 'saz/ssh',
  :git => "#{base_url}/bodepd/puppet-ssh",
  :ref => 'master'
mod 'duritong/sysctl',
  :git => "#{base_url}/duritong/puppet-sysctl",
  :ref => 'master'

# load a Puppetfile that can override things
localdir = File.expand_path(File.join(File.dirname(__FILE__)))
path     = File.join(localdir, 'builder_overrides', 'Puppetfile')
if File.exists?(path)
  eval(File.read(path))
end

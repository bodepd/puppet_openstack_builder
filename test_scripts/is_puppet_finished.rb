#! /usr/bin/env ruby
#
# figure out if Puppet has installed openstack, and if it was successful.
#
#

require 'timeout'
require 'yaml'

# wait 15 minutes for everything to finish
# it's a little it long, but I can tune later
status = Timeout::timeout(9000) do
  run_summary_file = '/var/lib/puppet/state/last_run_summary.yaml'
  # first wait until a Pupet run has completed
  while(! File.exists?(run_summary_file)) do
    sleep 5
  end
  # fail if the latest Puppet run has failures
  run_yaml = YAML.load_file(run_summary_file)
  #
  # we will set config version to 0 so that we can make sure it is the correct run
  #
  while(run_yaml['version']['config'] != 'heat_puppet_run') do
    raise(Exception, 'Last Puppet run has failures') if run_yaml['events']['failure'] != 0
    sleep 5
    run_yaml = YAML.load_file(run_summary_file)
  end
  raise(Exception, 'Last Puppet run has failures') if run_yaml['events']['failure'] != 0

end

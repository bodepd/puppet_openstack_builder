#!/usr/bin/env ruby
for i in `heat stack-show puppet_integration_2014-07-15_14-29-57 | grep output_value`; do
  if [[ $i =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    ip=`echo $i | awk -F'"' '{print $2}'`
    echo $ip
    ssh root@$ip -i /home/jenkins-slave/.ssh/id_rsa -o StrictHostKeyChecking=no "ruby -e \"require 'yaml';exit 1 if YAML.load_file('/var/lib/puppet/state/last_run_summary.yaml')['events']['failure'] != 0\""
  fi
done

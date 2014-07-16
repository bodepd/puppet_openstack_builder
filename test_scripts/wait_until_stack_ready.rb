#!/usr/bin/env ruby

require 'timeout'

name=ARGV[0] || raise(Exception, 'stack name must be passed as an argument')

def stack_complete?(name)
  result = `heat stack-list | grep #{name}`.split(/\n/)
  unless result.size == 1
    raise("Expected one result from stack-list for #{name}, found: #{result.size}")
  end
  result.first.split(/\s*\|\s*/)[3] == 'CREATE_COMPLETE'
end

def remote_script
  File.join(File.dirname(__FILE__), 'is_puppet_finished.rb')
end

Timeout::timeout(600) do

  # sleep until stack is in a ready state
  while( ! stack_complete?(name)) do
    sleep 5
  end

  # get all ip addresses and run a remote command to see if Puppet is ready
  `heat stack-show #{name} | grep output_value`.split(/\n/).each do |l|
    if l =~ /output_value\":\s*\"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/
      puts "Checking to see when Puppet is finished on node: #{$1}"
      out = `ssh root@#{$1} -i /home/jenkins-slave/.ssh/id_rsa -o StrictHostKeyChecking=no ruby < #{remote_script}`
      puts out
    end
  end

end

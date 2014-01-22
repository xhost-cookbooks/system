#
# Cookbook Name:: system
# Provider:: hostname
#
# Copyright 2012-2014, Chris Fordham
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

action :set do

  require 'socket'

  def local_ip
    # turn off reverse DNS resolution temporarily
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
    ensure
      Socket.do_not_reverse_lookup = orig
  end

  # get node IP
  node_ip = local_ip
  log("Node IP: #{node_ip}") { level :debug }

  # ensure the required short hostname is lower case
  new_resource.short_hostname.downcase!

  # set hostname from short or long (when domain_name set)
  if new_resource.domain_name
    hostname = "#{new_resource.short_hostname}.#{new_resource.domain_name}"
    hosts_list = "#{new_resource.short_hostname}.#{new_resource.domain_name} #{new_resource.short_hostname}"
  else
    hostname = new_resource.short_hostname
    hosts_list = new_resource.short_hostname
  end
  log("Setting hostname for '#{hostname}'.") { level :debug }

  # Update /etc/hosts
  log('Configure /etc/hosts.') { level :debug }
  template '/etc/hosts' do
    source 'hosts.erb'
    variables(
      :node_ip => node_ip,
      :hosts_list => hosts_list,
      :static_hosts => new_resource.static_hosts
      )
    mode 0744
  end

  # Update /etc/hostname
  log('Configure /etc/hostname') { level :debug }
  file '/etc/hostname' do
    owner 'root'
    group 'root'
    mode 0755
    content new_resource.short_hostname
    action :create
  end

  # Call hostname command
  log('Setting hostname.') { level :debug }
  if platform?('centos', 'redhat')
    bash 'set hostname' do
      code <<-EOH
        sed -i "s/HOSTNAME=.*/HOSTNAME=#{hostname}/" /etc/sysconfig/network
        hostname #{hostname}
      EOH
    end
  else
    bash 'set hostname' do
      code <<-EOH
        hostname #{hostname}
      EOH
    end
  end

  # run domainname command if available
  execute 'run domainname' do
    command "domainname #{new_resource.domain_name}"
    only_if "bash -c 'type -P domainname'"
  end

  # restart hostname services on appropriate platforms
  if platform?('ubuntu')
    log('Starting hostname service.') { level :debug }
    service 'hostname' do
      service_name 'hostname'
      supports :restart => true, :status => true, :reload => true
      action :restart
    end
  end
  if platform?('debian')
    log('Starting hostname.sh service.') { level :debug }
    service 'hostname.sh' do
      service_name 'hostname.sh'
      supports :restart => false, :status => true, :reload => false
      action :start
    end
  end

  # rightlink command line tools set tag with rs_tag
  script 'set node hostname tag' do
    interpreter 'bash'
    user 'root'
    code <<-EOH
      if type -P rs_tag &>/dev/null; then
        rs_tag --add 'node:hostname=#{hostname}'
      fi
    EOH
  end

  # reload ohai hostname plugin for subsequent recipes in the run_list, or not
  # (http://bit.ly/1bfjHH5)
  # ohai "reload_hostname_info_from_ohai" do
  #   plugin "hostname"
  # end

  # manually update node & automatic attributes (probably won't do anything heh)
  fqdn = Mixlib::ShellOut.new('hostname -f').run_command.stdout.strip
  node.automatic_attrs['hostname'] = fqdn
  node.automatic_attrs['fqdn'] = fqdn
  node.set['fqdn'] = fqdn
  node.set['hostname'] = fqdn

  # node.save

  # Show the new host/node information
  ruby_block 'show host info' do
    block do
      hostname = Mixlib::ShellOut.new('hostname').run_command.stdout.strip
      network_node = Mixlib::ShellOut.new('uname -n').run_command.stdout.strip
      host_aliases = Mixlib::ShellOut.new('hostname -a').run_command.stdout.strip
      short_name = Mixlib::ShellOut.new('hostname -s').run_command.stdout.strip
      domain_name = Mixlib::ShellOut.new('hostname -d').run_command.stdout.strip
      fqdn = Mixlib::ShellOut.new('hostname -f').run_command.stdout.strip
      host_ip = Mixlib::ShellOut.new('hostname -i').run_command.stdout.strip
      Chef::Log.info('== New host/node information ==')
      Chef::Log.info("Hostname: #{hostname == '' ? '<none>' : hostname}")
      Chef::Log.info("Network node hostname: #{network_node == '' ? '<none>' : network_node}")
      Chef::Log.info("Alias names of host: #{host_aliases == '' ? '<none>' : host_aliases}")
      Chef::Log.info("Short host name (cut from first dot of hostname): #{short_name == '' ? '<none>' : short_name.strip}")
      Chef::Log.info("Domain of hostname: #{domain_name == '' ? '<none>' : domain_name}")
      Chef::Log.info("FQDN of host: #{fqdn == '' ? '<none>' : fqdn}")
      Chef::Log.info("IP addresses for the hostname: #{host_ip == '' ? '<none>' : host_ip}")
      Chef::Log.info("Current Chef FQDN loaded from Ohai: #{node['fqdn']}")
    end
  end

  new_resource.updated_by_last_action(true)

end # close action :set

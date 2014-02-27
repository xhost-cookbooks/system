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

# include the HostInfo library
class Chef::Recipe
  include HostInfo
  include GetIP
end

action :set do

  # ensure the required short hostname is lower case
  new_resource.short_hostname.downcase!

  fqdn = "#{new_resource.short_hostname}.#{new_resource.domain_name}"

  template '/etc/hosts' do
    source 'hosts.erb'
    variables(
      :node_ip => GetIP.local,
      :hosts_list => "#{fqdn} #{new_resource.short_hostname}",
      :static_hosts => new_resource.static_hosts
      )
    mode 0744
  end

  # Restart the hostname[.sh] service on debian-based distros
  if platform_family?('debian')
    case node['platform']
    when 'debian'
      service_name = 'hostname.sh'
      service_supports = {
        :restart => false,
        :status => true,
        :reload => false
      }
      service_action 'start'
      service_provider = Chef::Provider::Service::Init::Debian
    when 'ubuntu'
      service_name = 'hostname'
      service_supports = {
        :restart => true,
        :status => true,
        :reload => true
      }
      service_action = 'restart'
      service_provider = Chef::Provider::Service::Upstart
    end

    service 'hostname' do
      service_name service_name
      supports service_supports
      provider service_provider
      action :nothing
    end
  end

  # let's not manage the entire file because its shared (TODO: upgrade to chef-edit)
  execute 'update network sysconfig' do
    command "sed -i 's/HOSTNAME=.*/HOSTNAME=#{fqdn}/' /etc/sysconfig/network"
    only_if { platform_family?('redhat') }
    action :nothing
  end

  execute 'run hostname' do
    command "hostname #{fqdn}"
    not_if { platform_family?('debian') }
    action :nothing
  end

  # run domainname command if available
  execute 'run domainname' do
    command "domainname #{new_resource.domain_name}"
    only_if "bash -c 'type -P domainname'"
    action :nothing
  end

  # Show the new host/node information
  ruby_block 'show host info' do
    block do
      Chef::Log.info('== New host/node information ==')
      Chef::Log.info("Hostname: #{HostInfo.hostname == '' ? '<none>' : HostInfo.hostname}")
      Chef::Log.info("Network node hostname: #{HostInfo.network_node == '' ? '<none>' : HostInfo.network_node}")
      Chef::Log.info("Alias names of host: #{HostInfo.host_aliases == '' ? '<none>' : HostInfo.host_aliases}")
      Chef::Log.info("Short host name (cut from first dot of hostname): #{HostInfo.short_name == '' ? '<none>' : HostInfo.short_name}")
      Chef::Log.info("Domain of hostname: #{HostInfo.domain_name == '' ? '<none>' : HostInfo.domain_name}")
      Chef::Log.info("FQDN of host: #{HostInfo.fqdn == '' ? '<none>' : HostInfo.fqdn}")
      Chef::Log.info("IP addresses for the hostname: #{HostInfo.host_ip == '' ? '<none>' : HostInfo.host_ip}")
      Chef::Log.info("Current Chef FQDN loaded from Ohai: #{node['fqdn']}")
    end
    action :nothing
  end

  file '/etc/hostname' do
    owner 'root'
    group 'root'
    mode 0755
    content fqdn
    action :create
    notifies service_action.to_sym, resources("service[#{service_name}]") if platform_family?('debian')
    notifies :run, 'execute[update network sysconfig]', :immediately
    notifies :run, 'execute[run domainname]', :immediately
    notifies :run, 'execute[run hostname]', :immediately
    notifies :create, 'ruby_block[show host info]', :delayed
  end

  # rightscale support: rightlink CLI tools, rs_tag
  execute 'set rightscale server hostname tag' do
    command "rs_tag --add 'node:hostname=#{fqdn}'"
    only_if "bash -c 'type -P rs_tag'"
  end

  new_resource.updated_by_last_action(true)

end # close action :set

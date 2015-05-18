# encoding: UTF-8
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

# represents Chef
class Chef
  # include the HostInfo and GetIP libraries
  class Recipe
    include HostInfo
    include GetIP
  end
end

action :set do
  # ensure the required short hostname is lower case
  new_resource.short_hostname.downcase!

  fqdn = "#{new_resource.short_hostname}.#{new_resource.domain_name}"

  # https://tickets.opscode.com/browse/OHAI-389
  # http://lists.opscode.com/sympa/arc/chef/2014-10/msg00092.html
  node.automatic_attrs['fqdn'] = fqdn
  node.automatic_attrs['hostname'] = new_resource.short_hostname

  if platform_family?('mac_os_x')
    execute 'set configd parameter: HostName' do
      command "scutil --set HostName #{fqdn}"
      not_if { Mixlib::ShellOut.new('scutil --get HostName').run_command.stdout.strip == fqdn }
      notifies :create, 'ruby_block[show host info]', :delayed
    end

    shorthost_params = %w(ComputerName LocalHostName)
    shorthost_params.each do |param|
      execute "set configd parameter: #{param}" do
        command "scutil --set #{param} #{new_resource.short_hostname}"
        not_if { Mixlib::ShellOut.new("scutil --get #{param}").run_command.stdout.strip == new_resource.short_hostname }
        notifies :create, 'ruby_block[show host info]', :delayed
      end
    end

    smb_params = %w(NetBIOSName Workgroup)
    smb_params.each do |param|
      execute "set configd parameter: #{param}" do
        command "defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server #{param} #{node['system']['netbios_name']}"
        not_if { Mixlib::ShellOut.new("defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server #{param}").run_command.stdout.strip == node['system']['netbios_name'] }
        notifies :create, 'ruby_block[show host info]', :delayed
      end
    end
  end

  # http://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution
  if node['system']['permanent_ip']
    # remove 127.0.0.1 from /etc/hosts when using permanent IP
    hostsfile_entry '127.0.1.1' do
      action :remove
    end
    hostsfile_entry '127.0.0.1' do
      hostname 'localhost.localdomain'
      aliases ['localhost']
      unique true
    end
    hostsfile_entry GetIP.local do
      hostname lazy { fqdn }
      aliases [new_resource.short_hostname]
    end
  else
    hostsfile_entry GetIP.local do
      hostname lazy { fqdn }
      aliases [new_resource.short_hostname]
      action :remove
    end
    hostsfile_entry '127.0.1.1' do
      hostname lazy { fqdn }
      aliases [new_resource.short_hostname]
      only_if { platform_family?('debian') }
    end
    hostsfile_entry '127.0.0.1' do
      hostname lazy { fqdn }
      aliases [new_resource.short_hostname, 'localhost.localdomain', 'localhost']
      not_if { platform_family?('debian') }
    end
  end

  # add in/ensure this default host for mac_os_x
  hostsfile_entry '255.255.255.255' do
    hostname 'broadcasthost'
    only_if { platform_family?('mac_os_x') }
  end

  # ipv6 for localhost
  hostsfile_entry '::1' do
    hostname 'localhost'
  end

  # (re)start the hostname[.sh] service on debian-based distros
  if platform_family?('debian')
    case node['platform']
    when 'debian'
      service_name = 'hostname.sh'
      service_supports = {
        start: true,
        restart: false,
        status: false,
        reload: false
      }
      service_provider = ::Chef::Provider::Service::Init::Debian
    when 'ubuntu'
      service_name = 'hostname'
      service_supports = {
        start: true,
        restart: true,
        status: false,
        reload: true
      }
      service_provider = ::Chef::Provider::Service::Upstart
    end

    service service_name do
      supports service_supports
      provider service_provider
      action :nothing
    end
  end

  # http://www.rackspace.com/knowledge_center/article/centos-hostname-change
  service 'network' do
    only_if { platform_family?('rhel') }
    only_if { node['platform_version'] < '7.0' }
  end

  # we want to physically set the hostname in the compile phase
  # as early as possible, just in case (although its not actually needed)
  execute 'run hostname' do
    command "hostname #{fqdn}"
    action :nothing
    not_if { Mixlib::ShellOut.new('hostname -f').run_command.stdout.strip == fqdn }
  end.run_action(:run)

  # let's not manage the entire file because its shared
  ruby_block 'update network sysconfig' do
    block do
      fe = ::Chef::Util::FileEdit.new('/etc/sysconfig/network')
      fe.search_file_replace_line(/HOSTNAME\=/, "HOSTNAME=#{fqdn}")
      fe.write_file
    end
    only_if { platform_family?('rhel') }
    only_if { node['platform_version'] < '7.0' }
    not_if { ::File.readlines('/etc/sysconfig/network').grep(/HOSTNAME=#{fqdn}/).any? }
    notifies :restart, 'service[network]', :delayed
  end

  ruby_block 'show hostnamectl' do
    block do
      ::Chef::Log.info('== hostnamectl ==')
      ::Chef::Log.info(HostInfo.hostnamectl)
    end
    action :nothing
    only_if "bash -c 'type -P hostnamectl'"
  end

  # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/sec_Configuring_Host_Names_Using_hostnamectl.html
  # hostnamectl is used by other distributions too
  execute 'run hostnamectl' do
    command "hostnamectl set-hostname #{fqdn}"
    only_if "bash -c 'type -P hostnamectl'"
    notifies :create, 'ruby_block[show hostnamectl]', :delayed
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
      ::Chef::Log.info('== New host/node information ==')
      ::Chef::Log.info("Hostname: #{HostInfo.hostname == '' ? '<none>' : HostInfo.hostname}")
      ::Chef::Log.info("Network node hostname: #{HostInfo.network_node == '' ? '<none>' : HostInfo.network_node}")
      ::Chef::Log.info("Alias names of host: #{HostInfo.host_aliases == '' ? '<none>' : HostInfo.host_aliases}")
      ::Chef::Log.info("Short host name (cut from first dot of hostname): #{HostInfo.short_name == '' ? '<none>' : HostInfo.short_name}")
      ::Chef::Log.info("Domain of hostname: #{HostInfo.domain_name == '' ? '<none>' : HostInfo.domain_name}")
      ::Chef::Log.info("FQDN of host: #{HostInfo.fqdn == '' ? '<none>' : HostInfo.fqdn}")
      ::Chef::Log.info("IP address(es) for the hostname: #{HostInfo.host_ip == '' ? '<none>' : HostInfo.host_ip}")
      ::Chef::Log.info("Current FQDN in node object: #{node['fqdn']}")
      ::Chef::Log.info("Apple SMB Server: #{HostInfo.apple_smb_server}") if node['platform'] == 'mac_os_x'
    end
    action :nothing
  end

  file '/etc/hostname' do
    owner 'root'
    group 'root'
    mode 0755
    content "#{fqdn}\n"
    action :create
    notifies :start, resources("service[#{service_name}]"), :immediately if platform?('debian')
    notifies :restart, resources("service[#{service_name}]"), :immediately if platform?('ubuntu')
    notifies :create, 'ruby_block[update network sysconfig]', :immediately
    notifies :run, 'execute[run domainname]', :immediately
    notifies :run, 'execute[run hostname]', :immediately
    notifies :create, 'ruby_block[show host info]', :delayed
    not_if { node['platform'] == 'mac_os_x' }
  end

  # covers cases where a dhcp client has manually
  # set the hostname (such as with the hostname command)
  # and /etc/hostname has not changed
  # this can be the the case with ec2 ebs start
  execute "ensure hostname sync'd" do
    command "hostname #{fqdn}"
    not_if { Mixlib::ShellOut.new('hostname -f').run_command.stdout.strip == fqdn }
  end

  # rightscale support: rightlink CLI tools, rs_tag
  execute 'set rightscale server hostname tag' do
    command "rs_tag --add 'node:hostname=#{fqdn}'"
    only_if "bash -c 'type -P rs_tag'"
  end

  new_resource.updated_by_last_action(true)
end # close action :set

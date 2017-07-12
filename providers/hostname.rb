# encoding: UTF-8
#
# Cookbook Name:: system
# Provider:: hostname
#
# Copyright 2012-2016, Chris Fordham
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

use_inline_resources

# represents Chef
class Chef
  # include the HostInfo library
  class Recipe
    include HostInfo
  end
end

action :set do
  # user can specify short_hostname and domain_name or simply
  # derive it from the name of the resource

  short_hostname = if new_resource.short_hostname
                     new_resource.short_hostname
                   else
                     # as the resource must have a name, there will always
                     # be one result from the split
                     new_resource.hostname.split('.').first
                   end

  domain_name = if new_resource.domain_name
                  new_resource.domain_name
                elsif new_resource.hostname.split('.').count >= 2
                  new_resource.hostname.split('.')[1..-1].join('.')
                else
                  # fallback domain name to 'localdomain'
                  # to complete a valid FQDN
                  node['system']['domain_name']
                end

  # finally, raise if we don't have a valid hostname
  # http://en.wikipedia.org/wiki/Hostname
  raise "#{short_hostname} is not a valid hostname!" unless \
    short_hostname =~ /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/

  # reconstruct the fqdn
  fqdn = "#{short_hostname}.#{domain_name}"
  ::Chef::Log.debug "FQDN determined to be: #{fqdn}"

  # https://tickets.opscode.com/browse/OHAI-389
  # http://lists.opscode.com/sympa/arc/chef/2014-10/msg00092.html
  node.automatic_attrs['fqdn'] = fqdn
  node.automatic_attrs['hostname'] = new_resource.short_hostname

  # FreeBSD
  ruby_block 'update hostname in /etc/rc.conf' do
    block do
      fe = ::Chef::Util::FileEdit.new('/etc/rc.conf')
      fe.search_file_replace_line(/hostname\=/, "hostname=#{fqdn}")
      fe.write_file
    end
    only_if { platform?('freebsd') }
    not_if { ::File.readlines('/etc/rc.conf').grep(/hostname=#{fqdn}/).any? }
  end

  if platform_family?('mac_os_x')
    execute 'set configd parameter: HostName' do
      command "scutil --set HostName #{fqdn}"
      not_if { Mixlib::ShellOut.new('scutil --get HostName').run_command.stdout.strip == fqdn }
      notifies :create, 'ruby_block[show host info]', :delayed
    end

    shorthost_params = %w(ComputerName LocalHostName)
    shorthost_params.each do |param|
      execute "set configd parameter: #{param}" do
        command "scutil --set #{param} #{short_hostname}"
        not_if { Mixlib::ShellOut.new("scutil --get #{param}").run_command.stdout.strip == short_hostname }
        notifies :create, 'ruby_block[show host info]', :delayed
      end
    end

    # https://discussions.apple.com/thread/2457573
    smb_params = { 'NetBIOSName' => new_resource.netbios_name,
                   'Workgroup'   => new_resource.workgroup }
    default = '/Library/Preferences/SystemConfiguration/com.apple.smb.server'
    smb_params.each do |param, value|
      execute "set configd parameter: #{param}" do
        command "defaults write #{default} #{param} #{value}"
        not_if { Mixlib::ShellOut.new("defaults read #{default} #{param}").run_command.stdout.strip == value }
        notifies :create, 'ruby_block[show host info]', :delayed
      end
    end
  end

  primary_if = node['network']['interfaces'][node['system']['primary_interface']]
  primary_addrs = primary_if['addresses']
  primary_addrs_ipv4 = primary_addrs.select { |_addr, attrs| attrs['family'] == 'inet' }
  primary_ip = primary_addrs_ipv4.keys.first
  ::Chef::Log.debug "primary_ip is: #{primary_ip}"

  # http://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution
  if node['system']['permanent_ip']
    # remove 127.0.0.1 from /etc/hosts when using permanent IP
    hostsfile_entry "127.0.1.1_#{new_resource.name}" do
      ip_address '127.0.1.1'
      action :remove
      only_if { new_resource.manage_hostsfile }
    end
    hostsfile_entry "127.0.0.1_#{new_resource.name}" do
      ip_address '127.0.0.1'
      hostname 'localhost.localdomain'
      aliases ['localhost']
      action node['system']['hostsfile_behaviour'].to_sym
      only_if { new_resource.manage_hostsfile }
    end
    # condition used due to https://github.com/xhost-cookbooks/system/issues/35
    if primary_ip
      hostsfile_entry "#{primary_ip}_#{new_resource.name}" do
        ip_address primary_ip
        hostname lazy { fqdn }
        aliases [new_resource.short_hostname]
        action node['system']['hostsfile_behaviour'].to_sym
        only_if { new_resource.manage_hostsfile }
      end
    end
  else
    # condition used due to https://github.com/xhost-cookbooks/system/issues/35
    if primary_ip
      hostsfile_entry "#{primary_ip}_#{new_resource.name}" do
        ip_address primary_ip
        hostname lazy { fqdn }
        aliases [new_resource.short_hostname]
        action :remove
        only_if { new_resource.manage_hostsfile }
      end
    end
    hostsfile_entry "127.0.1.1_#{new_resource.name}" do
      ip_address '127.0.1.1'
      hostname lazy { fqdn }
      aliases [new_resource.short_hostname]
      action node['system']['hostsfile_behaviour'].to_sym
      only_if { platform_family?('debian') }
      only_if { new_resource.manage_hostsfile }
    end
    hostsfile_entry "127.0.0.1_#{new_resource.name}" do
      ip_address '127.0.0.1'
      hostname lazy { fqdn }
      aliases [new_resource.short_hostname, 'localhost.localdomain', 'localhost']
      action node['system']['hostsfile_behaviour'].to_sym
      not_if { platform_family?('debian') }
      only_if { new_resource.manage_hostsfile }
    end
  end

  # add in/ensure this default host for mac_os_x
  hostsfile_entry "255.255.255.255_#{new_resource.name}" do
    ip_address '255.255.255.255'
    hostname 'broadcasthost'
    action node['system']['hostsfile_behaviour'].to_sym
    only_if { platform_family?('mac_os_x') }
    only_if { new_resource.manage_hostsfile }
  end

  # the following are desirable for IPv6 capable hosts
  ipv6_hosts = [
    { ip: '::1', name: 'localhost6.localdomain6',
      aliases: %w(localhost6 ip6-localhost ip6-loopback) },
    { ip: 'fe00::0', name: 'ip6-localnet' },
    { ip: 'ff00::0', name: 'ip6-mcastprefix' },
    { ip: 'ff02::1', name: 'ip6-allnodes' },
    { ip: 'ff02::2', name: 'ip6-allrouters' }
  ]

  # we'll keep ipv6 stock for os x
  if platform_family?('mac_os_x')
    ipv6_hosts.select { |h| h[:ip] == '::1' }[0][:name] = 'localhost'
    ipv6_hosts.select { |h| h[:ip] == '::1' }[0][:aliases] = nil
    ipv6_hosts = [ipv6_hosts.slice(1 - 1)]
  end

  # add the ipv6 hosts to /etc/hosts
  ipv6_hosts.each do |host|
    hostsfile_entry "#{host[:ip]}_#{new_resource.name}" do
      ip_address host[:ip]
      hostname host[:name]
      aliases host[:aliases] if host[:aliases]
      priority 5
      action node['system']['hostsfile_behaviour'].to_sym
      only_if { new_resource.manage_hostsfile }
    end
  end

  # additional static hosts
  new_resource.static_hosts.each do |ip, host|
    hostsfile_entry "#{ip}_#{new_resource.name}" do
      ip_address ip
      hostname host
      priority 6
      action node['system']['hostsfile_behaviour'].to_sym
      only_if { new_resource.manage_hostsfile }
    end
  end

  # (re)start the hostname[.sh] service on debian-based distros
  if platform_family?('debian')
    case node['platform']
    when 'debian', 'raspbian'
      service_name = 'hostname.sh'
      service_supports = {
        start: true,
        restart: false,
        status: false,
        reload: false
      }

      # Debian moved to systemd
      service_provider = if node['platform_version'] >= '8.0'
                           ::Chef::Provider::Service::Systemd
                         else
                           ::Chef::Provider::Service::Init::Debian
                         end
    when 'ubuntu'
      service_name = 'hostname'
      service_supports = {
        start: true,
        restart: true,
        status: false,
        reload: true
      }

      # Ubuntu moved to systemd
      service_provider = if node['platform_version'] >= '15.04'
                           ::Chef::Provider::Service::Systemd
                         else
                           ::Chef::Provider::Service::Upstart
                         end
    end

    service service_name do
      supports service_supports
      provider service_provider
      not_if { service_provider == ::Chef::Provider::Service::Systemd }
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
      fe.insert_line_if_no_match(/HOSTNAME\=/, "HOSTNAME=#{fqdn}")
      fe.write_file
    end
    only_if { ::File.exist?('/etc/sysconfig/network') }
    not_if { ::File.readlines('/etc/sysconfig/network').grep(/HOSTNAME=#{fqdn}/).any? }
    notifies :restart, 'service[network]', node['system']['delay_network_restart'] ? :delayed : :immediately
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
    not_if { Mixlib::ShellOut.new('hostname -f').run_command.stdout.strip == fqdn }
    notifies :create, 'ruby_block[show hostnamectl]', :delayed
  end

  # run domainname command if available
  execute 'run domainname' do
    command "domainname #{new_resource.domain_name}"
    only_if "bash -c 'type -P domainname'"
    not_if { Mixlib::ShellOut.new('domainname').run_command.stdout.strip == new_resource.domain_name }
    action :nothing
  end

  # for systems with cloud-init, ensure preserve hostname
  # https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/
  file '/etc/cloud/cloud.cfg.d/01_preserve_hostname.cfg' do
    content "preserve_hostname: true\n"
    only_if { ::File.exist?('/etc/cloud/cloud.cfg.d') }
  end

  # for systems with nmcli (NetworkManager)
  execute 'update hostname via nmcli' do
    command "nmcli general hostname #{short_hostname}"
    not_if { Mixlib::ShellOut.new('hostname -s').run_command.stdout.strip == short_hostname }
    only_if "bash -c 'type -P nmcli'"
  end

  # for systemd systems with systemd-hostnamed unit
  service 'systemd-hostnamed' do
    provider ::Chef::Provider::Service::Systemd
    only_if "bash -c 'type -P systemctl && systemctl is-enabled systemd-hostnamed'"
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
    mode 0644
    # https://www.freedesktop.org/software/systemd/man/hostname.html
    # do not include any comment lines to be on the safe side,
    # /etc/init.d/hostname.sh on debian does not ignore them
    content "#{short_hostname}\n"
    action :create
    notifies :start, resources("service[#{service_name}]"), :immediately if platform?('debian', 'raspbian')
    notifies :restart, resources("service[#{service_name}]"), :immediately if platform?('ubuntu')
    notifies :restart, resources('service[systemd-hostnamed]'), :delayed
    notifies :create, 'ruby_block[update network sysconfig]', :immediately
    notifies :run, 'execute[run domainname]', :immediately
    notifies :run, 'execute[run hostname]', :immediately
    notifies :create, 'ruby_block[show host info]', :delayed
    not_if { platform?('mac_os_x') }
    not_if { platform?('freebsd') }
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

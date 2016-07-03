# encoding: UTF-8
#
# Cookbook Name:: system
# Provider:: timezone
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

# SYSTEMSETUP(8) could be used on mac_os_x, however from oberservation
# linking /etc/localtime in the same manner as linux is adequate

use_inline_resources

action :set do
  # ensure the cron package is installed and cron is in the resource collection
  # http://jtimberman.housepub.org/blog/2015/01/17/quick-tip-define-resources-to-notifiy-in-lwrps/
  # https://github.com/chef-cookbooks/cron/blob/master/recipes/default.rb#L20-L27
  if node['system']['enable_cron'] && node['platform'] != 'mac_os_x'
    node['cron']['package_name'].each do |pkg|
      package pkg
    end

    service 'cron' do
      service_name node['cron']['service_name'] unless node['cron']['service_name'].nil?
      action [:enable, :start]
    end
  end

  # support user specifying a space instead of underscore in zone file path
  zone_file = new_resource.timezone.sub(' ', '_')

  # the zone file needs to exist in the system share to succeed
  raise "#{zone_file} is not a valid timezone!" unless ::File.file?("/usr/share/zoneinfo/#{zone_file}")

  # initially assume a zone change
  zone_change = true

  # when already a symlink to the zone_file, no need to reconfigure timezone
  if ::File.symlink?('/etc/localtime')
    if ::File.readlink('/etc/localtime').include? zone_file
      zone_change = false
    end
  end

  log "tz-info (before set): #{Time.now.strftime('%z %Z')}" do
    level :debug
    only_if { zone_change }
  end

  if %w(debian ubuntu).member? node['platform']
    package 'tzdata'

    bash 'dpkg-reconfigure tzdata' do
      user 'root'
      code '/usr/sbin/dpkg-reconfigure -f noninteractive tzdata'
      action :nothing
    end

    file '/etc/timezone' do
      owner 'root'
      group 'root'
      content "#{zone_file}\n"
      notifies :run, 'bash[dpkg-reconfigure tzdata]'
    end
  end

  execute "timedatectl set-timezone #{zone_file}" do
    if node['system']['enable_cron'] && node['platform'] != 'mac_os_x'
      notifies :restart, 'service[cron]', :immediately
    end
    notifies :create, 'ruby_block[verify newly-linked timezone]', :delayed
    only_if "bash -c 'type -P timedatectl'"
    not_if { Mixlib::ShellOut.new('timedatectl').run_command.stdout.include?(zone_file) }
  end

  link '/etc/localtime' do
    to "/usr/share/zoneinfo/#{zone_file}"
    if node['system']['enable_cron'] && node['platform'] != 'mac_os_x'
      notifies :restart, 'service[cron]', :immediately
    end
    notifies :create, 'ruby_block[verify newly-linked timezone]', :delayed
    not_if "bash -c 'type -P timedatectl'"
  end

  ruby_block 'verify newly-linked timezone' do
    block do
      tz_info = ::Time.now.strftime('%z %Z')
      tz_info << "#{::File.readlink('/etc/localtime').gsub(/^/, ' (').gsub(/$/, ')')})"
      ::Chef::Log.debug("tz-info (after set): #{tz_info}")
    end
    action :nothing
    only_if { ::File.symlink?('/etc/localtime') }
    only_if { zone_change }
  end

  new_resource.updated_by_last_action(true) if zone_change
end

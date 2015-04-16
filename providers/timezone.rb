#
# Cookbook Name:: system
# Provider:: timezone
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
  # support user specifying a space instead of underscore in zone file path
  zone_file = new_resource.timezone.sub(' ', '_')

  fail "#{zone_file} is not a valid timezone!" unless ::File.file?("/usr/share/zoneinfo/#{zone_file}")

  log "tz-info (before set): #{Time.now.strftime('%z %Z')}" do
    level :debug
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

  link '/etc/localtime' do
    to "/usr/share/zoneinfo/#{zone_file}"
    notifies :restart, "service[#{node['system']['cron_service_name']}]", :immediately
  end

  ruby_block 'verify linked timezone' do
    block do
      tz_info = ::Time.now.strftime('%z %Z')
      tz_info << "#{::File.readlink('/etc/localtime').gsub(/^/, ' (').gsub(/$/, ')')})"
      ::Chef::Log.debug("tz-info (after set): #{tz_info}")
    end
  end

  new_resource.updated_by_last_action(true)
end

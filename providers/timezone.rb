#
# Cookbook Name:: system
# Provider:: timezone
#
# Copyright 2013, Tacit Knowledge, Inc.
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

  # TODO: Add checking if zone file exists in the zoneinfo

  log("tz-info (before): #{Time.now.strftime("%z %Z")}")

  if %w(debian ubuntu').member? node['platform']
    package 'tzdata'

    bash 'dpkg-reconfigure tzdata' do
      user 'root'
      code '/usr/sbin/dpkg-reconfigure -f noninteractive tzdata'
      action :nothing
    end

    template '/etc/timezone' do
      source 'timezone.conf.erb'
      owner 'root'
      group 'root'
      mode 0644
      notifies :run, 'bash[dpkg-reconfigure tzdata]'
    end
  end

  link '/etc/localtime' do
    to "/usr/share/zoneinfo/#{new_resource.name}"
    notifies :restart, "service[#{value_for_platform(["ubuntu", "debian"] => { "default" => "cron" }, "default" => "crond")}]", :immediately
  end

  ruby_block 'verify_linked_timezone' do
    block do
      Chef::Log.info("tz-info: #{::Time.now.strftime("%z %Z")}#{::File.readlink('/etc/localtime').gsub(/^/, ' (').gsub(/$/, ')')}")
    end
  end

  new_resource.updated_by_last_action(true)

end # close action :set

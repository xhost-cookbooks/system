# encoding: UTF-8
#
# Cookbook Name:: system
# Recipe:: upgrade_packages
#
# Copyright 2012, Chris Fordham
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

include_recipe 'system::update_package_list'

upgrade_cmd = value_for_platform(
  %w(ubuntu debian) => {
    'default' => 'export DEBIAN_FRONTEND=noninteractive; apt-get -y upgrade'
  },
  %w(centos redhat scientific fedora amazon) => {
    'default' => 'yum -y update && yum -y upgrade'
  },
  'suse' => { 'default' => 'zypper --non-interactive update' },
  'arch' => {
    'default' => 'pacman --sync --refresh --sysupgrade --noprogressbar -q'
  },
  'freebsd' => { 'default' => 'portupgrade -af' },
  'mac_os_x' => { 'default' => 'port sync' }
)

e = execute 'upgrade system packages' do
  command upgrade_cmd
  action :nothing
end

if node['system']['upgrade_packages']
  # supports type string if defined through metadata
  e.run_action(:run) unless node['system']['upgrade_packages'] == 'false'
end

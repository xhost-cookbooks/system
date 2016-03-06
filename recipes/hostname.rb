# encoding: UTF-8
#
# Cookbook Name:: system
# Recipe:: hostname
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

system_hostname node['system']['short_hostname'] do
  short_hostname    node['system']['short_hostname']
  domain_name       node['system']['domain_name']
  static_hosts      node['system']['static_hosts']
  netbios_name      node['system']['netbios_name']
  workgroup         node['system']['workgroup']
  manage_hostsfile  node['system']['manage_hostsfile']
  not_if            { node['virtualization'] && node['virtualization']['system'] && node['virtualization']['system'] == 'docker' }

  # https://github.com/chef/ohai/pull/569 not yet in most used chef versions
  not_if            'ls /.dockerinit'
end

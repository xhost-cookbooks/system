# encoding: UTF-8
#
# Cookbook Name:: system
# Attributes:: system
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

default['system']['timezone'] = 'Etc/UTC'

# just in case the node/image fails to have a proper hostname
default['system']['short_hostname'] = if node['hostname']
                                        node['hostname']
                                      else
                                        'localhost'
                                      end

default['system']['domain_name'] = 'localdomain'
default['system']['netbios_name'] = node['system']['short_hostname'].upcase
default['system']['workgroup'] = 'WORKGROUP'
default['system']['static_hosts'] = {}
default['system']['manage_hostsfile'] = true
default['system']['hostsfile_behaviour'] = 'append'
default['system']['upgrade_packages'] = true
default['system']['upgrade_packages_at_compile'] = true
default['system']['permanent_ip'] = true
default['system']['primary_interface'] = node['network']['default_interface'] if node['network']
default['system']['delay_network_restart'] = true
default['system']['enable_cron'] = true
default['system']['packages']['install'] = []
default['system']['packages']['install_compile_time'] = []

default['system']['packages']['uninstall'] = []
default['system']['packages']['uninstall_compile_time'] = []

default['system']['environment']['extra'] = {}

# RightScale doesn't support boolean attributes in metadata
node.override['system']['manage_hostsfile'] = false if node['system']['manage_hostsfile'] == 'false'
node.override['system']['manage_hostsfile'] = true if node['system']['manage_hostsfile'] == 'true'

node.override['system']['upgrade_packages'] = false if node['system']['upgrade_packages'] == 'false'
node.override['system']['upgrade_packages'] = true if node['system']['upgrade_packages'] == 'true'

node.override['system']['permanent_ip'] = false if node['system']['permanent_ip'] == 'false'
node.override['system']['permanent_ip'] = true if node['system']['permanent_ip'] == 'true'

node.override['system']['enable_cron'] = false if node['system']['enable_cron'] == 'false'
node.override['system']['enable_cron'] = true if node['system']['enable_cron'] == 'true'

# encoding: UTF-8
#
# Cookbook Name:: system
# Recipe:: update_package_list
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

include_recipe 'apt' if platform_family?('debian')

# sync the MacPorts tree if older than 1 week
execute 'sync macports tree' do
  command 'port -d sync'
  only_if "bash -c 'type -P port'"
  only_if { platform_family?('mac_os_x') }
  only_if { (Time.now - File.mtime('/opt/local/var/macports/pingtimes')) >= 604_800 }
end

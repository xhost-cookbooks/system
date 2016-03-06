# encoding: UTF-8
#
# Cookbook Name:: system
# Resource:: timezone
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

# use 'Etc/UTC' for UTC/GMT
attribute :timezone,
          kind_of: String,
          name_attribute: true

actions :set

def initialize(*args)
  super
  @action = :set

  # arch can be removed once arch linux support is in the cron cookbook
  # https://github.com/opscode-cookbooks/cron/pull/49 needs merge
  @run_context.include_recipe 'cron' if node['system']['enable_cron'] && !(node['platform'] == 'arch' || node['platform'] == 'mac_os_x' || node['platform'] == 'freebsd')
end

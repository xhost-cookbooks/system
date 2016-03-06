# encoding: UTF-8
#
# Cookbook Name:: system
# Recipe:: profile
#
# Copyright 2015-2016, Chris Fordham
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

system_profile '/etc/profile' do
  node['system']['profile'].each do |attr, value|
    send attr, value
  end
end

# encoding: UTF-8
#
# Cookbook Name:: system
# Recipe:: install_packages
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

system_packages node['system']['packages']['install'].join(',') do
  packages node['system']['packages']['install']
end

system_packages node['system']['packages']['install_compile_time'].join(',') do
  packages node['system']['packages']['install_compile_time']
  phase :compile
end

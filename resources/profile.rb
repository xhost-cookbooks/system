# encoding: UTF-8
#
# Cookbook Name:: system
# Resource:: profile
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

actions [:configure]
default_action :configure

# typically '/etc/profile'
attribute :filename,
          name_attribute: true,
          kind_of: String

attribute :template,
          kind_of: Hash,
          default: nil

attribute :path,
          kind_of: Array,
          default: []

attribute :path_append,
          kind_of: Array,
          default: []

attribute :path_prepend,
          kind_of: Array,
          default: []

attribute :append_scripts,
          kind_of: Array,
          default: []

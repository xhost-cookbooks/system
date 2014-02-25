#
# Cookbook Name:: system
# Resource:: hostname
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

actions :set
default_action :set

attribute :short_hostname,
          kind_of: String,
          default: nil

attribute :domain_name,
          kind_of: String,
          default: nil

attribute :static_hosts,
          kind_of: Hash,
          default: nil

def initialize(*args)
  super
  @action = :set
end

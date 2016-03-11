# encoding: UTF-8
#
# Cookbook Name:: system
# Provider:: profile
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

use_inline_resources

action :configure do
  template new_resource.filename do
    variables profile: {
      path: new_resource.path_prepend + \
            new_resource.path + \
            new_resource.path_append,
      append_scripts: new_resource.append_scripts
    }
    # Specify that the templates are from the system
    # cookbook
    cookbook 'system'
    if new_resource.template
      new_resource.template.each do |attr, value|
        send attr, value
      end
    else
      source 'profile.erb'
    end
  end
  new_resource.updated_by_last_action(true)
end

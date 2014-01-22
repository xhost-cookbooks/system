#
# Cookbook Name:: system
# Library:: host_info
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

module HostInfo
  def self.hostname
    Mixlib::ShellOut.new('hostname').run_command.stdout.strip
  end

  def self.network_node
    Mixlib::ShellOut.new('uname -n').run_command.stdout.strip
  end

  def self.host_aliases
    Mixlib::ShellOut.new('hostname -a').run_command.stdout.strip
  end

  def self.short_name
    Mixlib::ShellOut.new('hostname -s').run_command.stdout.strip
  end

  def self.domain_name
    Mixlib::ShellOut.new('hostname -d').run_command.stdout.strip
  end
  
  def self.fqdn
    Mixlib::ShellOut.new('hostname -f').run_command.stdout.strip
  end
  
  def self.host_ip 
    Mixlib::ShellOut.new('hostname -i').run_command.stdout.strip
  end
end

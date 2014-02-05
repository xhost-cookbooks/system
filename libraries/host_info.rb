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

# This module provides basic methods to shell-out and
# return stripped output of system commands related
# to its hostname information
module HostInfo
  def self.shell_command(cmd)
    Mixlib::ShellOut.new(cmd).run_command.stdout.strip
  end

  def self.hostname
    shell_command('hostname')
  end

  def self.network_node
    shell_command('uname -n')
  end

  def self.host_aliases
    shell_command('hostname -a')
  end

  def self.short_name
    shell_command('hostname -s')
  end

  def self.domain_name
    shell_command('hostname -d')
  end

  def self.fqdn
    shell_command('hostname -f')
  end

  def self.host_ip
    shell_command('hostname -i')
  end
end

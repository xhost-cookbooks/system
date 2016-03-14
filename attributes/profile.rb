# encoding: UTF-8
#
# Cookbook Name:: system
# Attributes:: system/profile
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

case node['platform_family']
when 'arch'
  # /etc/profile from the `filesystem` package
  default['system']['profile']['path'] = ['/usr/local/sbin',
                                          '/usr/local/bin',
                                          '/usr/bin']
  # /usr/share/base-files/profile postinst installs to
  # /etc/profile from the `base-files` package
when 'debian', 'raspbian'
  default['system']['profile']['path'] = ['/usr/local/bin',
                                          '/usr/bin',
                                          '/bin',
                                          '/usr/local/games',
                                          '/usr/games']
when 'rhel'
  default['system']['profile']['path'] = ['/usr/local/sbin',
                                          '/usr/local/bin',
                                          '/usr/sbin',
                                          '/usr/bin',
                                          '/sbin',
                                          '/bin']
when 'fedora'
  default['system']['profile']['path'] = ['/usr/local/sbin',
                                          '/usr/local/bin',
                                          '/usr/sbin',
                                          '/usr/bin',
                                          '/sbin',
                                          '/bin']
# base PATH on freebsd is set in /etc/rc,
# we'll use the same here
when 'freebsd'
  default['system']['profile']['path'] = ['/sbin',
                                          '/bin',
                                          '/usr/sbin',
                                          '/usr/bin']
# purposely sane defaults
else
  default['system']['profile']['path'] = ['/usr/local/sbin',
                                          '/usr/local/bin',
                                          '/usr/sbin',
                                          '/usr/bin',
                                          '/sbin',
                                          '/bin']
end

default['system']['profile']['path_prepend'] = []
default['system']['profile']['path_append'] = []
default['system']['profile']['append_scripts'] = []

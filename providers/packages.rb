# encoding: UTF-8
#
# Cookbook Name:: system
# Provider:: packages
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

# represents Chef
class Chef
  # include the URLPackage library
  class Recipe
    include URLPackage
  end
end

action :install do
  new_resource.packages.each do |package|
    require 'uri'

    if package =~ URI.regexp
      # package is remote by URL

      # get the filename from the URL
      pkg_file = URLPackage.filename(package)

      # fetch the remote package
      remote_file "#{::Chef::Config[:file_cache_path]}/#{pkg_file}" do
        source package
      end

      # install the package in compile time or normally
      if new_resource.phase == 'compile'
        p = package pkg_file.split('.').first do
          source "#{::Chef::Config[:file_cache_path]}/#{pkg_file}"
          provider URLPackage.provider(pkg_file)
          action :nothing
        end
        p.run_action(:install)
      else
        package pkg_file.split('.').first do
          source "#{::Chef::Config[:file_cache_path]}/#{pkg_file}"
          provider URLPackage.provider(pkg_file)
        end
      end
    elsif new_resource.phase == :compile
      # install the packages in compile time or normally
      p = package package do
        action :nothing
      end
      p.run_action(:install)
    else
      package package
    end
  end
  new_resource.updated_by_last_action(true)
end # close action :install

action :uninstall do
  if new_resource.phase == :compile
    # uninstall the packages in compile time
    new_resource.packages.each do |package|
      p = package package do
        action :nothing
      end
      p.run_action(:remove)
    end
  else
    # remove each package normally
    new_resource.packages.each do |package|
      package package do
        action :remove
      end
    end
  end
  new_resource.updated_by_last_action(true)
end # close action :uninstall

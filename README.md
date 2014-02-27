system Cookbook
===============

[![Build Status](https://secure.travis-ci.org/xhost-cookbooks/system.png?branch=master)](http://travis-ci.org/xhost-cookbooks/system)
[![Code Climate](https://codeclimate.com/github/xhost-cookbooks/system.png)](https://codeclimate.com/github/xhost-cookbooks/system)

This cookbook is designed to provide a set of recipes to manage core system properties.

Requirements
------------
- Chef >= 10
- Ruby 1.9

### Platforms Supported
- Debian, Ubuntu
- CentOS, RHEL, Fedora
- Arch Linux

### Cookbooks
- apt
- cron
- hostsfile

Attributes
----------

See `attributes/default.rb` for default values.

- `node['system']['timezone']` - the system timezone to set, default `UTC`
- `node['system']['short_hostname']` - the short hostname to set on the node, default is `node['hostname']`
- `node['system']['domain_name']` - the domain name to set on the node, default `localdomain`
- `node['system']['static_hosts']` - an array of static hostnames to add to /etc/hosts
- `node['system']['upgrade_packages']` - whether to upgrade the system's packages, default `true`
- `node['system']['packages']['install']` - an array of packages to install
- `node['system']['packages']['install_compile_time']` - an array of packages to install in Chef's compilation phase

The following attributes should never need to be user set:

- `node['system']['cron_service_name']`

Usage
-----

###Recipes

- default
- hostname
- install_packages
- reboot
- timezone
- update_package_list
- upgrade_packages

See `metadata.rb` for more information.

License and Authors
-------------------
- Author: Chris Fordham (<chris@fordham-nagy.id.au>)

```text
Copyright 2011-2014, Chris Fordham

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
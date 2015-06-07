system Cookbook
===============

[![Code Climate](https://codeclimate.com/github/xhost-cookbooks/system.png)](https://codeclimate.com/github/xhost-cookbooks/system)

Build Status
------------

|           |    Travis CI    |
|-----------|-----------------|
| **Master** |[![Build status](https://secure.travis-ci.org/xhost-cookbooks/system.png?branch=master)](http://travis-ci.org/xhost-cookbooks/system)|
| **Latest Release [0.6.4](https://github.com/xhost-cookbooks/system/releases/tag/v0.6.4)** |[![Build status](https://secure.travis-ci.org/xhost-cookbooks/system.png?branch=v0.6.4)](https://travis-ci.org/xhost-cookbooks/system/builds/64242112)|

This cookbook is designed to provide a set of recipes to manage core system properties as well as some ad-hoc operational tasks.

Get it from your (local) supermarket, https://supermarket.chef.io/cookbooks/system.

Requirements
------------
- Chef >= 11
- Ruby 1.9

### Platforms Supported
- Debian, Ubuntu
- CentOS, RHEL, Fedora
- Arch Linux
- Mac OS X

### Cookbooks
- apt
- cron
- hostsfile

Attributes
----------

See `attributes/default.rb` for default values.

- `node['system']['timezone']` - the system timezone to set, default `Etc/UTC`
- `node['system']['short_hostname']` - the short hostname to set on the node, default is `node['hostname']`
- `node['system']['domain_name']` - the domain name to set on the node, default `localdomain`
- `node['system']['netbios_name']` - the NetBIOS name to set on the node, default is `node['system']['short_hostname']` upper-cased (OS X only)
- `node['system']['workgroup']` - the NetBIOS workgroup name to set on the node, default is `WORKGROUP` (OS X only)
- `node['system']['static_hosts']` - an array of static hostnames to add to /etc/hosts
- `node['system']['upgrade_packages']` - whether to upgrade the system's packages, default `true`
- `node['system']['packages']['install']` - an array of packages to install (also supports remote package URLs)
- `node['system']['packages']['install_compile_time']` - an array of packages to install in Chef's compilation phase (also supports remote package URLs)
- `node['system']['permanent_ip']` - whether the system has a permenent IP address (http://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution)

The following attributes should never need to be user set:

- `node['system']['cron_service_name']`

Usage
-----

###Recipes

#####`system::default`
Includes `system::update_package_list`, `system::timezone` and `system::hostname` recipes only.

#####`system::hostname`
When using resources that reference `node['fqdn']` in variables or attribute values, note that you will
need to lazy load to get the new hostname that is being set.

Use with variables:
```
template '/tmp/foobar.txt' do
  source 'use_fqdn_in_variable.erb'
  variables lazy {
    {
      fqdn: node['fqdn'],
      foo: bar
    }
  }
end
```

Use with a resource attribute:
```
log 'lazy_log_fqdn' do
  message lazy { node['fqdn'] }
  level :debug
end
```

#####`system::install_packages`
Installs a list of system packages as specified in the `node['system']['packages']['install']` attribute.
Will also install packages provided at compile time from within `node['system']['packages']['install_compile_time']`.

#####`system::uninstall_packages`
Uninstalls a list of system packages as specified in the `node['system']['packages']['uninstall']` attribute.
Will also uninstall packages provided at compile time from within `node['system']['packages']['uninstall_compile_time']`.

#####`system::reboot`
Attempts to gracefully reboot the operating system.

#####`system::shutdown`
Attempts to gracefully shutdown the operating system.

#####`system::timezone`
Sets the timezone of the system.

#####`system::update_package_list`
Updates the local package manager's package list.

#####`system::upgrade_packages`
Upgrades all installed packages of the local package manager.

###LWRPs

The cookbook currently provides 3 Lightweight Resource Providers that can be used in your own recipes
by depending on this cookbook. Recipes are provided interfacing each of these for convenience but
you may find them useful in your own cookbook usage.

- `system_hostname`
- `system_timezone`
- `system_packages`

License and Authors
-------------------
- Author: Chris Fordham (<chris@fordham-nagy.id.au>)

```text
Copyright 2011-2015, Chris Fordham

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

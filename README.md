system Cookbook
===============

[![Cookbook Version](https://img.shields.io/badge/cookbook-v0.11.3-blue.svg)](https://supermarket.chef.io/cookbooks/system)
[![Dependency Status](https://gemnasium.com/xhost-cookbooks/system.svg)](https://gemnasium.com/xhost-cookbooks/system)
[![Code Climate](https://codeclimate.com/github/xhost-cookbooks/system.png)](https://codeclimate.com/github/xhost-cookbooks/system)
[![Test Coverage](https://codeclimate.com/github/xhost-cookbooks/system/badges/coverage.svg)](https://codeclimate.com/github/xhost-cookbooks/system)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Join the chat at https://gitter.im/xhost-cookbooks/system](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/xhost-cookbooks/system?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Build Status
------------

|           |    Travis CI    |
|-----------|-----------------|
| **Master** |[![Build status](https://secure.travis-ci.org/xhost-cookbooks/system.png?branch=master)](http://travis-ci.org/xhost-cookbooks/system)|
| **Latest Release** ([**0.11.3**](https://github.com/xhost-cookbooks/system/releases/tag/v0.11.3)) |[![Build status](https://secure.travis-ci.org/xhost-cookbooks/system.png?branch=v0.11.3)](https://travis-ci.org/xhost-cookbooks/system/builds/161531274)|

Overview
--------

This cookbook is designed to provide a set of recipes and LWRPs for managing the core properties of a host's system.

Currently the main features (from a high level) include:
- setting the hostname/domain name
- setting the default NetBIOS name and Workgroup (OS X only)
- setting the timezone
- configuring the system-wide profile (`/etc/profile`)
- managing packages (install, uninstall & upgrade)

Ad-hoc style operational tasks such as reboot and shutdown are also implemented by recipes.

Get it now from your (local) [supermarket](https://supermarket.chef.io/cookbooks/system)!


Requirements
------------
- Chef >= 11.12.0
- Ruby >= 1.9

### Platforms Supported
- Debian, Ubuntu
- CentOS, RHEL, Fedora
- Arch Linux
- FreeBSD
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
- `node['system']['static_hosts']` - a hash of static hosts to add to `/etc/hosts`
- `node['system']['upgrade_packages']` - whether to upgrade the system's packages, default `true`
- `node['system']['upgrade_packages_at_compile']` - whether upgrade of the system's packages in Chef's compilation phase, default `true`
- `node['system']['enable_cron']` - whether to include the cron recipe, default `true`
- `node['system']['packages']['install']` - an array of packages to install (also supports remote package URLs)
- `node['system']['packages']['install_compile_time']` - an array of packages to install in Chef's compilation phase (also supports remote package URLs)
- `node['system']['manage_hostsfile']` - whether or not to manage `/etc/hostsfile` (in any way)
- `node['system']['permanent_ip']` - whether the system has a permenent IP address (http://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution)
- `node['system']['primary_interface']` - Specify primary network interface, used by hostname to set the correct address in hostsfile, default is `node['network']['default_interface']`
- `node['system']['delay_network_restart']` - whether to trigger restart event as delayed. false causes an immediate restart instead. default `true`

Attributes (all arrays) to manipulate the system-wide profile (usually for `/etc/profile`):

- `node['system']['profile']['path']` - override the default `PATH` for the system
- `node['system']['profile']['path_append']` - append more paths to the base path
- `node['system']['profile']['path_prepend']` - prepend more paths to the base path
- `node['system']['profile']['append_scripts']` - an array of shell scripts to be appended to the system profile (include raw scripts without shebangs)


Usage
-----

### Recipes

##### `system::default`
Includes the `system::update_package_list`, `system::timezone` and `system::hostname` recipes only.

NOTE: if applicable, the system's package manager's package list will be updated, but installed packages won't be upgraded. To upgrade the system's packages, include the `system::upgrade_packages` recipe in your run_list or role.

##### `system::hostname`
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

##### `system::profile`
Manages `/etc/profile` with optional shell scripts to append from `node['system']['profile']['append_scripts']`,
configure `PATH` requirements per attributes documented above.

##### `system::install_packages`
Installs a list of system packages as specified in the `node['system']['packages']['install']` attribute.
Will also install packages provided at compile time from within `node['system']['packages']['install_compile_time']`.

##### `system::uninstall_packages`
Uninstalls a list of system packages as specified in the `node['system']['packages']['uninstall']` attribute.
Will also uninstall packages provided at compile time from within `node['system']['packages']['uninstall_compile_time']`.

##### `system::reboot`
Attempts to gracefully reboot the operating system.

##### `system::shutdown`
Attempts to gracefully shutdown the operating system.

##### `system::timezone`
Sets the timezone of the system.

##### `system::update_package_list`
Updates the local package manager's package list.

##### `system::upgrade_packages`
Upgrades all installed packages of the local package manager.

### LWRPs

The cookbook currently provides 3 Lightweight Resource Providers that can be used in your own recipes
by depending on this cookbook. Recipes are provided interfacing each of these for convenience but
you may find them useful in your own cookbook usage.

#### `system_hostname`

|  Attribute         | Description                                   |  Example           |  Default  |
|--------------------|-----------------------------------------------|--------------------|-----------|
|  short_hostname    | The short hostname for the system             |  `starbug`         |  nil      |
|  domain_name       | The domain name for the system                |  `reddwarf.space`  |  nil      |
|  static_hosts      | An array of static hosts to add to /etc/hosts |  `[{ '95.211.29.66' => 'supermarket.io' }, { '184.106.28.82' => 'chef.io' }]` |  nil      |

##### Examples

Set the hostname providing the desired FQDN:
```
system_hostname 'starbug.reddwarf.space'
```

Providing the short hostname as the resource name and explicitly defining the domain name
(alas this is a bit verbose), as well as some static hosts:
```
system_hostname 'starbug' do
  short_hostname 'starbug'
  domain_name 'reddwarf.space'
  static_hosts(({ '95.211.29.66' => 'supermarket.io',
                  '184.106.28.82' => 'chef.io' }))
end
```
The `system::hostname` recipe implements it this way as `short_hostname` and `domain_name`
are the exposed cookbook attributes.

#### `system_timezone`

|  Attribute         | Description                                   |  Example             |  Default  |
|--------------------|-----------------------------------------------|----------------------|-----------|
|  timezone          | The timezone to set the system to             |  `Australia/Sydney`  | `Etc/UTC` |

##### Example

```
system_timezone 'Australia/Sydney'
```

#### `system_packages`

|  Attribute         | Description                                   |  Example          |  Default    |
|--------------------|-----------------------------------------------|-------------------|-------------|
|  packages          | The timezone to set the system to             |  `%w(wget curl)`  | `[]`        |
|  phase             | The Chef phase to download the packages in    |  `:compile  `     | `:converge` |

##### Example

```
system_packages %w(wget curl).join(',') do
  packages %w(wget curl)
  phase :compile
end
```

#### `system_profile`

|  Attribute         | Description                                           |  Example               |  Default        |
|--------------------|-------------------------------------------------------|------------------------|-----------------|
|  filename          | The system profile file to manage                     |  `/etc/profile`        |  `/etc/profile` |
|  template          | The cookbook erb template for the profile file        |  `custom_profile.erb`  |  `profile.erb`  |
|  path              | An environment search path to prepend to the default  |  `/opt/local/bin`      |  `[]`           |
|  append_scripts    | Arbitrary scripts to append to the profile            |  `['export FOO=bar']`  |  `nil`          |

##### Example

```
system_profile '/etc/profile' do
  path ['/opt/local/bin', '/opt/foo/bin']
  append_scripts ['export FOO=bar']
end
```

### Publish to Chef Supermarket

    $ cd ..
    $ knife cookbook site share system "Operating Systems & Virtualization" -o . -u xhost -k ~/.chef/xhost.pem


License and Authors
-------------------
- Author: Chris Fordham (<chris@fordham-nagy.id.au>)

```text
Copyright 2011-2016, Chris Fordham

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

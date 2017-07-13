system CHANGELOG
================

This file is used to list changes made in each version of the system cookbook.

0.0.1
-----
- Initial pre-release version

0.1.0
-----
- Initial 'pre 1' minor release

0.2.2
-----
- Includes bug fixes, revised code and more testing files

0.2.3
-----
- Fix missing quote for rs_tag command in hostname provider

0.3.2
-----
- Fix missing equals sign for service_action variable
- Fix notifies for service[hostname] for Debian
- Set 127.0.1.1 on Debian if needed
- Fix for OHAI-389
- Set supports status false for hostname service
- Use service_name for hostname resource name
- Minor log text improvements for show host info
- Notify the hostname service immediately.
- Address FC037: Invalid notification action
- Add chefignore
- Add TESTING.md

0.3.3
-----
- Revision only to address https://github.com/xhost-cookbooks/system/issues/6

0.3.4
-----
- Revision only to address https://github.com/xhost-cookbooks/system/issues/8

0.4.0
-----
- Better platform support for default cron service
- timezone provider ensures inclusion of cron recipe
- Other minor fixes for cron
- Improve test suite, add basic tests
- Add a recipe to test setting of the fqdn
- New attribute, permanent_ip to affect usage of 127.0.1.1 on debian
- Fix setting hosts in /etc/hosts by using lazy loading of fqdn
- Set fqdn in compile phase, to be sure

0.4.1
-----
- Revision only to address https://github.com/xhost-cookbooks/system/issues/10

0.5.0
-----
- Add a hostsfile entry for 127.0.0.1 against localhost.localdomain when not using permanent_ip
- Include the FQDN in the hostfile entry for for 127.0.0.1 when not on Debian
- Add resource for the network service in RHEL platform family (restart it on hostname change)
- Use Chef::Util::FileEdit instead of sed to update /etc/sysconfig/network
- permanent_ip is now true by default
- Add support for hostnamectl (mostly for EL 7)
- Fix missing trailing line return for /etc/hostname
- Test Debian and CentOS with test-kitchen

0.6.0
-----
- Mac OS X support (including NetBIOS and Workgroup names)!
- Pull request #11 (default timezone is now 'Etc/UTC')
- Fail when an invalid timezone is provided
- Support providing a zone with a space instead of underscore (for the humans)
- Make before and after tz-info log resources debug log level
- update_package_list recipe will now sync MacPorts tree
- upgrade_packages recipe will now upgrade installed ports for MacPorts
- Improved test suite including use of chef_zero with test-kitchen, more platforms/versions
- Add a good handful of Serverspec tests

0.6.1
-----
- Ensure the crond service is available for restarting in timezone provider
- Add mac_os_x to supports in metadata

0.6.2
-----
- Fix cron daemon usage for arch linux (uses cronie which is not yet supported in the cron cookbook yet)
- Fix cron_service_name for arch linux (cronie) in default attributes
- Fix supports for arch linux in metadata.rb

0.6.3
-----
- Use regex with readlines grep when checking for hostname in /etc/sysconfig/network on EL-based distros (fix for issue #14)
- Help bad images/systems that have a null hostname (fix for issue #15)

0.6.4
-----
- Fix for issue #17 removing unique hostfile entry for 127.0.0.1
- Fix render of static_hosts via node attributes
- Add hostfile entries for ipv6 hosts
- Let the cron cookbook manage the cron resources entirely
- Various test elements added/improved

0.7.0
-----
- New system_packages LWRP
- Support for installing remote packages by URL using the system_packages LWRP
- timezone provider now defaults to Etc/UTC timezone

0.8.0
-----
- Initial FreeBSD support
- Manage /etc/profile by recipe or system_profile LWRP
- system::hostname recipe parameterizes available provider attributes
- Support for using the name_attribute of the hostname resource for fqdn
- Fix for issue #22 (timezone set idempotency)
- Various minor fixes

0.9.0
-----
- Manage /etc/environment by recipe or system_environment LWRP
- Support optional management of /etc/hosts (e.g. do not add hostname to this file)
- Support optional inclusion of the cron recipe
- Use ohai to determine network IP (pr #26)
- Allow specification primary network interface for hostsfile generation (pr #26)
- Improve/fix templating for system profile (/etc/profile)

0.9.1
-----
- Fix missing end statement in templates/arch/profile.erb

0.10.0
------
- Make it possible to control which phase package upgrades occur (issue #28)
- More lazy string from bool support for attributes in RightScale
- Support for Ubuntu 15.04 (issue #30 and #31)
- Chef 13 forward compliance (Do not specify both default and name_property together on property filename of resource)
- Better docker support and with test-kitchen (.kitchen-docker.yml)
- Add a Dockerfile
- timedatectl for supported systems (issue #32)
- Support path_append and path_prepend (issue #27)

0.10.1
------
- Fix missing underscore in ip_address attribute for 127.0.1.1 hostsfile entry
- Fix logic on if the cron service should be notified or used within timezone provider resources

0.11.0
------
- Fix cookbook templates attempting to use incorrect cookbook templates (pr #40)
- Raspbian platform support (pr #41)
- Add ChefSpec matchers (pr #42)
- Refresh TESTING.md (issue #39)
- /etc/hostname should be short hostname and mode 0644 (issue #37)
- Do not include any comment lines in /etc/hostname out of safeness
- Remove temporary archlinux code for cron (timezone provider)
- Only set hostsfile entry if private IP is set (issue #35)
- Network restart control feature (pr #36)
- Make attribute de-reference safe for failing attributes when undefined (pr #34)
- Test Kitchen path fix for docker (issue #33)
- Various test related improvements, bumps, fixes

0.11.1
------

Fix release to address issue #47 where hostname does not persist after reboot.

- always set HOSTNAME in /etc/sysconfig/network if the config file exists
- do not run domainname if the domainname is already as desired
- configure preserve_hostname with cloud-init if cloud-init is installed
- update hostname with nmcli if installed
- restart systemd-hostnamed if enabled

0.11.2
------

Fix release to address issue #49 where an only_if attribute causes a fatal error

- check for that systemctl command exists first with type command
- fix expectation of hostname command returning FQDN in serverspec
- ubuntu 16.04 now tested with test-kitchen

0.11.3
------

- Add support for Debian > 8 (systemd) in hostname recipe

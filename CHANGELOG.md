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

# Encoding: utf-8

name             'system'
maintainer       'Xhost Australia'
maintainer_email 'cookbooks@xhost.com.au'
license          'Apache 2.0'
description      'Installs/Configures system elements such as the hostname and timezone.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.3'

recipe           'system::default',             "Sets the system's hostname and timezone."
recipe           'system::timezone',            "Sets the system's' timezone."
recipe           'system::hostname',            "Sets the system's hostname."
recipe           'system::upgrade_packages',    "Upgrades the system's installed packages."
recipe           'system::update_package_list', "Updates the system's list of packages in the package manager's cache."
recipe           'system::install_packages',    "Installs packages to the system with it's native package manager."

%w{ ubuntu debian centos fedora redhat archlinux }.each do |os|
  supports os
end

depends 'apt'
depends 'cron'
depends 'hostsfile'

attribute 'system/timezone',
          display_name: 'Timezone',
          description: 'The system timezone, which must be a valid zoneinfo/tz database entry.',
          required: 'optional',
          default: 'UTC',
          recipes: ['system::timezone', 'system::default'],
          choice: [
            'Africa/Casablanca',
            'America/Bogota',
            'America/Buenos_Aires',
            'America/Caracas',
            'America/La_Paz',
            'America/Lima',
            'America/Mexico_City',
            'Asia/Almaty',
            'Asia/Baghdad',
            'Asia/Baku',
            'Asia/Bangkok',
            'Asia/Calcutta',
            'Asia/Colombo',
            'Asia/Dhaka',
            'Asia/Hong_Kong',
            'Asia/Jakarta',
            'Asia/Kabul',
            'Asia/Kamchatka',
            'Asia/Karachi',
            'Asia/Kathmandu',
            'Asia/Magadan',
            'Asia/Muscat',
            'Asia/Riyadh',
            'Asia/Seoul',
            'Asia/Singapore',
            'Asia/Tashkent',
            'Asia/Tbilisi',
            'Asia/Tehran',
            'Asia/Tokyo',
            'Asia/Vladivostok',
            'Asia/Yakutsk',
            'Asia/Yekaterinburg',
            'Atlantic/Azores',
            'Atlantic/Cape_Verde',
            'Australia/Adelaide',
            'Australia/Darwin',
            'Australia/Perth',
            'Australia/Sydney',
            'Brazil/Acre',
            'Brazil/DeNoronha',
            'Brazil/East',
            'Brazil/West',
            'Canada/Atlantic',
            'Canada/Newfoundland',
            'Europe/Brussels',
            'Europe/Copenhagen',
            'Europe/Kaliningrad',
            'Europe/Lisbon',
            'Europe/London',
            'Europe/Helsinki',
            'Europe/Madrid',
            'Europe/Moscow',
            'Europe/Paris',
            'Pacific/Auckland',
            'Pacific/Fiji',
            'Pacific/Guam',
            'Pacific/Kwajalein',
            'Pacific/Midway',
            'US/Alaska',
            'US/Central',
            'US/Eastern',
            'US/Hawaii',
            'US/Mountain',
            'US/Pacific',
            'US/Samoa',
            'GMT',
            'UTC',
            'localtime']

attribute 'system/short_hostname',
          display_name: 'Short Hostname',
          description: 'The short hostname that you would like this node to have, e.g. kryten',
          required: 'recommended',
          default: 'localhost',
          recipes: ['system::hostname', 'system::default']

attribute 'system/domain_name',
          display_name: 'Domain Name',
          description: 'The domain name that you would like this node to have, e.g. domain.suf. Note: Only set a valid domain name to satisfy the resolution of a FQDN; use ignore:ignore for no domain name.',
          required: 'recommended',
          default: 'localdomain',
          recipes: ['system::hostname', 'system::default']

attribute 'system/upgrade_packages',
          display_name: 'Upgrade Packages',
          description: "Whether or not the system::upgrade_packages recipe will physically update the system's installed packages (in compile time).",
          required: 'optional',
          choice: %w(true false),
          recipes: ['system::upgrade_packages']

attribute 'system/packages/install',
          display_name: 'Install Packages',
          description: 'An array of system packages to install with the package resource in execute phase.',
          required: 'optional',
          type: 'array',
          recipes: ['system::install_packages']

attribute 'system/packages/install_compile_time',
          display_name: 'Install Packages Compile Phase',
          description: 'An array of system packages to install with the package resource in compile phase.',
          required: 'optional',
          type: 'array',
          recipes: ['system::install_packages']

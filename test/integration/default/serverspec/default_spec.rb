# encoding: UTF-8

require_relative 'spec_helper'

# /etc/hostname
describe file('/etc/hostname') do
  it { should be_file }
  it { should be_owned_by 'root' }
end

# /etc/timezone (debian family only)
if (os[:family] == 'debian') || (os[:family] == 'ubuntu')
  describe file('/etc/timezone') do
    it { should be_file }
    it { should be_owned_by 'root' }
  end

  describe file('/etc/timezone') do
    its(:content) { should contain 'Australia/Sydney' }
  end
end

# TODO: /etc/localtime conditional tests
describe file('/etc/localtime') do
  it { should be_owned_by 'root' }
end

describe host('localhost') do
  it { should be_resolvable.by('localhost') }
  it { should be_reachable }
end

describe host('test.kitchen') do
  it { should be_resolvable.by('hosts') }
  it { should be_reachable }
end

# it's a little early to be able to expect most
# host/guest environments to be able to do these
# ipv6_hosts = %w(localhost6.localdomain6
#                localhost6
#                ip6-localhost
#                ip6-loopback
#                ip6-localnet
#                ip6-mcastprefix
#                ip6-allnodes
#                ip6-allrouters)
# ipv6_hosts.each do |host|
#   describe host(host) do
#     # ping
#     it { should be_reachable }
#     # resolution
#     it { should be_resolvable.by('hosts') }
#   end
# end

# /etc/hosts
describe file('/etc/hosts') do
  it { should contain('localhost').after('::1') }
  it { should contain('localhost').after('127.0.0.1') }
  it { should contain('localhost.localdomain').after('127.0.0.1') }
  it { should contain('localdomain').after('127.0.0.1') }
  it { should contain('chef.io').after('184.106.28.82') }
  it { should contain('supermarket.io').after('95.211.29.66') }
end

# el6 and older
if %w(redhat).include?(os[:family]) && os[:release] < '7.0'
  describe file('/etc/sysconfig/network') do
    it 'is a file' do
      expect(subject).to be_file
    end
    it { should contain 'HOSTNAME=test.kitchen' }
  end
end

# the cron service should be running
case os[:family]
when 'redhat', 'fedora'
  cron_service_name = 'crond'
when 'gentoo'
  cron_service_name = 'vixie-cron'
when 'arch'
  cron_service_name = 'cronie'
else
  cron_service_name = 'cron'
end

describe service(cron_service_name) do
  it { should be_running }
end

describe file('/etc/profile') do
  its(:content) { should contain 'export CHEF_IS_AWESOME=1' }
  its(:content) { should contain('/opt/local/bin').after('PATH=') }
  its(:content) { should contain('/opt/local/food/bin').after('PATH=') }
end

describe file('/etc/environment') do
  its(:content) { should contain "DINNER=Pizza" }
  its(:content) { should contain "DESERT=Ice cream" }
end

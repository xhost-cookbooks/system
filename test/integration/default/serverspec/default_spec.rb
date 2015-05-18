# encoding: UTF-8

require_relative 'spec_helper'

# /etc/hostname
describe file('/etc/hostname') do
  it { should be_file }
end

describe file('/etc/hostname') do
  it { should be_owned_by 'root' }
end

# /etc/timezone (debian family only)
if (os[:family] == 'debian') || (os[:family] == 'ubuntu')
  describe file('/etc/timezone') do
    it { should be_file }
  end

  describe file('/etc/timezone') do
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
end

describe host('test.kitchen') do
  it { should be_resolvable.by('hosts') }
end

describe host('localhost') do
  # ping
  it { should be_reachable }
end

describe host('test.kitchen') do
  # ping
  it { should be_reachable }
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

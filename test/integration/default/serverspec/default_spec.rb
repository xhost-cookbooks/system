# encoding: UTF-8

require_relative 'spec_helper'

describe file('/etc/hostname') do
  it { should be_file }
end

describe file('/etc/timezone') do
  it { should be_file }
end

describe file('/etc/timezone') do
  its(:content) { should contain 'Australia/Sydney' }
end

# TODO: /etc/localtime conditional tests

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

# file ownership checks
describe file('/etc/hostname') do
  it { should be_owned_by 'root' }
end

describe file('/etc/timezone') do
  it { should be_owned_by 'root' }
end

describe file('/etc/localtime') do
  it { should be_owned_by 'root' }
end

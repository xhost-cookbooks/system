# Encoding: utf-8

require_relative 'spec_helper'

describe file('/etc/hostname') do
  it { should be_file }
end

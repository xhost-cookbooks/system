# encoding: UTF-8

require 'serverspec'

set :backend, :exec

RSpec.configure do |c|
  c.before :all do
    c.path = '/bin:/sbin:/usr/bin'
  end
end

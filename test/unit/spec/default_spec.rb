# encoding: UTF-8

require_relative 'spec_helper'

describe 'system::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |_node|
      stub_command('ls /.dockerinit').and_return(false)
    end.converge(described_recipe)
  end

  it 'includes the `update_package_list` recipe' do
    expect(chef_run).to include_recipe('system::update_package_list')
  end

  it 'includes the `timezone` recipe' do
    expect(chef_run).to include_recipe('system::timezone')
  end

  it 'includes the `hostname` recipe' do
    expect(chef_run).to include_recipe('system::hostname')
  end
end

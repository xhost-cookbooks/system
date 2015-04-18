# encoding: UTF-8

require_relative 'spec_helper'

describe 'system::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

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

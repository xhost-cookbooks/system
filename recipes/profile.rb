
system_profile '/etc/profile' do
  node['system']['profile'].each do |attr, value|
    send attr, value
  end
end

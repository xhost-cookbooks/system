action :set do

# TODO: Add checking if zone file exists in the zoneinfo

log("tz-info (before): #{Time.now.strftime("%z %Z")}")

if ['debian','ubuntu'].member? node['platform']
  package "tzdata"

  bash "dpkg-reconfigure tzdata" do
    user "root"
    code "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata"
    action :nothing
  end
  
  template "/etc/timezone" do
    source "timezone.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :run, "bash[dpkg-reconfigure tzdata]"
  end
end

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{new_resource.name}"
  notifies :restart, "service[#{value_for_platform(["ubuntu","debian"] => { "default" => "cron" },"default" => "crond")}]", :immediately
end

ruby_block "verify_linked_timezone" do
  block do
    Chef::Log.info("tz-info: #{::Time.now.strftime("%z %Z")}#{::File.readlink('/etc/localtime').gsub(/^/, ' (').gsub(/$/, ')')}")
  end
end

new_resource.updated_by_last_action(true)

end # close action :set
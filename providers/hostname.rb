action :set do

require 'socket'

def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
  ensure
    Socket.do_not_reverse_lookup = orig
end

# get node IP
node_ip = "#{local_ip}"
log("Node IP: #{node_ip}") { level :debug }

# ensure the required short hostname is lower case
new_resource.short_hostname.downcase!

# set hostname from short or long (when domain_name set)
unless new_resource.domain_name.nil? || new_resource.domain_name == ''
  hostname = "#{new_resource.short_hostname}.#{new_resource.domain_name}"
  hosts_list = "#{new_resource.short_hostname}.#{new_resource.domain_name} #{new_resource.short_hostname}"
else
  hostname = "#{new_resource.short_hostname}"
  hosts_list = "#{new_resource.short_hostname}"
end
log("Setting hostname for '#{hostname}'.") { level :debug }

# Update /etc/hosts
log('Configure /etc/hosts.') { level :debug }
template "/etc/hosts" do
  source "hosts.erb"
  variables(
    :node_ip => node_ip,
    :hosts_list => hosts_list,
    :static_hosts => new_resource.static_hosts
    )
  mode 0744
end

# Update /etc/hostname
log('Configure /etc/hostname') { level :debug }
file "/etc/hostname" do
  owner "root"
  group "root"
  mode "0755"
  content "#{new_resource.short_hostname}"
  action :create
end

# Call hostname command
log('Setting hostname.') { level :debug }
if platform?('centos', 'redhat')
  bash "set_hostname" do
    code <<-EOH
      sed -i "s/HOSTNAME=.*/HOSTNAME=#{hostname}/" /etc/sysconfig/network
      hostname #{hostname}
    EOH
  end
else
  bash "set_hostname" do
    code <<-EOH
      hostname #{hostname}
    EOH
  end
end

# Call domainname command
if node['platform'] != 'archlinux' and ( !new_resource.domain_name.nil? || new_resource.domain_name != "" )
  log('Running domainname') { level :debug }
  bash "set_domainname" do
    code <<-EOH
    domainname #{new_resource.domain_name}
    EOH
  end
end

# restart hostname services on appropriate platforms
if platform?('ubuntu')
  log('Starting hostname service.') { level :debug }
  service "hostname" do
  service_name "hostname"
  supports :restart => true, :status => true, :reload => true
  action :restart
  end
end
if platform?('debian')
  log('Starting hostname.sh service.') { level :debug }
  service "hostname.sh" do
  service_name "hostname.sh"
  supports :restart => false, :status => true, :reload => false
  action :start
  end
end

# rightlink commandline tools set tag with rs_tag
# the rs_tag command exits 127 or similar on occasion, though not from command line (not sure why); hopefully || true can be removed in the future
script "set_node_hostname_tag" do
  interpreter "bash"
  user "root"
  code <<-EOH
( if type -P rs_tag &>/dev/null; then rs_tag --add 'node:hostname=#{hostname}'; fi ) || true
  EOH
end

# reload ohai hostname plugin for subsequent recipes in the run_list, or not (http://tickets.opscode.com/browse/OHAI-389?focusedCommentId=26255&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-26255)
#ohai "reload_hostname_info_from_ohai" do
#  plugin "hostname"
#end

# manually update node & automatic attributes (probably won't do anything heh)
node.automatic_attrs['hostname'] = `hostname -f`.strip
node.automatic_attrs['fqdn'] = `hostname -f`.strip
node.set['fqdn'] = `hostname -f`.strip
node.set['hostname'] = `hostname -f`.strip

#node.save

# Show the new host/node information (after ohai reload from provider)
ruby_block "show_host_info" do
  block do
    # show new host values from system
    Chef::Log.info("== New host/node information ==")
    Chef::Log.info("Hostname: #{`hostname`.strip == '' ? '<none>' : `hostname`.strip}")
    Chef::Log.info("Network node hostname: #{`uname -n`.strip == '' ? '<none>' : `uname -n`.strip}")
    Chef::Log.info("Alias names of host: #{`hostname -a`.strip == '' ? '<none>' : `hostname -a`.strip}")
    Chef::Log.info("Short host name (cut from first dot of hostname): #{`hostname -s`.strip == '' ? '<none>' : `hostname -s`.strip}")
    Chef::Log.info("Domain of hostname: #{`hostname -d`.strip == '' ? '<none>' : `hostname -d`.strip}")
    Chef::Log.info("FQDN of host: #{`hostname -f`.strip == '' ? '<none>' : `hostname -f`.strip}")
    Chef::Log.info("IP addresses for the hostname: #{`hostname -i`.strip == '' ? '<none>' : `hostname -i`.strip}")
    Chef::Log.info("Current Chef FQDN loaded from Ohai: #{node['fqdn']}")
  end
end

new_resource.updated_by_last_action(true)

end # close action :set
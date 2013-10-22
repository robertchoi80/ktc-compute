chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "ktc-compute::source_install"
include_recipe "openstack-compute::nova-common"

vnc_server_listen = node["openstack"]["compute"]["vncserver_listen"]
rewind :template => "/etc/nova/nova.conf" do
  cookbook "ktc-compute"
  variables(
    :vncserver_listen => vnc_server_listen
  )

end

cookbook_file "/etc/nova/policy.json" do
  source "policy.json"
  owner node["openstack"]["compute"]["user"]
  group node["openstack"]["compute"]["group"]
  mode 00640
  action :create
end

chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "openstack-compute::nova-setup"

rewind :template => "/etc/nova/nova.conf" do
  cookbook "ktc-compute"
end


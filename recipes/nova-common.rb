chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "ktc-compute::source_install"
include_recipe "openstack-compute::nova-common"

rewind :template => "/etc/nova/nova.conf" do
  cookbook "ktc-compute"
end


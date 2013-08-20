# Cookbook Name:: ktc-compute
# Recipe:: compute-api
#

class Chef::Recipe
  include KTCUtils
end

d1 = get_openstack_service_template(get_interface_address("management"), "8774")
register_member("compute-api", d1)

d2 = get_openstack_service_template(get_interface_address("management"), "8773")
register_member("compute-ec2-api", d2)

d3 = get_openstack_service_template(get_interface_address("management"), "8773")
register_member("compute-ec2-admin", d3)

set_rabbit_servers "compute"
set_memcached_servers
set_database_servers "compute"
set_service_endpoint_ip "compute-api"
set_service_endpoint_ip "compute-ec2-api"

include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "openstack-object-storage::memcached"
include_recipe "openstack-compute::nova-setup"
include_recipe "openstack-compute::scheduler"
include_recipe "openstack-compute::api-ec2"
include_recipe "openstack-compute::api-os-compute"
include_recipe "openstack-compute::api-metadata"
include_recipe "openstack-compute::nova-cert"
include_recipe "openstack-compute::vncproxy"
include_recipe "openstack-compute::identity_registration"

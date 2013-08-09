# Cookbook Name:: ktc-compute
# Recipe:: compute-api
#

class Chef::Recipe
  include KTCUtils
end

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

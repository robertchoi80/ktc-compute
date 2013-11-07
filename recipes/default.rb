#
# Cookbook Name:: ktc-nova
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "openstack-object-storage::memcached"
include_recipe "ktc-network::common"
include_recipe "ktc-compute::compute"
include_recipe "ktc-monitor::client"

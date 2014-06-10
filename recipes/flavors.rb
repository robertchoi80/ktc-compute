return unless node['openstack']['compute']['flavors']['action']

require 'uri'

# include Openstack libraries
# rubocop:disable ClassAndModuleChildren
class ::Chef::Recipe
  include ::Openstack
end

include_recipe 'ktc-compute::nova_common'

identity_admin_endpoint = endpoint 'identity-admin'
auth_uri = ::URI.decode identity_admin_endpoint.to_s
service_pass = service_password 'openstack-compute'
service_user = node['openstack']['compute']['service_user']
service_tenant_name = node['openstack']['compute']['service_tenant_name']

node['openstack']['compute']['flavors']['list'].each do |flavor|
  ktc_compute_flavor "Flavor: #{flavor['options']['name']}" do
    auth_uri auth_uri
    user_pass service_pass
    tenant_name service_tenant_name
    user_name service_user
    options flavor['options']
    action flavor['action'] || :create
  end
end

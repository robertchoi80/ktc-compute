chef_gem 'chef-rewind'
require 'chef/rewind'

ENV['PYTHON_EGG_CACHE'] = '/tmp'

include_recipe 'ktc-package'
include_recipe 'ktc-compute::package_setup'
include_recipe 'openstack-compute::nova-common'

rewind template: '/etc/nova/nova.conf' do
  cookbook 'ktc-compute'
end

cookbook_file '/etc/nova/policy.json' do
  source 'policy.json'
  owner node['openstack']['compute']['user']
  group node['openstack']['compute']['group']
  mode 00640
  action :create
end

cookbook_file '/etc/bash_completion.d/nova' do
  source 'etc/bash_completion.d/nova'
  mode 00640
  action :create
end

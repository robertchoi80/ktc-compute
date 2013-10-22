#
# vim: set ft=ruby:
#

chef_api "https://chefdev.mkd2.ktc", node_name: "cookbook", client_key: ".cookbook.pem"

metadata

group :integration do
  cookbook 'ktc-block-storage'
  cookbook 'ktc-database'
  cookbook 'ktc-etcd'
  cookbook 'ktc-identity'
  cookbook 'ktc-image'
  cookbook 'ktc-memcached'
  cookbook 'ktc-messaging'
  cookbook 'ktc-network'
  cookbook 'ktc-testing'
end

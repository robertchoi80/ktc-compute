maintainer        "KT Cloudware, Inc."
description       "Wrapper cookbook of rcb's nova cookbook"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "2.0.1"
recipe		        "compute", "Include recipes required for compute node"
recipe		        "compute-api", "Include recipes required for control node"

%w{ centos ubuntu }.each do |os|
  supports os
end

%w{
  ark
  ktc-base
  ktc-utils
  ktc-network
  openstack-common
  openstack-compute
  openstack-object-storage
}.each do |dep|
  depends dep
end


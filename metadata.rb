maintainer        "KT Cloudware, Inc."
description       "Wrapper cookbook of rcb's nova cookbook"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "2.0.1"
recipe		        "compute", ""

%w{ centos ubuntu }.each do |os|
  supports os
end

%w{
  ktc-utils
  openstack-common
  openstack-compute
  openstack-object-storage
}.each do |dep|
  depends dep
end


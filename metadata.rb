name              'ktc-compute'
maintainer        'KT Cloudware, Inc.'
maintainer_email  'wil.reichert@kt.com'
license           'All rights reserved'
description       "Wrapper cookbook of rcb's nova cookbook"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '2.1.34'
recipe		        'compute', 'Include recipes required for compute node'
recipe		        'compute-api', 'Include recipes required for control node'

%w(centos ubuntu).each do |os|
  supports os
end

depends 'ark', '>= 0.3.2'
depends 'ktc-base'
depends 'ktc-logging'
depends 'ktc-monitor'
depends 'ktc-network', '>= 0.2.5'
depends 'ktc-package', '>= 0.1.1'
depends 'ktc-utils', '>= 0.3.6'
depends 'openstack-common', '~> 0.4.3'
depends 'openstack-compute', '~> 7.0.0'
depends 'python', '>= 1.4.0'
depends 'services', '>= 1.1.0'
depends 'sudo'

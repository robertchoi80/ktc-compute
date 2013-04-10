maintainer        "KT Cloudware, Inc."
description       "Wrapper cookbook of rcb's nova cookbook"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.21"
recipe		        "compute", ""

%w{ centos ubuntu }.each do |os|
  supports os
end

%w{ nova }.each do |dep|
  depends dep
end


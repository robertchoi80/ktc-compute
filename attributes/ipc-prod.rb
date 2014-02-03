return  unless chef_environment == "ipc-prod"
# we want to override defaults
include_attribute "ktc-compute::flavors"

default["openstack"]["compute"]["flavors"]["action"] = true
default["openstack"]["compute"]["flavors"]["list"] = [
  {
    "action" => :delete,
    "options" => {
      "name" => "m1.tiny"
    }
  },
  {
    "action" => :delete,
    "options" => {
      "name" => "m1.small"
    }
  },
  {
    "action" => :delete,
    "options" => {
      "name" => "m1.medium"
    }
  },
  {
    "action" => :delete,
    "options" => {
      "name" => "m1.large"
    }
  },
  {
    "action" => :delete,
    "options" => {
      "name" => "m1.xlarge"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "1c1g",
      "ram" => 1024,
      "vcpus" => 1,
      "disk" => 0,
      "id" => "1"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "1c2g",
      "ram" => 2048,
      "vcpus" => 1,
      "disk" => 0,
      "id" => "2"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "2c2g",
      "ram" => 2048,
      "vcpus" => 2,
      "disk" => 0,
      "id" => "3"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "2c4g",
      "ram" => 4096,
      "vcpus" => 2,
      "disk" => 0,
      "id" => "4"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "2c8g",
      "ram" => 8192,
      "vcpus" => 2,
      "disk" => 0,
      "id" => "5"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "2c16g",
      "ram" => 16384,
      "vcpus" => 2,
      "disk" => 0,
      "id" => "6"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "4c4g",
      "ram" => 4096,
      "vcpus" => 4,
      "disk" => 0,
      "id" => "7"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "4c8g",
      "ram" => 8192,
      "vcpus" => 4,
      "disk" => 0,
      "id" => "8"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "4c16g",
      "ram" => 16384,
      "vcpus" => 4,
      "disk" => 0,
      "id" => "9"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "4c32g",
      "ram" => 32768,
      "vcpus" => 4,
      "disk" => 0,
      "id" => "10"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "8c8g",
      "ram" => 8192,
      "vcpus" => 8,
      "disk" => 0,
      "id" => "11"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "8c16g",
      "ram" => 16384,
      "vcpus" => 8,
      "disk" => 0,
      "id" => "12"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "8c32g",
      "ram" => 32768,
      "vcpus" => 8,
      "disk" => 0,
      "id" => "13"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "12c16g",
      "ram" => 16384,
      "vcpus" => 12,
      "disk" => 0,
      "id" => "14"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "12c32g",
      "ram" => 32768,
      "vcpus" => 12,
      "disk" => 0,
      "id" => "15"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "16c16g",
      "ram" => 16384,
      "vcpus" => 16,
      "disk" => 0,
      "id" => "16"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "16c32g",
      "ram" => 32768,
      "vcpus" => 16,
      "disk" => 0,
      "id" => "17"
    }
  },
  {
    "action" => :create,
    "options" => {
      "name" => "16c62g",
      "ram" => 63488,
      "vcpus" => 16,
      "disk" => 0,
      "id" => "18"
    }
  }
]

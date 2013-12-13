default["openstack"]["compute"]["flavors"]["action"] = false
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
  }
]

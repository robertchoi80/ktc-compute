# vim: ft=sh:

@test "compute-metadata-api registered with etcd" {
  curl http://127.0.0.1:4001/v1/keys/services/compute-metadata-api/members
}

@test "compute-api registered with etcd" {
  curl http://127.0.0.1:4001/v1/keys/services/compute-api/members
}

@test "compute-ec2-api registered with etcd" {
  curl http://127.0.0.1:4001/v1/keys/services/compute-ec2-api/members
}

@test "compute-xvpvnc registered with etcd" {
  curl http://127.0.0.1:4001/v1/keys/services/compute-xvpvnc/members
}

@test "compute-novnc registered with etcd" {
  curl http://127.0.0.1:4001/v1/keys/services/compute-novnc/members
}

@test "compute-metadata-api is running" {
  netstat -tan | grep 8775
}

@test "compute-api is running" {
  netstat -tan | grep 8774
}

@test "compute-ec2-api is running" {
  netstat -tan | grep 8773
}

#@test "compute-xvpvnc is running" {
#  netstat -tan | grep 6081
#}

@test "compute-novnc is running" {
  netstat -tan | grep 6080
}

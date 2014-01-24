# vim: ft=sh:

@test "nova user created" {
  source /root/openrc
  keystone user-get nova
}

@test "nova list flavors" {
  source /root/openrc
  nova flavor-list
}

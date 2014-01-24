# vim: ft=sh:

@test "boot vm" {
  glance="/opt/openstack/glanceclient/bin/glance"
  source /root/openrc
  wget http://cdn.download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img
  $glance image-create --name="CirrOS 0.3.1" --disk-format=qcow2 \
      --container-format=bare --is-public=true < cirros-0.3.1-x86_64-disk.img
  image_id=`$glance image-list | grep "CirrOS 0.3.1" | cut -d' ' -f2`
  ssh-keygen -f id_rsa -P ""
  nova keypair-add --pub_key id_rsa.pub mykey
  #nova boot --flavor 1 --key_name mykey --image $image_id --security_group default cirrOS
}

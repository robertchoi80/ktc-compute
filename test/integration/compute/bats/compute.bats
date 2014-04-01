# vim: ft=sh:

@test "python-kombu package should be more than 3 " {                                      
  kombu_ver=`pip list  | grep kombu | awk '{print $2}' | tr -d '()' `    
  vergte() { [  "$1" = "`echo -e "$1\n$2" | sort -V | tail -n1`" ]; }    
  vergt() { [ "$1" = "$2" ] && return 1 || vergte $1 $2; }                                                                              
  vergt $kombu_ver 3                                                     
}

                                                                                
@test "nfs option is in the conf" {
  cat /etc/nova/nova.conf | grep nfs_mount 
}

@test "seabios version is upgraded to 1.7.3-1ubuntu0.1" {
  dpkg -s seabios | grep 1.7.3-1ubuntu0.1
}

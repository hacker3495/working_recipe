#!/bin/bash

# get configuration from /etc/ldap.conf
for x in $(sed -n 's/^\([a-zA-Z_]*\) \(.*\)$/\1="\2"/p' /etc/ldap.conf); do
    eval $x;
done

OPTIONS=
case "$ssl" in
    start_tls)
        case "$tls_checkpeer" in
            no) OPTIONS+="-Z";;
            *) OPTIONS+="-ZZ";;
        esac;;
esac

ssh_keys=`ldapsearch $OPTIONS -H ${uri} \
    -w "${bindpw}" -D "${binddn}" \
    -b "${base}" \
    '(&(objectClass=posixAccount)(uid='"$1"'))' \
    'sshPublicKey' \
    | sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;s/sshPublicKey: //gp'`

echo "SSH KEYS FROM LDAP for user $1 $ssh_keys" >> /var/log/ldap_ssh.log

echo $ssh_keys

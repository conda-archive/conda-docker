#!/bin/bash
set -euxo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if ! [ -x "$(command -v mock)" ]; then
  echo 'error: mock is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker)" ]; then
  echo 'error: docker is not installed.' >&2
  exit 1
fi

name="centos6-32-minimal-base"
currdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
target="$currdir/$name"
config="$currdir/centos-6-i386.cfg"
registry="conda"

# Simplified version of https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh

mock --init -v -r centos-6-i386.cfg --rootdir="$target"

# make yum vars explicit
if [ -d /etc/yum/vars ]; then
   mkdir -p -m 755 "$target"/etc/yum
   echo "i686" > "$target"/etc/yum/vars/arch
   echo "i386" > "$target"/etc/yum/vars/basearch
fi

cat > "$target"/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

chrootcmd () {
   mock -r centos-6-i386.cfg --shell --rootdir="$target" "$@"
}

chrootcmd 'rpm --rebuilddb &> /dev/null'
chrootcmd 'yum -y clean all'
# effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb --keep-services "$target"
#  locales
# chrootcmd 'rm -rf /usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}'
#  docs and man pages
chrootcmd 'rm -rf /usr/share/{man,doc,info,gnome/help}'
#  cracklib
chrootcmd 'rm -rf /usr/share/cracklib'
#  i18n
chrootcmd 'rm -rf /usr/share/i18n'
#  yum cache
chrootcmd 'rm -rf /var/cache/yum || true'
chrootcmd 'mkdir -p --mode=0755 /var/cache/yum'
#  sln
chrootcmd 'rm -rf /sbin/sln'
#  ldconfig
chrootcmd 'rm -rf /etc/ld.so.cache /var/cache/ldconfig'
chrootcmd 'mkdir -p --mode=0755 /var/cache/ldconfig'
#  bring back the default yum config
chrootcmd 'mv /etc/yum.conf.rpmnew /etc/yum.conf'
#  this should be the last chroot command since
#  each invocation of mock creates this file
chrootcmd 'rm -f /etc/yum/yum.conf'

version=
for file in "$target"/etc/{redhat,system}-release
do
    if [ -r "$file" ]; then
        version="$(sed 's/^[^0-9\]*\([0-9.]\+\).*$/\1/' "$file")"
        break
    fi
done

if [ -z "$version" ]; then
    echo >&2 "warning: cannot autodetect OS version, using '$name' as tag"
    version=$name
fi

tar --numeric-owner -cf "${currdir}/${name}.tar" -C "$target" .

docker build -t "$registry/$name:$version" $currdir

docker run -i -t --rm "$registry/$name:$version" /bin/bash -c 'echo success'

rm -f "${currdir}/${name}.tar"
rm -rf "$target"

#!/bin/bash
set -euxo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if ! [ -x "$(command -v mock)" ]; then
  echo 'Error: mock is not installed.' >&2
  exit 1
fi

name="centos6-32-minimal-base"
currdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
target="$currdir/$name"
config="$currdir/centos-6-i386.cfg"
registry="conda"

# Simplified version of https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh

mock --init -v -r centos-6-i386.cfg --rootdir="$target"

# amazon linux yum will fail without vars set
if [ -d /etc/yum/vars ]; then
   mkdir -p -m 755 "$target"/etc/yum
   cp -a /etc/yum/vars "$target"/etc/yum/
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
chrootcmd 'rm -rf /usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}'
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

tar --numeric-owner -c -C "$target" . | docker import - "$registry/$name:$version"

docker run -i -t --rm "$registry/$name:$version" /bin/bash -c 'echo success'

rm -rf "$target"

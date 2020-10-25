#!/bin/bash

arch=x86_64
mirror=ftp://mirror.archlinux.no/


# link to cache (or download) and extract: openssl,libarchive,libfetch,pacman
cd /tmp
for pkg in openssl-1.0.0.e-1 libarchive-2.8.5-1 libfetch-2.33-3 pacman-3.5.4-4; do
    pkgname=${pkg}-${arch}.pkg.tar.gz
    if [[ -e /var/cache/pacman/pkg/${pkgname} ]]; then
        ln -sf /var/cache/pacman/pkg/${pkgname} .
    else
        wget ${mirror}/core/os/${arch}/${pkgname} || exit 1
    fi
    tar -xvpf ${pkgname} -C / --exclude .PKGINFO --exclude .INSTALL || exit 1
done

# now reinstall using pacman to update the local pacman db 
pacman -Sf openssl libarchive libfetch pacman || exit 1

# now update your system
pacman -Syu

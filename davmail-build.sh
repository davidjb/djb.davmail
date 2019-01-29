#!/bin/sh
set -e
# Get source package
sudo apt source davmail

# Install build dependencies
sudo apt build-dep -y davmail

# Patch and rebuild
cd davmail-* || exit
patch -p1 < /app/patches/davmail-userwhitelist.patch
EDITOR=/bin/true dpkg-source -q --commit . userwhitelist.patch
debuild -us -uc

# Test installation of output package
sudo dpkg -i ../davmail_*.deb
sudo apt --fix-broken install -y

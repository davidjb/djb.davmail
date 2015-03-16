#!/bin/sh

#Clean up old nginx builds
sudo rm -rf ~/rpmbuild/RPMS/*/davmail-*.rpm

#Install required packages for building
sudo yum install -y \
    rpm-build \
    rpmdevtools \
    yum-utils \
    wget


#Install source RPM for davmail
sudo wget http://download.opensuse.org/repositories/home:/mguessan:/branches:/home:/achimh:/branches:/home:/dammage:/davmail/Fedora_21/home:mguessan:branches:home:achimh:branches:home:dammage:davmail.repo -O /etc/yum.repos.d/davmail.repo
yumdownloader --source davmail
sudo rpm -ihv davmail*.src.rpm

#Prep and patch the Nginx specfile for the RPMs
#Note: expects to have the repository contents located in ~/rpmbuild/SPECS/
#      or located at /vagrant 
pushd ~/rpmbuild/SPECS
if [ -d "/vagrant" ]; then
    cp -n -f /vagrant/davmail-spec.patch ~/rpmbuild/SPECS/
    cp -n -f /vagrant/davmail-*.patch ~/rpmbuild/SOURCES/
fi
patch -p1 < davmail-spec.patch
spectool -g -R davmail.spec
yum-builddep -y davmail.spec
rpmbuild -ba davmail.spec

#Test installation and check output
sudo yum remove -y davmail
sudo yum install -y ~/rpmbuild/RPMS/*/davmail-*.rpm

#!/bin/bash

VERSION=2.7.1

if [ ! -f "hadoop-$VERSION.tar.gz" ]; then
    wget http://archive.eu.apache.org/dist/hadoop/common/hadoop-${VERSION}/hadoop-${VERSION}.tar.gz
fi

tar -xzf hadoop-$VERSION.tar.gz
mv hadoop-$VERSION /usr/lib
ln -s /usr/lib/hadoop-$VERSION /usr/lib/hadoop

# Copy template
cp hdfs-site.template /usr/lib/hadoop/etc/hadoop/

mv dockmobStart.sh /usr/lib/hadoop/bin



#!/bin/bash

VERSION=2.7.1

if [ ! -f "hadoop-$VERSION.tar.gz" ]; then
    wget http://archive.eu.apache.org/dist/hadoop/common/hadoop-${VERSION}/hadoop-${VERSION}.tar.gz
fi

tar -xzf hadoop-$VERSION.tar.gz
mv hadoop-$VERSION /usr/lib
ln -s /usr/lib/hadoop-$VERSION /usr/lib/hadoop

# Remove unnecessary files
rm -rf /usr/lib/hadoop/share/doc
rm -rf /usr/lib/hadoop/share/hadoop/common/sources
rm -rf /usr/lib/hadoop/share/hadoop/common/jdiff
rm -rf /usr/lib/hadoop/share/hadoop/hdfs/sources
rm -rf /usr/lib/hadoop/share/hadoop/mapreduce/sources
rm -rf /usr/lib/hadoop/share/hadoop/mapreduce/lib-examples
rm -rf /usr/lib/hadoop/share/hadoop/tools/sources
rm -rf /usr/lib/hadoop/share/hadoop/yarn/sources
rm -rf /usr/lib/hadoop/share/hadoop/yarn/test
find /usr/lib/hadoop/share -name *test*.jar | xargs rm -rf
find /usr/lib/hadoop/share -name *example*.jar | xargs rm -rf

# Remove heavy unused parts
rm -rf /usr/lib/hadoop/share/hadoop/httpfs
rm -rf /usr/lib/hadoop/share/hadoop/kms

# Remove archive
rm -rf /setup/*.gz

# Copy template
cp hdfs-site.template /usr/lib/hadoop/etc/hadoop/
cp hdfs-site.template.local /usr/lib/hadoop/etc/hadoop/
cp core-site.template /usr/lib/hadoop/etc/hadoop/

mv dockmobStart.sh /usr/lib/hadoop/bin



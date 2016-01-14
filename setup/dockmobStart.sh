#!/bin/bash

if [ ! -f /var/hadoop/config_ok ];
then
    set -e

    usage() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t [namenode|datanode|pseudodistributed]" 1>&2; exit 1; }
    usagenamenode() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t namenode -r <replication-factor>" 1>&2; exit 1; }
    usagedatanode() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t datanode -n <namenode-host>" 1>&2; exit 1; }
    usagepseudodistributed() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t pseudodistributed" 1>&2; exit 1; }

    while getopts ":n:r:t:" o; do
        case "${o}" in
            t)
                t=${OPTARG}
                ;;
            n)
                n=${OPTARG}
                ;;
            r)
                r=${OPTARG}
                ;;
            *)
                usage
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${t}" ] || [ "${t}" != "namenode" ] && [ "${t}" != "datanode" ] && [ "${t}" != "pseudodistributed" ]; then
        usage
    elif [ "${t}" == "namenode" ]; then
        echo "Starting $t"

        if [ -z "${r}" ]; then
            usagenamenode
        fi

        HOSTNAME=$(cat /etc/hostname)

        echo "Hostname=$HOSTNAME"

        sed -e "s#\$DATA_DIRECTORY#${DATA_DIRECTORY}#" -e "s#\$NAMENODE_HOST#$HOSTNAME#" -e "s#\$NAMENODE_BIND_TO##" -e "s#\$REPLICATION#$r#" /usr/lib/hadoop/etc/hadoop/hdfs-site.template > /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
        sed -e "s#\$NAMENODE_HOST#$HOSTNAME#" /usr/lib/hadoop/etc/hadoop/core-site.template > /usr/lib/hadoop/etc/hadoop/core-site.xml

        ./hdfs namenode -format

        ./hdfs $t

    elif [ "${t}" == "datanode" ]; then
        echo "Starting $t"

        if [ -z "${n}" ]; then
            usagedatanode
        fi

        HOSTNAME=$(cat /etc/hostname)

        echo "Hostname=$HOSTNAME"
        NAMENODE_HP="${n}:8020"
        sed -e "s#\$DATA_DIRECTORY#${DATA_DIRECTORY}#" -e "s#\$NAMENODE_HOST#$HOSTNAME#" -e "s#\$NAMENODE_BIND_TO#$NAMENODE_HP#"  -e "s#\$REPLICATION##" /usr/lib/hadoop/etc/hadoop/hdfs-site.template > /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
        sed -e "s#\$NAMENODE_HOST#$HOSTNAME#" /usr/lib/hadoop/etc/hadoop/core-site.template > /usr/lib/hadoop/etc/hadoop/core-site.xml

        ./hdfs $t
    elif [ "${t}" == "pseudodistributed" ]; then
        echo "Starting $t"

        HOSTNAME=$(cat /etc/hostname)

        echo "Hostname=$HOSTNAME"
        NAMENODE_HP="${HOSTNAME}:8020"

        sed -e "s#\$DATA_DIRECTORY#${DATA_DIRECTORY}#" -e "s#\$NAMENODE_HOST#$HOSTNAME#" -e "s#\$NAMENODE_BIND_TO##" -e "s#\$REPLICATION#1#" /usr/lib/hadoop/etc/hadoop/hdfs-site.template.local > /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
        sed -e "s#\$DATA_DIRECTORY#${DATA_DIRECTORY}#" -e "s#\$NAMENODE_HOST#$HOSTNAME#" -e "s#\$NAMENODE_BIND_TO#$NAMENODE_HP#" -e "s#\$REPLICATION#1#" /usr/lib/hadoop/etc/hadoop/hdfs-site.template.local > /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.datanode
        sed -e "s#\$NAMENODE_HOST#$HOSTNAME#" /usr/lib/hadoop/etc/hadoop/core-site.template > /usr/lib/hadoop/etc/hadoop/core-site.xml

        ./hdfs namenode -format

        echo "Starting namenode"
        ./hdfs namenode > /var/log/namenode.log 2>&1 &

        echo "Waiting port 8020"
        while ! nc -z $HOSTNAME 8020; do sleep 1; done

        mv /usr/lib/hadoop/etc/hadoop/hdfs-site.xml /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.namenode
        mv /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.datanode /usr/lib/hadoop/etc/hadoop/hdfs-site.xml

        echo "Starting datanode"
        ./hdfs datanode
    fi

    echo "$t" > /var/hadoop/config_ok

else
    t=$(cat /var/hadoop/config_ok)
    echo "Restarting $t"
    if [ "${t}" == "pseudodistributed" ]; then
        mv /usr/lib/hadoop/etc/hadoop/hdfs-site.xml /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.datanode
        mv /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.namenode /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
        ./hdfs namenode > /var/log/namenode.log 2>&1 &
        echo "Waiting port 8020"
        while ! nc -z $HOSTNAME 8020; do sleep 1; done

        mv /usr/lib/hadoop/etc/hadoop/hdfs-site.xml /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.namenode
        mv /usr/lib/hadoop/etc/hadoop/hdfs-site.xml.datanode /usr/lib/hadoop/etc/hadoop/hdfs-site.xml

        ./hdfs datanode
    else
        ./hdfs $t
    fi
fi




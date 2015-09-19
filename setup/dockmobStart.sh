#!/bin/bash

if [ ! -f /var/hadoop/config_ok ];
then
    set -e

    usage() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t [namenode|datanode]" 1>&2; exit 1; }
    usagenamenode() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t namenode -r <replication-factor>" 1>&2; exit 1; }
    usagedatanode() { echo "Usage: docker run [<docker options>] dockmob/hadoop -t datanode -n <namenode-host>" 1>&2; exit 1; }

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

    if [ -z "${t}" ] || [ "${t}" != "namenode" ] && [ "${t}" != "datanode" ]; then
        usage
    elif [ "${t}" == "namenode" ]; then
        echo "Starting $t"

        if [ -z "${r}" ]; then
            usagenamenode
        fi

        HOSTNAME=$(cat /etc/hostname)

        echo "Hostname=$HOSTNAME"

        sed -e "s/\$NAMENODE_HOST/$HOSTNAME/" -e "s/\$NAMENODE_BIND_TO//" -e "s/\$REPLICATION/$r/" /usr/lib/hadoop/etc/hadoop/hdfs-site.template > /usr/lib/hadoop/etc/hadoop/hdfs-site.xml
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
        sed -e "s/\$NAMENODE_HOST/$HOSTNAME/" -e "s/\$NAMENODE_BIND_TO/$NAMENODE_HP/"  -e "s/\$REPLICATION//" /usr/lib/hadoop/etc/hadoop/hdfs-site.template > /usr/lib/hadoop/etc/hadoop/hdfs-site.xml

        ./hdfs $t
    fi

    echo "$t" > /var/hadoop/config_ok

else
    t=$(cat /var/hadoop/config_ok)
    echo "Restarting $t"
    ./hdfs $t
fi




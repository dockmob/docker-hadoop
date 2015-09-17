# docker-hadoop
Docker images for Apache Hadoop (YARN, HDFS, MapReduce).

## HDFS
A HDFS cluster consists of a Namenode container and at least 3 Datanode containers. 
Both namenodes and datanodes can be provisioned using the *dockmob/hadoop* image as follows.

```
docker run -d -h dfs --name dfs dockmob/hadoop -t namenode
docker run -d -h dn1 --name dn1 dockmob/hadoop -t datanode -n dfs
docker run -d -h dn2 --name dn2 dockmob/hadoop -t datanode -n dfs
docker run -d -h dn3 --name dn3 dockmob/hadoop -t datanode -n dfs
```


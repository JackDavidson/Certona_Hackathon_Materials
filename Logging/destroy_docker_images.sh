#! /bin/bash

workdir=`pwd`

$workdir/ELK/destroy_containers.sh $workdir/ELK
$workdir/InfluxDB_Grafana/destroy_containers.sh $workdir/InfluxDB_Grafana

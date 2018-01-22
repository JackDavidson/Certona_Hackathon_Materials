#! /bin/bash
workdir=$1

for container in influxdb_for_certona grafana_for_certona telegraf_for_certona; do
	echo "stopping $container"
	sudo docker stop $container
	echo "destroying $container"
	sudo docker rm $container
	echo
done

sleep 3
echo 'displaying still running containers'
sudo docker ps

echo 'removing service directories'
sudo rm -rf $workdir/influxdb/ $workdir/telegraf/ $workdir/grafana/

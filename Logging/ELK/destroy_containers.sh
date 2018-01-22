#! /bin/bash
workdir=$1

for container in elastic_search_for_certona kibana_for_certona logstash_for_certona filebeat_for_certona; do
	echo "stopping $container"
	sudo docker stop $container
	echo "destroying $container"
	sudo docker rm $container
	echo
done

sleep 3
echo 'displaying still running containers'
sudo docker ps

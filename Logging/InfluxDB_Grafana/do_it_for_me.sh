#! /bin/bash

workdir=$1
GRAFANA_IP='15.15.1.6'
INFLUXDB_IP='15.15.1.7'
TELEGRAF_IP='15.15.1.8'

sudo mkdir -p $workdir/grafana
sudo chown root:root $workdir/grafana
sudo mkdir -p $workdir/influxdb
sudo chown root:root $workdir/influxdb
sudo chmod 777 $workdir/influxdb
sudo mkdir -p $workdir/telegraf
sudo chown root:root $workdir/telegraf
sudo chmod 777 $workdir/telegraf

echo 'Building influxdb default config'
sudo docker run --rm --net esnetwork --ip $INFLUXDB_IP --name=influxdb_for_certona -p 8083:8083 -p 8086:8086 -v $workdir/influxdb/:/var/lib/influxdb influxdb influxd config > $workdir/influxdb/influxdb.conf
echo 'starting influxdb under docker'
sudo docker run --net esnetwork --ip $INFLUXDB_IP --name=influxdb_for_certona -p 8083:8083 -p 8086:8086 -v $workdir/influxdb/:/var/lib/influxdb -v $workdir/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf influxdb > /dev/null 2>/dev/null &
echo 'influxdb should be up and running'
echo
echo 'Building telegraf default config'
sudo docker run --rm --net esnetwork --ip $TELEGRAF_IP --name=telegraf_for_certona --link influxdb_for_certona telegraf -sample-config > $workdir/telegraf/telegraf.conf
sudo sed -i 's/127.0.0.1/influxdb_for_certona/g' $workdir/telegraf/telegraf.conf
echo 'starting telegraf under docker'
sudo docker run --net esnetwork --ip $TELEGRAF_IP --name=telegraf_for_certona -v $workdir/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf --link influxdb_for_certona telegraf > /dev/null 2>/dev/null &
echo 'telegraf should be up and running'
echo
echo 'starting grafana under docker'
sudo docker run --net esnetwork --ip $GRAFANA_IP --name=grafana_for_certona -d -p 3000:3000 -v $workdir/grafana/:/var/lib/grafana --link influxdb_for_certona grafana/grafana > /dev/null 2>/dev/null &
echo 'grafana should be up and running'
echo
sleep 3
echo 'running docker processes:'
sudo docker ps
echo
echo 'opening port for grafana to the world'
sudo ufw allow 3000
echo 'opening admin port for influxdb to the world'
sudo ufw allow 8083
echo 'opening data port for influxdb to the world'
sudo ufw allow 8086

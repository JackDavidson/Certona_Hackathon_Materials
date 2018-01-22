echo 'creating a subnet for docker at 15.15.1.0/24'
sudo docker network create --subnet=15.15.1.0/24 esnetwork

workdir=`pwd`

$workdir/ELK/do_it_for_me.sh $workdir/ELK
$workdir/InfluxDB_Grafana/do_it_for_me.sh $workdir/InfluxDB_Grafana

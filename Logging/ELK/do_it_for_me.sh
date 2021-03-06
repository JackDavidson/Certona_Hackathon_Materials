#! /bin/bash

workdir=$1
ELASTIC_SEARCH_IP='15.15.1.2'
KIBANA_IP='15.15.1.3'
LOGSTASH_IP='15.15.1.4'
FILEBEAT_IP='15.15.1.5'

echo 'modifying sysctl vm.max_map_count for elastic search'
sudo sysctl -w vm.max_map_count=262144

echo 'starting up elastic search'
sudo docker run --net esnetwork --ip $ELASTIC_SEARCH_IP -p 9200:9200 --name=elastic_search_for_certona -d -e ELASTIC_PASSWORD=ElasticPass docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.1 > /dev/null 2>/dev/null
echo 'elastic search should be up and running.'
echo
echo
echo 'starting up kibana oss (without X-Pack)'
sudo docker run --net esnetwork --ip $KIBANA_IP -p 5601:5601 --net esnetwork --name=kibana_for_certona -d -e ELASTICSEARCH_URL='http://'$ELASTIC_SEARCH_IP':9200' -e ELASTICSEARCH_PASSWORD='ElasticPass' docker.elastic.co/kibana/kibana-oss:6.1.1 > /dev/null 2>/dev/null
echo 'kibana should be up and running.'
echo
echo 'starting logstash in a docker image'
sudo docker run --net esnetwork --ip $LOGSTASH_IP --name=logstash_for_certona --rm -d -v $workdir/logstash_config/:/usr/share/logstash/pipeline/ docker.elastic.co/logstash/logstash-oss:6.1.1
echo 'logstash should be up and running'
echo
echo 'starting filebeat under docker'
sudo chown root:root $workdir/filebeat_config/filebeat_conf.yml
sudo chmod 604 $workdir/filebeat_config/filebeat_conf.yml
sudo chmod o+r /var/log/syslog
sudo docker run --net esnetwork --ip $FILEBEAT_IP --name=filebeat_for_certona -d -v $workdir/filebeat_config/filebeat_conf.yml:/usr/share/filebeat/filebeat.yml -v /var/log/syslog:/var/log/host/syslog docker.elastic.co/beats/filebeat:6.1.1
echo 'filebeat should be up and running, and publishing syslog messages to logstash'
echo
echo 'running docker processes:'
sudo docker ps
echo
echo 'opening port for kibana to the world'
sudo ufw allow 5601
sudo ufw allow 9200

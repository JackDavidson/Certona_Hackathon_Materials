ELASTIC_SEARCH_IP='15.15.1.0'
KIBANA_IP='15.15.1.1'

echo 'creating a subnet for docker at 15.15.0.0/16'
sudo docker network create --subnet=15.15.0.0/16 esnetwork

echo 'modifying sysctl vm.max_map_count for elastic search'
sudo sysctl -w vm.max_map_count=262144

echo 'starting up elastic search'
sudo docker run --net esnetwork --ip $ELASTIC_SEARCH_IP --name=elastic_search_for_certona -d -e ELASTIC_PASSWORD=ElasticPass docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.1 > /dev/null 2>/dev/null
echo 'elastic search should be up and running.'
echo
echo
echo 'starting up kibana oss (without X-Pack)'
sudo docker run --net esnetwork --ip $KIBANA_IP -p 5601:5601 --net esnetwork --name=kibana_for_certona -d -e ELASTICSEARCH_URL='http://'$ELASTIC_SEARCH_IP':9200' -e ELASTICSEARCH_PASSWORD='ElasticPass' docker.elastic.co/kibana/kibana-oss:6.1.1 > /dev/null 2>/dev/null
echo 'kibana should be up and running.'
echo
echo 'running docker processes:'
sudo docker ps
echo
echo 'opening port for kibana to the world'
sudo ufw allow 5601

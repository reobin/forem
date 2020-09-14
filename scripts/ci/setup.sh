#!/bin/bash

set -eu

date --rfc-3339=seconds
nvm install
cp .env_sample .env

# Elasticsearch Install
curl -s -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.2-amd64.deb
sudo sed -i.old 's/-Xms1g/-Xms128m/' /etc/elasticsearch/jvm.options
sudo sed -i.old 's/-Xmx1g/-Xmx128m/' /etc/elasticsearch/jvm.options
echo -e '-XX:+DisableExplicitGC\n-Djdk.io.permissionsUseCanonicalPath=true\n-Dlog4j.skipJansi=true\n-server\n' | sudo tee -a /etc/elasticsearch/jvm.options
sudo chown -R elasticsearch:elasticsearch /etc/default/elasticsearch
sudo systemctl start elasticsearch

curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
chmod +x ./cc-test-reporter
bundle install --local --jobs 3
yarn install --frozen-lockfile
bundle exec rails db:create
bundle exec rails webpacker:compile
bundle exec rails db:schema:load

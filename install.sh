#!/bin/bash
#based on https://docs.nginx.com/nginx-management-suite/installation/vm-bare-metal/prerequisites/
#created Aug 2023
#Download Certificate and Key
sudo mkdir -p /etc/ssl/nginx
sudo mv <nginx-mgmt-suite-trial.crt> /etc/ssl/nginx/nginx-repo.crt
sudo mv <nginx-mgmt-suite-trial.key> /etc/ssl/nginx/nginx-repo.key

#Install ClickHouse
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
GNUPGHOME=$(mktemp -d)
sudo GNUPGHOME="$GNUPGHOME" gpg --no-default-keyring --keyring /usr/share/keyrings/clickhouse-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8919F6BD2B48D754
sudo rm -r "$GNUPGHOME"
sudo chmod +r /usr/share/keyrings/clickhouse-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb lts main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo apt-get install -y clickhouse-server clickhouse-client
sudo systemctl enable clickhouse-server
sudo systemctl start clickhouse-server
sudo systemctl status clickhouse-server

#Add NGINX Management Suite Repository
printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/nms/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nms.list
printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/adm/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee -a /etc/apt/sources.list.d/nms.list
sudo wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx

#Install Instance Manager and API Connectivity Manager
sudo apt-get update
sudo apt-get install -y nms-instance-manager nms-api-connectivity-manager
sudo systemctl enable nms nms-core nms-dpm nms-ingestion nms-integrations nms-acm --now
sudo systemctl restart nginx

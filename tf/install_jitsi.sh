#! /bin/bash
sudo apt -y install apt-transport-https
curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null
sudo apt-get update
echo “jitsi-videobridge jitsi-videobridge/jvb-hostname string hasemeet.haselab.net” | debconf-set-selections
echo "jitsi-meet-web-config jitsi-meet/cert-choice select 'Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)'" | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install jitsi-meet openjdk-8-jdk maven
git clone https://github.com/engesin/Jitsi-Prometheus-Exporter.git && cd Jitsi-Prometheus-Exporter
mvn package -DskipTests
sudo update-java-alternatives --set java-1.8.0-openjdk-amd64
nohup java -server -d64 -DCONFIG_HOME=./conf -jar ./target/jpe-0.0.5-SNAPSHOT.jar >/dev/null 2>&1 &

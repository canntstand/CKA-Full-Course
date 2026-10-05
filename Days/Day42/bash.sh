openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 \
-keyout certs/tls.key -out certs/tls.crt \
-subj "/CN=my-registry" -addext "subjectAltName = DNS:my-registry"

sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run --entrypoint htpasswd httpd:2 -Bbn myuser mypasswd > auth/htpasswd

kubectl create secret tls certs-secret --cert=$HOME/registry/certs/tls.crt \
--key $HOME/registry/certs/tls.key

mkdir -r /home/vagrant/repos

cat "APPLY ALL .yaml files"

export REGISTRY_NAME="my-registry"
export REGISTRY_IP="10.111.43.119"
cat "add 10.111.43.119 my-registry to /etc/hosts on all vms"

docker login my-registry:5000 -u myuser -p mypasswd
cat "time="2026-10-05T10:34:46Z" level=info msg="Error logging in to endpoint, trying next endpoint" endpoint="{https://my-registry:5000 0x2b9f05fa2b40}" error="Get \"https://my-registry:5000/v2/\": tls: failed to verify certificate: x509: certificate signed by unknown authority"
Get "https://my-registry:5000/v2/": tls: failed to verify certificate: x509: certificate signed by unknown authority"

cat "25:40"
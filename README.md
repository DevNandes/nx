# DESCRICAO

Servidor nginx.

## ARQUITETURA

- Organizacao dos diretorios:
  - `etc`: Diretorio que contem os arquivos de configuracao.
  - `scripts`: Contem os scripts para as configuracoes e startup.

### CRIACAO DA IMAGEM

A rotina abaixo descreve o processo para as intalacoes dos softwares e a criacao da imagem.

```bash

cd /home/renault
git clone [URL] 
cd /home/renault/nx

# Dirs
sudo ./scripts/host/create_dirs.pl

# Criacao da imagem
docker build -t nx:latest .

# Sobe o container
make run_dev
make post_install

# No host: Salva a imagem com a instalacao do Genesis e as automacoes
# Importante: utilizar o id do container nos comandos commit
docker commit --message='Set Timezone' `docker ps -aqf "name=nx"` nx:latest
docker images
docker save nx:latest | gzip > /home/renault/images/nx.tar.gz

docker image inspect -f {{.Config.Cmd}} nx:latest
docker image inspect -f {{.Comment}} nx:latest
docker image history nx:latest

```

### CRIACAO DO CONTAINER

```bash

# Na estacao DEV  >>>>>>>
ssh-copy-id USER@HOST
ssh USER@HOST
# <<<<<<<<<<<<<<<<<<<<<<<

# Na estacao de destino >>>>>>>>>>>>>>>>>>>>>>>>
sudo mkdir -p /home/renault/images
sudo mkdir -p /home/renault/nx
sudo chown -R $USER:$USER /home/renault/nx
sudo chmod -R 0775 /home/renault/nx
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Na estacao DEV >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cd /home/renault/nx
make push_image user=USER host=HOST  # USER / HOST na estacao remota
make deploy user=USER host=HOST      # USER / HOST na estacao remota
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# A partir daqui, as acoes devem ser executadas na estacao remota de destino
docker load < /home/renault/images/nx.tar.gz
docker images
docker ps -a

cd /home/renault/nx
sudo ./scripts/host/create_dirs.pl

make run_dev

# Log: logrotate
sudo cp ./etc/logrotate.d/nx /etc/logrotate.d/
sudo chmod 0644 /etc/logrotate.d/nx
sudo logrotate -d /etc/logrotate.d/nx
sudo logrotate /etc/logrotate.d/nx

# Liberar portas (Debian)
sudo ufw allow 3080/tcp
sudo ufw allow 3070/tcp
sudo ufw allow 3073/tcp

```

### DEPLOYMENTS

```bash

# Entra em uma estacao DEV...
cd /home/renault/nx
make push_image user=USER host=HOST  # USER / HOST na estacao remota
make deploy user=USER host=HOST      # USER / HOST na estacao remota

```


proxy https multiples apps: https://gist.github.com/msankhala/4cf4fe7fbef8c7a4b54793a6c82bd7a9

### GERAR O CERTIFICADO

```bash

rm -rf /tmp/cert
mkdir /tmp/cert
cd /tmp/cert
vim openssl.cnf

[req]
default_bits = 2048
encrypt_key  = no
default_md   = sha256
prompt       = no
utf8         = yes

distinguished_name = req_distinguished_name

req_extensions = v3_req

[req_distinguished_name]
C  = BR
ST = Parana
L  = Curitiba
O  = Renault
OU = DevNandes
CN = CertificadoAppsRenault

[v3_req]
#basicConstraints     = CA:TRUE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = renault_risk
DNS.2 = rws

openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/C=BR/ST=Parana/L=Curitiba/O=Renault/OU=DevNandes/CN=CertificadoAppsRenault" -keyout CA.key -out CA.crt
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -config openssl.cnf
openssl x509 -req -days 3650 -in server.csr -CA CA.crt -CAkey CA.key -CAcreateserial -extensions v3_req -extfile openssl.cnf -out server.crt
openssl x509 -inform PEM -outform DER -in server.crt -out server.der.crt
rm -rf /home/renault/nx/etc/certs/*
mv /tmp/cert/* /home/renault/nx/etc/certs/
cd /home/renault/nx/
docker rm nx --force
make run_dev

```


## COMO IMPORTAR O CERTIFICADO

### ANDROID

Vai depender da versão do android, no dispositivo utilizado para testes, o passo a passo foi o seguinte:
- Conectar o dispotivo no computador e copiar o arquivo "CA.crt", disponivel em /home/renault/nx2/etc/certs/
- No android, navegar até: configurações > Biometria e segurança > Outras config. de segurança > Instalar do armaz. dispositivo
- Selecione o arquivo "CA.crt" (copiado anteriormente)
- Dê o nome "Renault" ao certificado, e selecione e, "Usado para" a opção "VPN e aplicativos"

### OUTRAS VERSOES DO ANDROID

- Navegar até: Senha e segurança > Privacidade > Criptografia e credenciais > Instalar um certificado > Certificado CA > 

### LINUX & WINDOWS

#### GOOGLE CHROME

- Navegue até: Settings > Privacy and security > Security > Manage certificates > Authorities
- Clique em "Import" e importe o certificado "CA.crt", assinale todas as caixas

#### MOZILA FIREFOX

- Navegue até: Settings > Privacy & Security > View certificates > Authorities
- Clique em "Import" e importe o certificado "CA.crt", assinale todas as caixas


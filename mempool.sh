#!/bin/bash

# Definir variáveis
MEMPOOL_DIR="/opt/mempool"
NODE_VERSION="14.x"
MEMPOOL_GIT_URL="https://github.com/mempool/mempool.git"

# Instalar dependências
echo "Instalando dependências..."
sudo apt update
sudo apt install -y git curl build-essential

# Instalar Node.js
echo "Instalando Node.js..."
curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | sudo -E bash -
sudo apt install -y nodejs

# Clonar o repositório Mempool
echo "Clonando o repositório Mempool..."
git clone $MEMPOOL_GIT_URL $MEMPOOL_DIR

# Instalar dependências do backend
echo "Instalando dependências do backend..."
cd $MEMPOOL_DIR/backend
npm install

# Instalar dependências do frontend
echo "Instalando dependências do frontend..."
cd $MEMPOOL_DIR/frontend
npm install

# Construir o frontend
echo "Construindo o frontend..."
npm run build

# Copiar o arquivo de configuração de exemplo
echo "Configurando o Mempool..."
cp $MEMPOOL_DIR/backend/mempool-config.json.example $MEMPOOL_DIR/backend/mempool-config.json

# Criar arquivos de serviço do systemd para o Mempool

# Backend
echo "Criando arquivo de serviço do systemd para o backend do Mempool..."
cat <<EOF | sudo tee /etc/systemd/system/mempool-backend.service
[Unit]
Description=Mempool Backend
After=network.target bitcoind.service
Requires=bitcoind.service

[Service]
WorkingDirectory=$MEMPOOL_DIR/backend
ExecStart=/usr/bin/npm start
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Frontend
echo "Criando arquivo de serviço do systemd para o frontend do Mempool..."
cat <<EOF | sudo tee /etc/systemd/system/mempool-frontend.service
[Unit]
Description=Mempool Frontend
After=network.target mempool-backend.service
Requires=mempool-backend.service

[Service]
WorkingDirectory=$MEMPOOL_DIR/frontend
ExecStart=/usr/bin/npm start
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Recarregar os serviços do systemd
sudo systemctl daemon-reload

# Ativar e iniciar os serviços do Mempool
sudo systemctl enable mempool-backend
sudo systemctl start mempool-backend
sudo systemctl enable mempool-frontend
sudo systemctl start mempool-frontend

echo "Mempool instalado e configurado para iniciar automaticamente após o Bitcoin Core!"

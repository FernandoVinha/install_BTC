#!/bin/bash
# Script para configurar o Lightning Network Daemon (LND)

# Pedir ao usuário o nome do alias para o LND
read -p "Digite o nome do alias para o Lightning Network Daemon (LND): " alias_name

# Diretórios para os arquivos de configuração
LND_DIR="/root/.lnd"
LND_CONF="$LND_DIR/lnd.conf"
BITCOIN_CONF="/root/.bitcoin/bitcoin.conf"

# Criar o diretório .lnd, se não existir
if [ ! -d "$LND_DIR" ]; then
    echo "Criando o diretório $LND_DIR..."
    mkdir -p "$LND_DIR"
fi

# Criar o arquivo lnd.conf, se não existir
if [ ! -f "$LND_CONF" ]; then
    echo "Criando o arquivo lnd.conf em $LND_CONF..."
    touch "$LND_CONF"
fi

# Ler as configurações de rpcuser e rpcpassword de bitcoin.conf
RPC_USER=$(grep '^rpcuser=' "$BITCOIN_CONF" | cut -d'=' -f2)
RPC_PASSWORD=$(grep '^rpcpassword=' "$BITCOIN_CONF" | cut -d'=' -f2)

# Adicionar configurações ao lnd.conf
echo "alias=$alias_name" > "$LND_CONF"
echo "color=#FF5733" >> "$LND_CONF"
echo "[Bitcoin]" >> "$LND_CONF"
echo "bitcoin.active=1" >> "$LND_CONF"
echo "bitcoin.node=bitcoind" >> "$LND_CONF"
echo "bitcoin.mainnet=1" >> "$LND_CONF"
echo "[bitcoind]" >> "$LND_CONF"
echo "bitcoind.rpcuser=$RPC_USER" >> "$LND_CONF"
echo "bitcoind.rpcpass=$RPC_PASSWORD" >> "$LND_CONF"
echo "bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332" >> "$LND_CONF"
echo "bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333" >> "$LND_CONF"

# Criar um arquivo de serviço systemd para o LND
LND_SERVICE_FILE="/etc/systemd/system/lnd.service"
echo "Criando o serviço systemd para o LND em $LND_SERVICE_FILE..."
sudo bash -c "cat > $LND_SERVICE_FILE" << EOF
[Unit]
Description=LND Lightning Network Daemon
Wants=bitcoind.service
After=bitcoind.service

[Service]
ExecStart=/usr/local/bin/lnd
User=root
Restart=on-failure
TimeoutSec=60
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar o serviço LND
echo "Habilitando e iniciando o serviço LND..."
sudo systemctl enable lnd.service
sudo systemctl start lnd.service

# As próximas linhas para criar e desbloquear carteiras são indicativas
# e precisariam de uma implementação específica para automatizar a interação com lncli.

echo "LND configurado e serviço systemd criado."


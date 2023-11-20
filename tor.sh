#!/bin/bash

# Instala o curl e o Tor
sudo apt update
sudo apt install -y curl tor

# Inicia o serviço Tor
sudo service tor start

# Caminho para o arquivo bitcoin.conf
BITCOIN_CONF="/root/.bitcoin/bitcoin.conf"

# Configurar o Bitcoin Core para Usar o Tor
echo -e "\n# Configurações para o Bitcoin Core com Tor" | sudo tee -a $BITCOIN_CONF
echo "proxy=127.0.0.1:9050" | sudo tee -a $BITCOIN_CONF
echo "listen=1" | sudo tee -a $BITCOIN_CONF
echo "bind=127.0.0.1" | sudo tee -a $BITCOIN_CONF
echo "onlynet=onion" | sudo tee -a $BITCOIN_CONF

echo "Configuração do Tor para o Bitcoin Core concluída com sucesso!"

# Caminho para o arquivo lnd.conf
LND_CONF="/root/.lnd/lnd.conf"

# Verificar se o arquivo lnd.conf existe
if [ ! -f "$LND_CONF" ]; then
    echo "Erro: O arquivo lnd.conf não encontrado em $LND_CONF."
    exit 1
fi

# Verificar se as linhas já existem no lnd.conf
if grep -Fxq "tor.active=true" "$LND_CONF"; then
    echo "As linhas já existem no lnd.conf. Pulando a adição."
else
    # Adicionar as linhas ao lnd.conf
    echo "Adicionando linhas ao lnd.conf..."
    echo "tor.active=true" | sudo tee -a "$LND_CONF"
fi

echo "Configuração do Tor para o Lightning Network Daemon (LND) concluída com sucesso!"


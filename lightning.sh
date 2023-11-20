#!/bin/bash
# Esta linha indica que o script será executado usando o interpretador bash.

# Pedir ao usuário o nome do alias
read -p "Digite o nome do alias para o Lightning Network Daemon (LND): " alias_name

# Verificar se o arquivo lnd.conf existe
LND_CONF="/root/.lnd/lnd.conf"
if [ ! -f "$LND_CONF" ]; then
    echo "Erro: O arquivo lnd.conf não encontrado em $LND_CONF."
    exit 1
fi

# Verificar se as linhas já existem no lnd.conf
if grep -Fxq "alias=$alias_name" "$LND_CONF" && grep -Fxq "color=#FF5733" "$LND_CONF"; then
    echo "As linhas já existem no lnd.conf. Pulando a adição."
else
    # Adicionar as linhas ao lnd.conf
    echo "Adicionando linhas ao lnd.conf..."
    echo "alias=$alias_name" | sudo tee -a "$LND_CONF"
    echo "color=#FF5733" | sudo tee -a "$LND_CONF"
fi

# Atualiza os pacotes e instala o Go (Golang)
echo "Atualizando pacotes e instalando Go..."
sudo apt update
sudo apt install -y golang-go

# Diretório temporário para baixar e extrair o LND (Lightning Network Daemon)
TEMP_DIR="/tmp/lnd-install"
LND_VERSION="v0.17.1-beta" # Substitua pela versão mais recente se necessário
LND_TAR="lnd-linux-amd64-${LND_VERSION}.tar.gz"
LND_URL="https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}/${LND_TAR}"

# Criar diretório temporário
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Baixar o LND
echo "Baixando LND ${LND_VERSION}..."
curl -L -O $LND_URL

# Extrair o arquivo baixado
echo "Extraindo..."
tar -xvzf $LND_TAR

# Instalar o LND
echo "Instalando..."
sudo install -m 0755 -o root -g root -t /usr/local/bin "lnd-linux-amd64-${LND_VERSION}/lncli"
sudo install -m 0755 -o root -g root -t /usr/local/bin "lnd-linux-amd64-${LND_VERSION}/lnd"

# Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf $TEMP_DIR

echo "LND ${LND_VERSION} instalado com sucesso!"

# Crie um arquivo de serviço do systemd para o LND
echo "Criando arquivo de serviço do systemd para o LND..."
cat <<EOF | sudo tee /etc/systemd/system/lnd.service
[Unit]
Description=LND Lightning Network Daemon
Wants=bitcoind.service
After=bitcoind.service

[Service]
ExecStart=/usr/local/bin/lnd
User=root
LimitNOFILE=128000
Restart=on-failure
TimeoutSec=60
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

# Recarregue os serviços do systemd
sudo systemctl daemon-reload

# Ative o serviço do LND para iniciar na inicialização
sudo systemctl enable lnd

# Inicie o serviço do LND
sudo systemctl start lnd

echo "Serviço do LND configurado e iniciado com sucesso!"


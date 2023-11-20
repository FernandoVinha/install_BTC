#!/bin/bash

# Diretório temporário para baixar e extrair o Electrs
TEMP_DIR="/tmp/electrs-install"
ELECTRS_VERSION="4.0.0"  # Substitua pela versão desejada
ELECTRS_TAR="electrs-v${ELECTRS_VERSION}-x86_64-linux-gnu.tar.gz"
ELECTRS_URL="https://github.com/romanz/electrs/releases/download/v${ELECTRS_VERSION}/${ELECTRS_TAR}"

# Criar diretório temporário
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Baixar o Electrs
echo "Baixando Electrs v${ELECTRS_VERSION}..."
curl -L -O $ELECTRS_URL

# Extrair o arquivo baixado
echo "Extraindo..."
tar -xvzf $ELECTRS_TAR

# Instalar o Electrs
echo "Instalando..."
sudo install -m 0755 -o root -g root -t /usr/local/bin electrs

# Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf $TEMP_DIR

echo "Electrs v${ELECTRS_VERSION} instalado com sucesso!"

# Crie um arquivo de serviço do systemd para o Electrs
echo "Criando arquivo de serviço do systemd para o Electrs..."
cat <<EOF | sudo tee /etc/systemd/system/electrs.service
[Unit]
Description=Electrs - Electrum Rust Server
After=network.target

[Service]
ExecStart=/usr/local/bin/electrs --daemon
User=root
Restart=always
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF

# Recarregue os serviços do systemd
sudo systemctl daemon-reload

# Ative o serviço do Electrs para iniciar na inicialização
sudo systemctl enable electrs

# Inicie o serviço do Electrs
sudo systemctl start electrs

echo "Serviço do Electrs configurado e iniciado com sucesso!"

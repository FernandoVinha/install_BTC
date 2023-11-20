# Instala o curl
apt install curl
# Este comando instala o utilitário curl, que é utilizado posteriormente no script para baixar arquivos da web.

# Diretório temporário para baixar e extrair o Bitcoin Core
TEMP_DIR="/tmp/bitcoin-core-install"
BITCOIN_VERSION="0.21.1"
BITCOIN_TAR="bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz"
BITCOIN_URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_TAR}"

# Criar diretório temporário
mkdir -p $TEMP_DIR
cd $TEMP_DIR
# Estas linhas definem variáveis relacionadas ao diretório temporário e à versão do Bitcoin Core.
# Em seguida, o script cria e entra no diretório temporário.

# Baixar o Bitcoin Core
echo "Baixando Bitcoin Core v${BITCOIN_VERSION}..."
curl -L -O $BITCOIN_URL
# Esta linha utiliza o curl para baixar o arquivo do Bitcoin Core da URL especificada.

# Extrair o arquivo baixado
echo "Extraindo..."
tar -xvzf $BITCOIN_TAR
# Esta linha extrai o conteúdo do arquivo tar.gz baixado.

# Instalar o Bitcoin Core
echo "Instalando..."
sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-${BITCOIN_VERSION}/bin/*
# Aqui, o script instala o Bitcoin Core no diretório '/usr/local/bin'.

# Criar arquivo de configuração bitcoin.conf
echo "Criando arquivo de configuração bitcoin.conf..."
cat <<EOF | sudo tee /root/.bitcoin/bitcoin.conf
# Configurações para o Bitcoin Core

# Você pode adicionar suas configurações específicas aqui
# rpcuser=seu_usuario
# rpcpassword=sua_senha
# server=1
# listen=1
# ...
EOF
# Esta parte cria um arquivo de configuração 'bitcoin.conf' no diretório '/root/.bitcoin/'.

# Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf $TEMP_DIR
# Esta linha remove o diretório temporário e seus conteúdos após a instalação.

echo "Bitcoin Core v${BITCOIN_VERSION} instalado com sucesso!"

# Crie um arquivo de serviço do systemd para o Bitcoin
echo "Criando arquivo de serviço do systemd para o Bitcoin..."
cat <<EOF | sudo tee /etc/systemd/system/bitcoind.service
[Unit]
Description=Bitcoin daemon
After=network.target

[Service]
ExecStart=/usr/local/bin/bitcoind -daemon -conf=/root/.bitcoin/bitcoin.conf -pid=/root/.bitcoin/bitcoind.pid
User=root
Type=forking
PIDFile=/root/.bitcoin/bitcoind.pid
Restart=always
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF
# Aqui, o script cria um arquivo de serviço do systemd para o Bitcoin.

# Recarregue os serviços do systemd
sudo systemctl daemon-reload
# Esta linha recarrega os serviços do systemd para reconhecer o novo arquivo de serviço.

# Ative o serviço do Bitcoin para iniciar na inicialização
sudo systemctl enable bitcoind

# Inicie o serviço do Bitcoin
sudo systemctl start bitcoind
# Estas linhas ativam e iniciam o serviço do Bitcoin usando o systemd.

echo "Serviço do Bitcoin configurado e iniciado com sucesso!"
# Esta linha exibe uma mensagem indicando que o serviço do Bitcoin foi configurado e iniciado com sucesso.


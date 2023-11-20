# Atualiza os pacotes e instala o Go (Golang)
echo "Atualizando pacotes e instalando Go..."
sudo apt update
sudo apt install -y golang-go
# Estas linhas atualizam os pacotes do sistema e instalam o Go (Golang) usando o gerenciador de pacotes apt.

# Diretório temporário para baixar e extrair o LND (Lightning Network Daemon)
TEMP_DIR="/tmp/lnd-install"
LND_VERSION="v0.17.1-beta" # Substitua pela versão mais recente se necessário
LND_TAR="lnd-linux-amd64-${LND_VERSION}.tar.gz"
LND_URL="https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}/${LND_TAR}"
# Estas linhas definem variáveis relacionadas ao diretório temporário e à versão do LND.

# Criar diretório temporário
mkdir -p $TEMP_DIR
cd $TEMP_DIR
# Este script cria e entra no diretório temporário.

# Baixar o LND
echo "Baixando LND ${LND_VERSION}..."
curl -L -O $LND_URL
# Esta linha utiliza o curl para baixar o arquivo do LND da URL especificada.

# Extrair o arquivo baixado
echo "Extraindo..."
tar -xvzf $LND_TAR
# Esta linha extrai o conteúdo do arquivo tar.gz baixado.

# Instalar o LND
echo "Instalando..."
sudo install -m 0755 -o root -g root -t /usr/local/bin "lnd-linux-amd64-${LND_VERSION}/lncli"
sudo install -m 0755 -o root -g root -t /usr/local/bin "lnd-linux-amd64-${LND_VERSION}/lnd"
# Estas linhas instalam o LND no diretório '/usr/local/bin'.

# Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf $TEMP_DIR
# Esta linha remove o diretório temporário e seus conteúdos após a instalação.

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
# Esta parte do script cria um arquivo de serviço do systemd para o LND.

# Recarregue os serviços do systemd
sudo systemctl daemon-reload
# Esta linha recarrega os serviços do systemd para reconhecer o novo arquivo de serviço.

# Ative o serviço do LND para iniciar na inicialização
sudo systemctl enable lnd

# Inicie o serviço do LND
sudo systemctl start lnd
# Estas linhas ativam e iniciam o serviço do LND usando o systemd.

echo "Serviço do LND configurado e iniciado com sucesso!"
# Esta linha exibe uma mensagem indicando que o serviço do LND foi configurado e iniciado com sucesso.


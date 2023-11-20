#!/bin/bash

# Instala o curl
sudo apt install curl

# Lista de versões disponíveis do Bitcoin Core
VERSIONS=("26.0" "0.21.2" "0.21.1" "0.20.0" "0.19.1" "0.18.0" "0.17.2" "0.16.3" "0.15.2" "0.14.3")

# Solicitar ao usuário que escolha uma versão
echo "Escolha uma versão do Bitcoin Core:"
select BITCOIN_VERSION in "${VERSIONS[@]}"; do
    if [[ " ${VERSIONS[@]} " =~ " ${BITCOIN_VERSION} " ]]; then
        break
    else
        echo "Opção inválida. Tente novamente."
    fi
done

# Diretório temporário para baixar e extrair o Bitcoin Core
TEMP_DIR="/tmp/bitcoin-core-install"
BITCOIN_TAR="bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz"
BITCOIN_URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_TAR}"

# Criar diretório temporário
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Baixar o Bitcoin Core
echo "Baixando Bitcoin Core v${BITCOIN_VERSION}..."
curl -L -O $BITCOIN_URL

# Extrair o arquivo baixado
echo "Extraindo..."
tar -xvzf $BITCOIN_TAR

# Instalar o Bitcoin Core
echo "Instalando..."
sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-${BITCOIN_VERSION}/bin/*

# Criar arquivo de configuração bitcoin.conf
echo "Criando arquivo de configuração bitcoin.conf..."

# Perguntar ao usuário se deseja habilitar o RPC
read -p "Deseja habilitar o RPC? (s/n) " enable_rpc
if [[ $enable_rpc =~ ^[Ss]$ ]]; then
    read -p "Digite o nome de usuário RPC: " rpc_user
    read -s -p "Digite a senha RPC: " rpc_password
    echo -e "\nrpcuser=${rpc_user}" | sudo tee -a /root/.bitcoin/bitcoin.conf
    echo -e "rpcpassword=${rpc_password}" | sudo tee -a /root/.bitcoin/bitcoin.conf
fi

# Perguntar ao usuário se deseja adicionar mais memória RAM
read -p "Deseja adicionar mais memória RAM para a sincronização? (s/n) " enable_ram
if [[ $enable_ram =~ ^[Ss]$ ]]; then
    options=("1g" "2g" "4g")
    PS3="Escolha a quantidade de memória RAM adicional: "
    select ram_option in "${options[@]}"; do
        case $ram_option in
            "1g")
                echo "dbcache=1024" | sudo tee -a /root/.bitcoin/bitcoin.conf
                break
                ;;
            "2g")
                echo "dbcache=2048" | sudo tee -a /root/.bitcoin/bitcoin.conf
                break
                ;;
            "4g")
                echo "dbcache=4096" | sudo tee -a /root/.bitcoin/bitcoin.conf
                break
                ;;
            *)
                echo "Opção inválida. Tente novamente."
                ;;
        esac
    done
fi

# Perguntar ao usuário se deseja limitar o uso de HD
read -p "Deseja limitar o uso de HD para o Bitcoin Core? (s/n) " enable_hd_limit
if [[ $enable_hd_limit =~ ^[Ss]$ ]]; then
    read -p "Digite a porcentagem de HD a ser utilizada pelo Bitcoin Core (0-100%): " hd_percentage
    if [[ $hd_percentage =~ ^[0-9]+$ ]] && ((hd_percentage >= 0 && hd_percentage <= 100)); then
        echo "dbcache=${hd_percentage}" | sudo tee -a /root/.bitcoin/bitcoin.conf
    else
        echo "Porcentagem inválida. Utilizando o valor padrão."
    fi
fi

# Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf $TEMP_DIR

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
RestartSec


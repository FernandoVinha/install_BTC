#!/bin/bash
# Esta linha indica que o script será executado usando o interpretador bash.

# Adiciona a chave de assinatura do pacote Tailscale e o repositório
echo "Adicionando a chave de assinatura do pacote Tailscale e o repositório..."
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
# Essas linhas utilizam o comando 'curl' para baixar a chave de assinatura do pacote Tailscale e o repositório.
# As chaves e o repositório são adicionados ao sistema usando 'tee' e 'sudo'. 
# "/dev/null" é utilizado para descartar a saída do comando 'tee'.

# Atualiza a lista de pacotes e instala o Tailscale
echo "Atualizando a lista de pacotes..."
sudo apt-get update
echo "Instalando o Tailscale..."
sudo apt-get install tailscale
# Estas linhas atualizam a lista de pacotes usando 'apt-get update' e instalam o pacote Tailscale usando 'apt-get install'.

# Criar arquivo de serviço do systemd para o Tailscale
echo "Criando arquivo de serviço do systemd para o Tailscale..."
cat <<EOF | sudo tee /etc/systemd/system/tailscale.service
[Unit]
Description=Tailscale Node
After=network.target

[Service]
ExecStart=/usr/bin/tailscale up
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
# Essas linhas utilizam 'cat' para criar um arquivo de serviço do systemd para o Tailscale.
# O conteúdo do arquivo é fornecido usando a sintaxe 'EOF' e é direcionado para o arquivo '/etc/systemd/system/tailscale.service' usando 'tee' e 'sudo'.

# Recarregar os serviços do systemd
sudo systemctl daemon-reload
# Esta linha recarrega os serviços do systemd para que o novo arquivo de serviço do Tailscale seja reconhecido.

# Ativar e iniciar o serviço do Tailscale
sudo systemctl enable tailscale
sudo systemctl start tailscale
# Estas linhas ativam e iniciam o serviço do Tailscale usando 'systemctl'.

echo "Tailscale instalado e configurado para iniciar automaticamente!"
# Esta linha exibe uma mensagem indicando que o Tailscale foi instalado e configurado com sucesso.


#!/bin/bash
# Esta linha indica que o script será executado usando o interpretador bash.

echo "Bem-vindo ao instalador. Vamos configurar o seu sistema."
# Esta linha exibe uma mensagem de boas-vindas no console.

# Função para perguntar ao usuário se quer instalar um componente
ask_to_install() {
    while true; do
        read -p "Deseja instalar $1? (s/n) " yn
        case $yn in
            [Ss]* ) ./$2; break;;
            [Nn]* ) echo "Pulando a instalação de $1."; return;;
            * ) echo "Por favor, responda com 's' (sim) ou 'n' (não).";;
        esac
    done
}
# Esta parte define uma função chamada ask_to_install que solicitará ao usuário a instalação de um componente.
# Ela usa um loop while para garantir que o usuário forneça uma resposta válida.
# A função aceita dois parâmetros: $1 é o nome do componente, $2 é o script a ser executado para instalação.

# Pergunte ao usuário se deseja instalar cada componente
ask_to_install "Tailscale" "tailscale.sh"
ask_to_install "Tor" "tor.sh"
ask_to_install "Bitcoin" "bitcoin.sh"
ask_to_install "Lightning Network" "lightning.sh"
ask_to_install "Electrs" "electrs.sh"
ask_to_install "Mempool" "mempool.sh"
# Aqui, o script pergunta ao usuário se deseja instalar cada um dos componentes listados,
# chamando a função ask_to_install com os nomes e scripts correspondentes.

echo "Configuração concluída."
# Esta linha exibe uma mensagem indicando que a configuração foi concluída.


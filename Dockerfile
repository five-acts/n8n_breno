# Começa da imagem base do n8n que você já usa
FROM n8nio/n8n:1.101.3

# Muda para o usuário root para ter permissão de instalar pacotes
USER root

# Instala o seu pacote de nó customizado globalmente
RUN npm install -g n8n-nodes-databricksgenienode

# --- INÍCIO DA CORREÇÃO ---
# Adiciona as variáveis de ambiente para que o n8n encontre e confie no nó

# 1. Lista os pacotes externos que o n8n tem permissão para carregar.
#    Se tiver mais de um, separe por vírgula.
ENV NODE_FUNCTION_ALLOW_EXTERNAL=n8n-nodes-databricksgenienode

# 2. Informa ao Node.js para procurar pacotes no diretório de instalação global.
#    Este é o caminho padrão onde o `npm install -g` coloca os pacotes.
ENV NODE_PATH=/usr/local/lib/node_modules
# --- FIM DA CORREÇÃO ---

# Retorna para o usuário 'node' por segurança, para rodar a aplicação sem privilégios de root
USER node
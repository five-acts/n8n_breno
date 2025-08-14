# Etapa 1: Construir o n8n a partir do código-fonte com o seu nó incluído
FROM node:18-alpine AS builder

# Instalar dependências de sistema necessárias para a compilação
RUN apk add --no-cache git python3 make g++

WORKDIR /usr/src/app

# Clonar a versão exata do n8n que você quer usar
ARG N8N_VERSION=1.101.3
RUN git clone --depth 1 --branch n8n@${N8N_VERSION} https://github.com/n8n-io/n8n.git .

# Copia o seu código-fonte local para dentro da pasta de pacotes do n8n.
COPY .n8n/custom ./packages/nodes-community/

# --- INÍCIO DA CORREÇÃO ---
# Atualiza o NPM e executa o install na mesma camada para garantir que a versão correta seja usada
RUN npm install -g npm@10 && npm install
# --- FIM DA CORREÇÃO ---

# Fazer o bootstrap dos pacotes internos do n8n
RUN npm run bootstrap

# Compilar o n8n junto com o seu nó
RUN npm run build


# Etapa 2: Criar a imagem final de execução, que é menor e mais segura
FROM node:18-alpine

# Instalar dependências de produção que o n8n precisa
RUN apk add --no-cache graphicsmagick

WORKDIR /data

# Copiar apenas os pacotes compilados da etapa de build
COPY --from=builder /usr/src/app/packages ./packages

# --- Variáveis de Ambiente ---
# A única variável que precisamos para rodar no Coolify
ENV N8N_TRUST_PROXY=true

# Expor a porta padrão do n8n
EXPOSE 5678

# Definir o comando para iniciar o n8n
ENTRYPOINT ["./packages/cli/bin/n8n"]

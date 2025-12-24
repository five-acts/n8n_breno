# Etapa 1: Construir o n8n a partir do código-fonte com o seu nó incluído
# Usando a imagem base Node.js 20, conforme exigido pelo seu package.json
FROM node:20 AS builder

# Instalar dependências de sistema necessárias para a compilação
RUN apt-get update && apt-get install -y --no-install-recommends git python3 make g++

WORKDIR /usr/src/app

# Clonar a versão exata do n8n que você quer usar
ARG N8N_VERSION=2.1.1
RUN git clone --depth 1 --branch n8n@${N8N_VERSION} https://github.com/n8n-io/n8n.git .

# Copia o seu código-fonte local para dentro da pasta de pacotes do n8n.
COPY .n8n/custom ./packages/nodes-community/

# Habilita o corepack e instala as dependências usando pnpm, a ferramenta correta para o n8n
RUN corepack enable
RUN pnpm install

# Compilar o n8n junto com o seu nó
RUN pnpm run build


# Etapa 2: Criar a imagem final de execução
# Usando a imagem 'slim' do Node 20
FROM node:20-slim

# Instalar dependências de produção que o n8n precisa
RUN apt-get update && apt-get install -y --no-install-recommends graphicsmagick && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# Copia os arquivos necessários da etapa de build
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/packages ./packages

# Adiciona a variável que diz ao n8n para carregar os nós da pasta community
ENV N8N_CUSTOM_EXTENSIONS='/data/packages/nodes-community/'

# --- Variáveis de Ambiente ---
ENV N8N_TRUST_PROXY=true

# Expor a porta padrão do n8n
EXPOSE 5678

# Definir o comando para iniciar o n8n
ENTRYPOINT ["./packages/cli/bin/n8n"]

# Etapa 1: Construir o n8n a partir do código-fonte com o seu nó incluído
# Usando a imagem base padrão do Node.js 18 para maior compatibilidade
FROM node:18 AS builder

# Instalar dependências de sistema necessárias para a compilação
# A imagem base Debian usa 'apt-get' em vez de 'apk'
RUN apt-get update && apt-get install -y --no-install-recommends git python3 make g++

WORKDIR /usr/src/app

# Clonar a versão exata do n8n que você quer usar
ARG N8N_VERSION=1.101.3
RUN git clone --depth 1 --branch n8n@${N8N_VERSION} https://github.com/n8n-io/n8n.git .

# Copia o seu código-fonte local para dentro da pasta de pacotes do n8n.
COPY .n8n/custom ./packages/nodes-community/

# Instalar todas as dependências do n8n
RUN npm install

# Fazer o bootstrap dos pacotes internos do n8n
RUN npm run bootstrap

# Compilar o n8n junto com o seu nó
RUN npm run build


# Etapa 2: Criar a imagem final de execução, que é menor e mais segura
# Usando a imagem 'slim' que é menor que a padrão, mas mais robusta que a 'alpine'
FROM node:18-slim

# Instalar dependências de produção que o n8n precisa
RUN apt-get update && apt-get install -y --no-install-recommends graphicsmagick && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# Copiar apenas os pacotes compilados da etapa de build
COPY --from=builder /usr/src/app/packages ./packages

# --- Variáveis de Ambiente ---
ENV N8N_TRUST_PROXY=true

# Expor a porta padrão do n8n
EXPOSE 5678

# Definir o comando para iniciar o n8n
ENTRYPOINT ["./packages/cli/bin/n8n"]

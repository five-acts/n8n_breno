# Etapa 1: ... (Toda a primeira parte está perfeita, não mude nada) ...
FROM node:20 AS builder
# ... (tudo igual até o final da primeira etapa) ...
RUN pnpm run build


# Etapa 2: Criar a imagem final de execução
FROM node:20-slim

# Instalar dependências de produção
RUN apt-get update && apt-get install -y --no-install-recommends graphicsmagick && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# Copiar os arquivos necessários da etapa de build
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/packages ./packages

# --- A CORREÇÃO FINAL ---
# Adiciona a variável que diz ao n8n para carregar os nós da pasta community
ENV N8N_CUSTOM_EXTENSIONS='/data/packages/nodes-community/'
# --- FIM DA CORREÇÃO ---

# --- Variáveis de Ambiente ---
ENV N8N_TRUST_PROXY=true

# Expor a porta padrão do n8n
EXPOSE 5678

# Definir o comando para iniciar o n8n
ENTRYPOINT ["./packages/cli/bin/n8n"]

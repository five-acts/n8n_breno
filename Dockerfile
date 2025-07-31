FROM n8nio/n8n:1.101.3

USER root

RUN npm install -g n8n-nodes-databricksgenienode

USER node

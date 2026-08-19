# Dockerfile para Produção da via-audit-api
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar definidores de pacotes
COPY package*.json ./

# Instalar dependências de produção
RUN npm ci --only=production

# Copiar código fonte
COPY . .

# Imagem final de produção
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Criar pasta de uploads para fotos e assinaturas com permissões
RUN mkdir -p /app/uploads/fotos /app/uploads/assinaturas && \
    chown -R node:node /app

# Copiar do builder
COPY --from=builder /app ./

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "src/server.js"]

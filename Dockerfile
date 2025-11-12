# ===============================
# Build: clona o site e prepara arquivos
# ===============================
FROM alpine:3.20 AS builder

# Instala git e wget
RUN apk add --no-cache git

# Define repositório e branch
ARG GIT_REPO=https://github.com/isaiasfontes/site.git
ARG GIT_BRANCH=main

# Cria diretório de trabalho
WORKDIR /app

# Clona o repositório (shallow clone para mais velocidade)
RUN git clone --depth 1 --branch ${GIT_BRANCH} ${GIT_REPO} .

# ===============================
# Final: servidor Nginx estático
# ===============================
FROM nginx:stable-alpine

# Remove página padrão
RUN rm -rf /usr/share/nginx/html/*

# Copia os arquivos do site
COPY --from=builder /app /usr/share/nginx/html

# Copia configuração customizada do Nginx (opcional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Define permissões
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expõe porta padrão (apenas interna — o EasyPanel faz o proxy)
EXPOSE 80

# Comando final
CMD ["nginx", "-g", "daemon off;"]

# Étape de construction
FROM caddy:2.8.0-rc.1-builder-alpine AS builder

# Installer xcaddy
RUN go install --x github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# Construire Caddy avec les modules supplémentaires
RUN xcaddy build v2.8.0-rc.1 \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/WeidiDeng/caddy-cloudflare-ip \
    --with github.com/caddyserver/transform-encoder

# Étape finale
FROM caddy:2.8.0-rc.1-alpine

# Créer un utilisateur non-root et un groupe
RUN addgroup -S caddygroup && adduser -S caddyuser -G caddygroup

# Créer un répertoire pour les fichiers de Caddy et définir les permissions
RUN mkdir -p /etc/caddy /data /config && \
    chown -R caddyuser:caddygroup /etc/caddy /data /config

# Copier l'exécutable Caddy personnalisé depuis l'étape de construction
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Changer l'utilisateur pour caddyuser
USER caddyuser

# Exposer les ports non privilégiés
EXPOSE 80
EXPOSE 443

# Commande pour démarrer Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]


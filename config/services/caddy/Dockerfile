# Use the official Caddy builder image to compile the custom binary
FROM caddy:2-builder AS builder

# Build Caddy with the Cloudflare DNS plugin
RUN xcaddy build --with github.com/caddy-dns/cloudflare

# Use the standard Caddy image for the final stage
FROM caddy:2

# Replace the default binary with our custom one
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
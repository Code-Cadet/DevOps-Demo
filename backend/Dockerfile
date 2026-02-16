# Stage 1: Build
FROM node:22-slim AS builder
WORKDIR /app
COPY package*.json ./
# Install only what we need
RUN npm install --only=production && npm audit fix --force

# Stage 2: Production Hardening
FROM node:22-slim
# Patch OS-level vulnerabilities
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Copy the clean modules from the builder
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# SECURITY HARDENING: Remove npm/npx as they aren't needed at runtime
# This removes the vulnerable 'tar' and 'glob' packages found in the logs
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

EXPOSE 3000
# Run the app directly with node
CMD ["node", "index.js"]
# Stage 1: Build & Patch
FROM node:22-slim AS builder
WORKDIR /app
COPY package*.json ./
# Force update global npm and install dependencies with a fresh audit
RUN npm install -g npm@latest && \
    npm install && \
    npm audit fix --force

    # Stage 2: Production Image
FROM node:22-slim
# Apply OS patches
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Only copy the patched node_modules from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY . .

EXPOSE 3000
CMD ["node", "index.js"]
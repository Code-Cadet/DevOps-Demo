# Stage 1: Build & Patch
FROM node:18-slim AS builder
WORKDIR /app
COPY package*.json ./
# Install and fix vulnerabilities during the build
RUN npm install && npm audit fix --force

# Stage 2: Production Image
FROM node:18-slim
# Apply OS patches
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Only copy the patched node_modules from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY . .

EXPOSE 3000
CMD ["node", "index.js"]
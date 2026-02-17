# Stage 1: Build stage with security updates
FROM node:22-slim AS builder

# 1. Update OS packages
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 2. Set working directory
WORKDIR /app

# 3. Copy package files
COPY package*.json ./

# 4. Install dependencies with security fixes
RUN npm ci --only=production && \
    npm install tar@^7.5.7 glob@^11.1.0 diff@^8.0.3 --save && \
    npm audit fix --force

# 5. Copy application code
COPY . .

# Stage 2: Production stage (smaller, more secure)
FROM node:22-slim

# 1. Security updates in final image
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 2. Create app directory
WORKDIR /app

# 3. Copy only necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/*.js ./

# 4. Switch to non-root user
USER node

# 5. Expose port and run
EXPOSE 3000
CMD ["node", "index.js"]
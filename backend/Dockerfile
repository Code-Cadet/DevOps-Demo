FROM node:22-alpine

# 1. Install security updates (Alpine uses apk)
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# 2. Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# 3. Create app directory
WORKDIR /app

# 4. Copy package files
COPY package*.json ./

# 5. Install dependencies with security fixes
RUN npm ci --only=production && \
    npm install tar@^7.5.7 glob@^11.1.0 diff@^8.0.3 --save

# 6. Copy application code
COPY . .

# 7. Switch to non-root user (Alpine has 'node' user)
USER node

# 8. Use dumb-init to handle signals properly
EXPOSE 3000
CMD ["dumb-init", "node", "index.js"]
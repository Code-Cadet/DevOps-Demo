# Use Node 22 slim directly
FROM node:22-slim

# 1. Security: Patch OS vulnerabilities
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 2. Set the working directory
WORKDIR /app

# 3. Copy package files and install dependencies
# We do this before COPY . . to take advantage of Docker layer caching correctly
COPY package*.json ./
RUN npm install --only=production && npm audit fix --force

# 4. Copy the rest of the application code
COPY . .

# 5. Security: Change ownership to the 'node' user
RUN chown -R node:node /app

# 6. Switch to the non-root user
USER node

EXPOSE 3000
CMD ["node", "index.js"]
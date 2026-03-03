# Build stage
FROM node:22-alpine AS builder

WORKDIR /app
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

COPY . .

# Production stage - Google's distroless (no shell, minimal attack surface)
FROM gcr.io/distroless/nodejs22-debian12

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/*.js ./

# Set environment to production
ENV NODE_ENV=production

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["node", "-e", "require('http').get('http://localhost:3000/healthz', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"]

CMD ["index.js"]
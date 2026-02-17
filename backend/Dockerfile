# Build stage
FROM node:22-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && \
    npm install tar@^7.5.7 glob@^11.1.0 diff@^8.0.3 --save

COPY . .

# Production stage - Google's distroless (no shell, minimal attack surface)
FROM gcr.io/distroless/nodejs22-debian12

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/*.js ./

EXPOSE 3000
CMD ["index.js"]
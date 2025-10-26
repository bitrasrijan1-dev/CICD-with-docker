
FROM node:18-alpine AS builder


WORKDIR /app


COPY package*.json ./


RUN npm ci

COPY . .


RUN npm test


FROM node:18-alpine AS production


RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app


COPY package*.json ./


RUN npm ci --only=production


COPY --from=builder /app/app.js ./


RUN chown -R nodejs:nodejs /app


USER nodejs


EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "app.js"]


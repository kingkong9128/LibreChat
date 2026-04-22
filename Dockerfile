# Stage 1: Build the frontend
FROM node:20-alpine AS builder

WORKDIR /app
USER node

COPY package*.json ./
COPY api/package*.json ./api/
COPY client/package*.json ./client/
COPY packages/*/package*.json ./packages/
RUN npm ci --no-audit

COPY . .

RUN DISABLE_PWA=1 NODE_OPTIONS="--max-old-space-size=4096" npm run frontend

# Stage 2: Create minimal runtime image
FROM node:20-alpine AS runtime

RUN apk add --no-cache jemalloc
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
WORKDIR /app
USER node

COPY --from=builder /app/client/dist ./client/dist
COPY --from=builder /app/api ./api
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/config ./config
COPY --from=builder /app/client/public ./client/public

RUN mkdir -p /app/logs /app/uploads /app/client/public/images && \
    npm prune --production

EXPOSE 3080
ENV HOST=0.0.0.0
ENV NODE_ENV=production
CMD ["npm", "run", "backend"]
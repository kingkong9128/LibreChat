# Stage 1: Build API from our source
FROM node:20-alpine AS api

WORKDIR /app
USER node

COPY package*.json ./
COPY api/package*.json ./api/
COPY packages/*/package*.json ./packages/
COPY config/ ./config/
COPY models/ ./models/
COPY strategies/ ./strategies/
COPY operations/ ./operations/
COPY stringGen.js ./
COPY librechat.yaml ./

RUN npm ci --omit=dev && mkdir -p /app/logs /app/uploads && touch .env

COPY api/ ./api/
COPY packages/ ./packages/
COPY config/ ./config/
COPY models/ ./models/
COPY strategies/ ./strategies/
COPY operations/ ./operations/
COPY stringGen.js ./

# Stage 2: Get pre-built frontend from official image
FROM ghcr.io/danny-avila/librechat:v0.8.5-rc1 AS frontend

# Stage 3: Final
FROM node:20-alpine

RUN apk add --no-cache jemalloc
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
WORKDIR /app
USER node

COPY --from=api /app/node_modules ./node_modules
COPY --from=api /app/api ./api
COPY --from=api /app/packages ./packages
COPY --from=api /app/config ./config
COPY --from=api /app/models ./models
COPY --from=api /app/strategies ./strategies
COPY --from=api /app/operations ./operations
COPY --from=api /app/stringGen.js .
COPY --from=api /app/libllechat.yaml .
COPY --from=frontend /app/client/dist ./client/dist
COPY --from=frontend /app/client/public ./client/public

EXPOSE 3080
ENV HOST=0.0.0.0
ENV NODE_ENV=production
CMD ["npm", "run", "backend"]
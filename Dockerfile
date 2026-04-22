# Build from node:20-alpine
FROM node:20-alpine

RUN apk add --no-cache jemalloc python3 py3-pip

ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
ARG NODE_MAX_OLD_SPACE_SIZE=6144

WORKDIR /app
USER node

COPY package*.json ./
COPY api/package*.json ./api/
COPY client/package*.json ./client/
COPY packages/*/package*.json ./packages/

RUN npm ci --no-audit && mkdir -p /app/client/public/images /app/logs /app/uploads && touch .env

COPY . .

RUN npm prune --production

EXPOSE 3080
ENV HOST=0.0.0.0
ENV NODE_ENV=production
CMD ["npm", "run", "backend"]
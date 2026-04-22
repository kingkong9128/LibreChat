# v0.8.5-rc1

FROM node:20-alpine AS node

RUN apk upgrade --no-cache
RUN apk add --no-cache jemalloc
RUN apk add --no-cache python3 py3-pip

COPY --from=ghcr.io/astral-sh/uv:0.9.5-python3.12-alpine /usr/local/bin/uv /usr/local/bin/uvx /bin/
RUN uv --version

ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
ARG NODE_MAX_OLD_SPACE_SIZE=6144

WORKDIR /app
USER node

COPY --chown=node:node package.json package-lock.json ./
COPY --chown=node:node api/package.json ./api/package.json
COPY --chown=node:node client/package.json ./client/package.json
COPY --chown=node:node packages/data-provider/package.json ./packages/data-provider/package.json
COPY --chown=node:node packages/data-schemas/package.json ./packages/data-schemas/package.json
COPY --chown=node:node packages/api/package.json ./packages/api/package.json

RUN \
    touch .env ; \
    mkdir -p /app/client/public/images /app/logs /app/uploads ; \
    npm config set fetch-retry-maxtimeout 600000 ; \
    npm config set fetch-retries 5 ; \
    npm config set fetch-retry-mintimeout 15000 ; \
    npm ci --no-audit

COPY --chown=node:node . .

RUN DISABLE_PWA=1 NODE_OPTIONS="--max-old-space-size=${NODE_MAX_OLD_SPACE_SIZE}" npm run frontend

RUN rm -f /app/client/dist/sw.js /app/client/dist/workbox-*.js /app/client/dist/precache.*.json && \
    echo "PWA files removed" && \
    (test -f /app/client/dist/index.html && echo "Frontend dist verified: OK" || (echo "ERROR: index.html not found!"; exit 1)) && \
    npm prune --production && \
    npm cache clean --force

EXPOSE 3080
ENV HOST=0.0.0.0
ENV NODE_ENV=production
CMD ["npm", "run", "backend"]

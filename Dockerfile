# v0.8.5-rc1 - Fixed frontend build
FROM node:20-alpine
RUN apk add --no-cache jemalloc
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
ARG NODE_MAX_OLD_SPACE_SIZE=6144
WORKDIR /app
USER node
COPY --chown=node:node package.json package-lock.json ./
COPY --chown=node:node api/package.json ./api/
COPY --chown=node:node client/package.json ./client/
COPY --chown=node:node packages/data-provider/package.json ./packages/data-provider/
COPY --chown=node:node packages/data-schemas/package.json ./packages/data-schemas/
COPY --chown=node:node packages/api/package.json ./packages/api/
COPY --chown=node:node packages/client/package.json ./packages/client/
RUN npm ci --no-audit && mkdir -p /app/client/public/images /app/logs /app/uploads && touch .env
COPY --chown=node:node . .
RUN DISABLE_PWA=1 NODE_OPTIONS="--max-old-space-size=${NODE_MAX_OLD_SPACE_SIZE}" npm run frontend && rm -f /app/client/dist/sw.js /app/client/dist/workbox-*.js /app/client/dist/precache.*.json && test -f /app/client/dist/index.html && npm prune --production
EXPOSE 3080
ENV HOST=0.0.0.0 NODE_ENV=production
CMD ["npm", "run", "backend"]
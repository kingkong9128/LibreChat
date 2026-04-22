# AccountexAI LibreChat - Minimal Docker build
FROM node:20-alpine AS base

WORKDIR /app

FROM base AS deps
COPY package*.json ./
COPY api/package*.json ./api/
COPY client/package*.json ./client/
COPY packages/*/package*.json ./packages/
RUN npm ci --omit=dev

FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN DISABLE_PWA=1 npm run frontend

FROM base AS runner
ENV NODE_ENV=production HOST=0.0.0.0
WORKDIR /app
COPY --from=builder /app/client/dist ./client/dist
COPY --from=builder /app/api ./api
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/packages ./packages
RUN npm prune --production
EXPOSE 3080
CMD ["npm", "run", "backend"]
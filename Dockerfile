FROM ghcr.io/danny-avila/librechat:v0.8.5-rc1

ENV HOST=0.0.0.0
ENV NODE_ENV=production

EXPOSE 3080
CMD ["npm", "run", "backend"]
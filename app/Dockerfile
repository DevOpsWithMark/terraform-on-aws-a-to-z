# app/Dockerfile
# Book 1 readers do not need to build this image:
# a pre-built copy is published at
# ghcr.io/devopswithmark/shortener:1.0.0 and copied to ECR
# by scripts/push-image.sh (Chapter 15).
FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm install --omit=dev
COPY server.js ./
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
USER node
CMD ["node", "server.js"]

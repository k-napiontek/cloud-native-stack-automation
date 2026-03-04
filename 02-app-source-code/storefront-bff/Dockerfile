FROM node:24-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build


FROM node:24-alpine AS runner

ENV NODE_ENV=production

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

COPY --from=builder --chown=node:node /app/dist ./dist

USER node

EXPOSE 8080

CMD ["node", "dist/index.js"]
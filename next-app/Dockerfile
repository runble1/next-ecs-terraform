FROM node:16 AS builder

WORKDIR /app
COPY package.json ./
COPY yarn.lock ./
RUN yarn install --frozen-lockfile --production=false
COPY . .
RUN yarn build

FROM node:16-stretch-slim AS runner
ENV NODE_ENV=production

WORKDIR /app

# standalone モードを利用すると、publicと.next/staticはデフォルトでは含まれないので明示的にコピーする必要があります
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static

COPY --from=builder /app/.next/standalone ./
CMD ["node", "server.js"]
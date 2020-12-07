FROM node:erbium-alpine as base

WORKDIR /home/node/app/
COPY package.json package-lock.json ./
RUN npm ci

# ==========================================
FROM base as build

COPY . ./
RUN npm run build && rm ./dist/*.tsbuildinfo

# ==========================================
FROM base as deps

RUN rm -rf node_modules && npm install --production

# ==========================================
FROM alpine:3.12.1 as alpine-node

RUN apk add --no-cache nodejs=12.18.4-r0 \
  && apk del apk-tools \
  && rm -rf /var/cache/apk/* \
  && adduser -D node

# ==========================================
FROM alpine-node
WORKDIR /home/node/app/
COPY --from=deps /home/node/app/node_modules ./node_modules
COPY --from=build /home/node/app/dist ./

EXPOSE 4000
USER node
ENTRYPOINT [ "node", "main" ]

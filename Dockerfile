# Build stage
FROM node:22.7.0-alpine3.19 AS builder
 
WORKDIR /home/node
 
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi
 
COPY . .
RUN \
  if [ -f yarn.lock ]; then npm run build; \
  elif [ -f package-lock.json ]; then npm run build && npm prune --omit=dev; \
  elif [ -f pnpm-lock.yaml ]; then npm run build && pnpm prune --prod --ignore-scripts; \
  else echo "Lockfile not found." && exit 1; \
  fi
 
# Final run stage
FROM node:22.7.0-alpine3.19
 
ENV NODE_ENV production
USER node
WORKDIR /home/node
 
COPY --from=builder --chown=node:node /home/node/package*.json .
COPY --from=builder --chown=node:node /home/node/node_modules ./node_modules
COPY --from=builder --chown=node:node /home/node/dist ./dist
 
CMD ["node", "dist/main.js"]
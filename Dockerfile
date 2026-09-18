FROM node:24-bookworm-slim

WORKDIR /app
RUN corepack enable

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.base.json tsconfig.json ./
COPY artifacts ./artifacts
COPY lib ./lib
COPY scripts ./scripts
COPY data ./data
COPY replit.md ./

RUN pnpm install --frozen-lockfile
RUN pnpm --filter @workspace/api-spec run codegen
RUN pnpm --filter @workspace/biodiversity-intelligence-ai run build
RUN pnpm --filter @workspace/api-server run build

ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080
CMD ["node", "--enable-source-maps", "artifacts/api-server/dist/index.mjs"]
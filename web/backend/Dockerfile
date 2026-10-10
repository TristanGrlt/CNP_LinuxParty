FROM oven/bun:1 as base
WORKDIR /app

COPY package.json bun.lockb* ./
RUN bun install --production

COPY index.ts config.json ./

ENV DATA_DIR="/data"
EXPOSE 8086

CMD ["bun", "run", "index.ts"]

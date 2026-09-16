FROM node:lts AS build

WORKDIR /app

COPY . /app

RUN corepack enable && pnpm install --frozen-lockfile && pnpm build

FROM node:lts

COPY --from=build /app/configs /app/configs
COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/dist /app/dist
COPY --from=build /app/public /app/public
COPY --from=build /app/node_modules /app/node_modules

WORKDIR /app

EXPOSE 8000

CMD ["node", "--enable-source-maps", "dist/index.js"]

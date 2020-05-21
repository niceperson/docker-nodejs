#base stage from official node image
FROM node:14-slim as base
ENV NODE_ENV=production
EXPOSE 3000
WORKDIR /app
#COPY package*.json ./
RUN npm install --only=production && npm cache clean --force
ENV PATH /app/node_modules/.bin:$PATH
CMD ["node", "index.js"]

#dev stage
FROM base as dev
ENV NODE_ENV=development
RUN apt-get update -qq && apt-get install -qy \
    ca-certificates \
    bzip2 \
    curl \
    libfontconfig \
    --no-install-recommends
RUN npm install -g nodemon
RUN npm install --only=development && npm cache clean --force
CMD ["nodemon", "index.js"]


#test stage
FROM dev as test
COPY . .
RUN npm audit


#pre-prod stage - clean up
FROM test as pre-prod
RUN rm -rf ./tests && rm -rf ./node_modules


#prod  stage
FROM pre-prod as prod
COPY --from=pre-prod /app /app
HEALTHCHECK CMD curl http://localhost || exit 1
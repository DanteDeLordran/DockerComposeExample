FROM node:19.2-alpine3.16

WORKDIR /app

COPY package.json ./

RUN npm i

COPY . .

RUN npm run test

RUN rm -rf tests && rm -rf node_modules

RUN npm i --prod

CMD ["node","app.js"]
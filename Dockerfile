#Node
FROM node:19.2-alpine3.16
WORKDIR /app
COPY package.json ./
RUN npm i
COPY . .
RUN npm run test
RUN rm -rf tests && rm -rf node_modules
RUN npm i --prod
CMD ["node","app.js"]

# Java
FROM alpine/git as clone
ARG url
WORKDIR /app
RUN git clone ${url}

FROM maven:3.9.6-eclipse-temurin-21-jammy as build
ARG project 
WORKDIR /app
COPY --from=clone /app/${project} /app
RUN mvn package

FROM eclipse-temurin:21.0.2_13-jre-jammy
ARG artifactid
ARG version
ENV artifact ${artifactid}-${version}.jar
WORKDIR /app
COPY --from=build /app/target/${artifact} /app
EXPOSE 8080
ENTRYPOINT ["sh", "-c"]
CMD ["java -jar ${artifact}"]

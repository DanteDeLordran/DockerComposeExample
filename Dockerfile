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

FROM eclipse-temurin:21.0.2_13-jre-alpine
ARG artifactid
ARG version
ENV artifact ${artifactid}-${version}.jar
WORKDIR /app
COPY --from=build /app/target/${artifact} /app
EXPOSE 8080
ENTRYPOINT ["sh", "-c"]
CMD ["java -jar ${artifact}"]


# Sprin Boot docs dockerfile

FROM eclipse-temurin:21.0.2_13-jdk-alpine as build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM eclipse-temurin:21.0.2_13-jre-alpine
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]

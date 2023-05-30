# syntax = docker/dockerfile:experimental
FROM gradle:8.1.1-jdk17 AS builder
WORKDIR /src/spring-admin
COPY . .
RUN --mount=type=cache,target=/root/.m2  gradle clean build -i --stacktrace -x test 

FROM openjdk:17-slim
ARG VERSION

RUN useradd trif-user -g root && \
	usermod -aG root trif-user && \
    mkdir /home/trif-user/ && \
    chmod -R 0755 /home/trif-user/ && \
    chown -R trif-user:0 /home/trif-user/

USER trif-user
COPY --from=builder /src/spring-admin/build/libs/*.jar /home/trif-user/demo.jar
COPY src/main/resources/application.properties /home/trif-user/application.properties
EXPOSE 8085

WORKDIR /home/trif-user/
ENTRYPOINT java -jar /home/trif-user/demo.jar

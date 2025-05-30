# Deafult base image, it can be overridden with --build-arg BASE_IMAGE=some-other-base-image
ARG BASE_IMAGE=openjdk:21-jdk

# Tiny image that provides shell to the distroless image so that we can extract the SpringBoot layers
FROM busybox as shell-provider

# Build phase - Extract spring boot layers
FROM gcr.io/distroless/java21-debian12 as builder
ARG JAR_FILE

COPY --from=shell-provider /bin/sh /bin/sh

WORKDIR /sb

COPY ${JAR_FILE} app.jar

RUN java -Djarmode=layertools -jar app.jar extract

# Runtime
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.authors="nikolahristvski1122@gmail.com"

WORKDIR /sb

COPY --from=builder /sb/dependencies/ .
COPY --from=builder /sb/snapshot-dependencies/ .
COPY --from=builder /sb/spring-boot-loader/ .
COPY --from=builder /sb/application/ .


# Ensure owner is set correctly
# Copy the empty /tmp folder from the shell-provider to an app-specific, writeable folder
# With the change of the owner we allow applications to write data in this folder
ARG OWNED_DIRECTORY="/tmp"
COPY --from=shell-provider --chown=nonroot:nonroot /tmp $OWNED_DIRECTORY
VOLUME /tmp

EXPOSE 8080

ENTRYPOINT ["java", \
            "-server", \
            "-XX:+ExitOnOutOfMemoryError", \
            "-XX:-OmitStackTraceInFastThrow", \
            "-Dhttp.maxConnections=100", \
            "-Dspring.profiles.active=ecs", \
            "-XX:+UseG1GC", \
            "org.springframework.boot.loader.launch.JarLauncher"]
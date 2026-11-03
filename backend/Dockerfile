# One Dockerfile for every backend service: docker compose passes SERVICE=<folder name>.
FROM maven:3.9-eclipse-temurin-17 AS build
ARG SERVICE
WORKDIR /src

# common-lib is a shared dependency of most services - build/install it first
# so this layer is cached and reused by every service build.
COPY common-lib ./common-lib
RUN --mount=type=cache,target=/root/.m2 mvn -q -B -f common-lib/pom.xml install -DskipTests

COPY ${SERVICE} ./${SERVICE}
# Newer pg_dump adds psql-only restrict/unrestrict meta-commands that Flyway cannot run.
# Stripped here (image only) so the git-tracked migration and its checksum stay untouched.
RUN find ${SERVICE}/src -name 'V*.sql' -exec sed -i -E '/^[\\](un)?restrict /d' {} +
RUN --mount=type=cache,target=/root/.m2 mvn -q -B -f ${SERVICE}/pom.xml package -DskipTests \
    && cp ${SERVICE}/target/*.jar /app.jar

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app.jar app.jar
# 13 JVMs on one machine - cap each one's heap.
ENV JAVA_TOOL_OPTIONS="-Xms64m -Xmx400m"
ENTRYPOINT ["java", "-jar", "app.jar"]

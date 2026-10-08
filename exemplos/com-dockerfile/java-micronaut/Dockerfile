# Duas etapas: compila com o Maven (Java 25) e roda só com o JRE.
FROM maven:3.9-eclipse-temurin-25-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B package -DskipTests

FROM eclipse-temurin:25-jre-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build --chown=app:app /app/target/exemplo-1.0.jar app.jar
USER app:app
# O app lê a porta da variável PORT (opção port do deploy.yml; padrão 8080)
EXPOSE 8080
# JVM enxuta para protótipo acadêmico: coletor serial, só o compilador rápido,
# cache de código e pilhas menores, cabeçalhos de objeto compactos (Java 25),
# heap até 35% da memória do container.
ENTRYPOINT ["java", \
  "-XX:+UseSerialGC", "-XX:TieredStopAtLevel=1", \
  "-XX:ReservedCodeCacheSize=48M", "-Xss512k", \
  "-XX:+UseCompactObjectHeaders", \
  "-XX:MaxRAMPercentage=35.0", \
  "-jar", "app.jar"]

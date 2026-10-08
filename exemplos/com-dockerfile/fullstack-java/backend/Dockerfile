# ==============================================================================
# Dockerfile — Backend Spring Boot
#
# Hardening aplicado:
#   - Multi-stage build: imagem final contem apenas JRE + .jar
#   - Usuario nao-root: roda como "spring" (sem privilegios)
#   - .jar somente leitura (444): impede modificacao em runtime
#   - JVM container-aware: respeita limites de memoria do cgroup
#   - Imagem Alpine: superficie de ataque minima
#   - HEALTHCHECK: Docker monitora saude do container
# ==============================================================================

# --- Build ---
FROM maven:3.9-eclipse-temurin-25-alpine AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -DskipTests -B

# --- Runtime ---
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=build --chown=spring:spring --chmod=444 /app/target/*.jar app.jar

USER spring:spring

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=3s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

# JVM enxuta para protótipo acadêmico (cabe em 320 MB, medido com carga):
# coletor serial, só o compilador rápido, cache de código e pilhas menores,
# cabeçalhos de objeto compactos (Java 25), heap até 35% da memória do container.
ENTRYPOINT ["java", \
  "-XX:+UseSerialGC", "-XX:TieredStopAtLevel=1", \
  "-XX:ReservedCodeCacheSize=48M", "-Xss512k", \
  "-XX:+UseCompactObjectHeaders", \
  "-XX:MaxRAMPercentage=35.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]

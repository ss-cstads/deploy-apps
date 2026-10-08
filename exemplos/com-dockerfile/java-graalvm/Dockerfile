# Duas etapas: o GraalVM compila o código em um executável nativo estático, e a
# imagem final tem só esse arquivo (sem JVM, sem sistema operacional).
FROM ghcr.io/graalvm/native-image-community:25-muslib AS build
WORKDIR /src
COPY src ./src
RUN mkdir /classes /saida && javac -d /classes $(find src/main/java -name '*.java') \
 && native-image --static --libc=musl -cp /classes -o /saida/app exemplo.Main

FROM scratch
COPY --from=build /saida/app /app
USER 65534
# O app lê a porta da variável PORT (opção port do deploy.yml; padrão 8080)
EXPOSE 8080
ENTRYPOINT ["/app"]

# Duas etapas: compila com a imagem do Go e roda só o binário numa imagem mínima.
FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY *.go ./
RUN CGO_ENABLED=0 go build -o /app .

FROM alpine:3.22
RUN adduser -D -H app
USER app
COPY --from=build /app /app
# O app lê a porta da variável PORT (opção port do deploy.yml; padrão 8080)
EXPOSE 8080
ENTRYPOINT ["/app"]

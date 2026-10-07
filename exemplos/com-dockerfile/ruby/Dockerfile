# Duas etapas: instala as gems (algumas compilam código nativo) e copia o
# resultado para a imagem enxuta que roda o app.
FROM ruby:3.4 AS build
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without development && bundle install

FROM ruby:3.4-slim
WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . .
RUN useradd --no-create-home app
USER app
# O Puma escuta na porta da variável PORT (opção port do deploy.yml; padrão 8080)
EXPOSE 8080
CMD ["sh", "-c", "bundle exec puma --bind tcp://0.0.0.0:${PORT:-8080}"]

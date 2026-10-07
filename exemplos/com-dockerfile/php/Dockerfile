# PHP com Apache. O Apache escuta na porta 80: port: 80 no deploy.yml.
FROM php:8.4-apache
# Extensão do MySQL (PDO); mbstring já vem na imagem
RUN docker-php-ext-install pdo_mysql
COPY index.php /var/www/html/
EXPOSE 80

# Duas etapas: compila com o SDK e roda só com o runtime do ASP.NET Core.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY exemplo.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
# A imagem do ASP.NET Core já escuta na porta 8080 (padrão da opção port)
EXPOSE 8080
ENTRYPOINT ["dotnet", "exemplo.dll"]

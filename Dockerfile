FROM mcr.microsoft.com/dotnet/sdk:5.0 AS installer-env
# Build requires 3.1 SDK
COPY --from=mcr.microsoft.com/dotnet/core/sdk:3.1 /usr/share/dotnet /usr/share/dotnet

COPY . /src/dotnet-function-app
RUN cd /src/dotnet-function-app && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot

# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet-isolated:3.0-dotnet-isolated5.0-appservice
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:3.0-dotnet-isolated5.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]

RUN apt-get update && apt-get install -y \
      $(/home/site/wwwroot/.playwright/node/linux/node -e "console.log(require('/home/site/wwwroot/.playwright/package/lib/nativeDeps.js').deps.bionic.chromium.join (' '))") && \
      # libasound2 \ 
      # libatk1.0-0 \ 
      # libatk-bridge2.0-0 \ 
      # libatspi2.0-0 \ 
      # libcairo2 \ 
      # libcups2 \ 
      # libdbus-1-3 \ 
      # libdrm2 \ 
      # libgbm1 \ 
      # libglib2.0-0 \ 
      # libnspr4 \ 
      # libnss3 \ 
      # libpango-1.0-0 \ 
      # libxcomposite1 \ 
      # libxdamage1 \ 
      # libxfixes3 \ 
      # libxkbcommon0 \
      # libxrandr2 && \
    /home/site/wwwroot/.playwright/node/linux/playwright.sh install chromium

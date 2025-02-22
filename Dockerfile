ARG MAIN_PROJECT_SRC=./src
ARG TEST_PROJECT_SRC=./tests

FROM mcr.microsoft.com/dotnet/sdk:5.0

# Add Microsoft Debian apt-get feed
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb

# Fix JRE Install https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

# Install the .NET 5 Runtime for SonarScanner
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y apt-transport-https \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y aspnetcore-runtime-5.0

# Install Java Runtime for SonarScanner
RUN apt-get install --no-install-recommends -y openjdk-11-jre

WORKDIR /app

ARG MAIN_PROJECT_SRC
ARG TEST_PROJECT_SRC

# https://github.com/dotnet/dotnet-docker/issues/520
ENV PATH="${PATH}:/root/.dotnet/tools"

# Tools used during development
RUN dotnet tool install --global dotnet-format
RUN dotnet tool install --global dotnet-sonarscanner

# Restores (downloads) all NuGet packages from all projects of the solution on a separate layer
COPY ${MAIN_PROJECT_SRC}/*.csproj ${MAIN_PROJECT_SRC}/
COPY ${TEST_PROJECT_SRC}/*.csproj ${TEST_PROJECT_SRC}/

RUN dotnet restore ${MAIN_PROJECT_SRC}
RUN dotnet restore ${TEST_PROJECT_SRC}

COPY . ./

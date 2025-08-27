# Dockerfile para devcontainer con Terraform y Azure CLI
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias básicas
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    unzip \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    git \
    nano \
    bash-completion \
    sudo

CMD ["bash"]
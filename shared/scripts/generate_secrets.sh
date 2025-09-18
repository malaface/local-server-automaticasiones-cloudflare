#!/bin/bash

# Script para generar todas las variables de seguridad necesarias
# Se puede llamar desde cualquier modo

generate_secret() {
    local var_name="$1"
    local env_file="$2"
    local length="${3:-32}"

    if ! grep -q "${var_name}=.\+" "$env_file" 2>/dev/null; then
        echo "Generando $var_name..."
        echo "${var_name}=$(openssl rand -hex $length)" >> "$env_file"
    fi
}

generate_password() {
    local var_name="$1"
    local env_file="$2"

    if ! grep -q "${var_name}=.\+" "$env_file" 2>/dev/null; then
        echo "Generando $var_name..."
        echo "${var_name}=$(openssl rand -base64 32)" >> "$env_file"
    fi
}

# Archivo .env (debe ser pasado como argumento)
ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: Archivo $ENV_FILE no encontrado"
    exit 1
fi

echo "🔐 Generando variables de seguridad en $ENV_FILE..."

# Generar todas las variables necesarias
generate_password "POSTGRES_PASSWORD" "$ENV_FILE"
generate_secret "JWT_SECRET" "$ENV_FILE" 64
generate_secret "SECRET_KEY_BASE" "$ENV_FILE" 64
generate_secret "N8N_ENCRYPTION_KEY" "$ENV_FILE" 32
generate_secret "ANON_KEY" "$ENV_FILE" 64
generate_secret "SERVICE_ROLE_KEY" "$ENV_FILE" 64
generate_secret "VAULT_ENC_KEY" "$ENV_FILE" 32

# Asegurar que Docker socket está configurado
if ! grep -q "DOCKER_SOCKET_LOCATION=.\+" "$ENV_FILE"; then
    echo "Configurando Docker socket..."
    echo "DOCKER_SOCKET_LOCATION=/var/run/docker.sock" >> "$ENV_FILE"
fi

echo "✅ Variables de seguridad generadas correctamente"
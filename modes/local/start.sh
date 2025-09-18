#!/bin/bash

# Modo Local - Setup y ejecución automática
echo "🏠 Iniciando Stack AI en Modo Local..."

# Verificar que estamos en la carpeta correcta
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Ejecuta este script desde la carpeta modes/local/"
    exit 1
fi

# Crear .env si no existe
if [ ! -f ".env" ]; then
    echo "📄 Creando archivo .env..."
    cp .env.example .env
fi

# Generar variables de seguridad si están vacías
echo "🔐 Generando variables de seguridad..."
if ! grep -q "POSTGRES_PASSWORD=.\+" .env; then
    echo "POSTGRES_PASSWORD=$(openssl rand -base64 32)" >> .env
fi
if ! grep -q "JWT_SECRET=.\+" .env; then
    echo "JWT_SECRET=$(openssl rand -hex 64)" >> .env
fi
if ! grep -q "SECRET_KEY_BASE=.\+" .env; then
    echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> .env
fi
if ! grep -q "N8N_ENCRYPTION_KEY=.\+" .env; then
    echo "N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)" >> .env
fi
if ! grep -q "ANON_KEY=.\+" .env; then
    echo "ANON_KEY=$(openssl rand -base64 64)" >> .env
fi
if ! grep -q "SERVICE_ROLE_KEY=.\+" .env; then
    echo "SERVICE_ROLE_KEY=$(openssl rand -base64 64)" >> .env
fi
if ! grep -q "VAULT_ENC_KEY=.\+" .env; then
    echo "VAULT_ENC_KEY=$(openssl rand -hex 32)" >> .env
fi

# Verificar Docker
if ! docker ps >/dev/null 2>&1; then
    echo "❌ Error: Docker no está ejecutándose o no tienes permisos"
    echo "💡 Solución: sudo systemctl start docker && sudo usermod -aG docker $USER"
    exit 1
fi

echo "🚀 Iniciando servicios..."

# Iniciar Supabase primero
echo "📦 Iniciando Supabase..."
cd ../../supabase/docker
docker compose up -d
cd ../../modes/local

# Esperar un poco
echo "⏳ Esperando 10 segundos para que Supabase esté listo..."
sleep 10

# Iniciar servicios principales
echo "🔄 Iniciando servicios principales..."
docker compose up -d

echo ""
echo "✅ ¡Stack AI Local iniciado!"
echo ""
echo "🌐 Accede a tus servicios:"
echo "  • n8n:        http://localhost:5678"
echo "  • Open WebUI: http://localhost:3000"
echo "  • Flowise:    http://localhost:3001"
echo "  • Qdrant:     http://localhost:6333"
echo "  • Supabase:   http://localhost:8000"
echo "  • SearXNG:    http://localhost:8080"
echo ""
echo "⏱️  Los servicios pueden tardar 1-2 minutos en estar completamente listos"
echo "📊 Verifica el estado: docker ps"
echo "📜 Ver logs: docker logs -f [nombre-servicio]"
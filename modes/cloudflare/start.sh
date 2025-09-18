#!/bin/bash

# Modo Cloudflare - Acceso remoto seguro sin puertos
echo "🌐 Iniciando Stack AI en Modo Cloudflare (Tunnel)..."

# Verificar que estamos en la carpeta correcta
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Ejecuta este script desde la carpeta modes/cloudflare/"
    exit 1
fi

# Crear .env si no existe
if [ ! -f ".env" ]; then
    echo "📄 Creando archivo .env..."
    cp .env.example .env
    echo "⚠️  IMPORTANTE: Edita el archivo .env y configura:"
    echo "   - TUNNEL_TOKEN=tu_token_de_cloudflare"
    echo "   - CLOUDFLARE_DOMAIN=ai.tudominio.com"
    echo "   También edita config.yml con tu tunnel ID y dominio."
    echo "   Después ejecuta este script nuevamente."
    exit 1
fi

# Verificar variables obligatorias
if ! grep -q "TUNNEL_TOKEN=.\+" .env || ! grep -q "CLOUDFLARE_DOMAIN=.\+" .env; then
    echo "❌ Error: Variables obligatorias no configuradas en .env"
    echo "💡 Configura: TUNNEL_TOKEN y CLOUDFLARE_DOMAIN"
    exit 1
fi

# Verificar configuración del tunnel
if grep -q "tu-tunnel-id-aqui" config.yml || grep -q "tudominio.com" config.yml; then
    echo "❌ Error: config.yml no está personalizado"
    echo "💡 Edita config.yml y reemplaza:"
    echo "   - tu-tunnel-id-aqui → tu tunnel ID real"
    echo "   - tudominio.com → tu dominio real"
    exit 1
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
    exit 1
fi

echo "🚀 Iniciando servicios..."

# Iniciar Supabase primero
echo "📦 Iniciando Supabase..."
cd ../../supabase/docker
docker compose up -d
cd ../../modes/cloudflare

# Esperar un poco
echo "⏳ Esperando 10 segundos para que Supabase esté listo..."
sleep 10

# Iniciar servicios principales
echo "🔄 Iniciando servicios principales con Cloudflare Tunnel..."
docker compose up -d

DOMAIN=$(grep CLOUDFLARE_DOMAIN .env | cut -d'=' -f2)

echo ""
echo "✅ ¡Stack AI con Cloudflare Tunnel iniciado!"
echo ""
echo "🌐 Accede a tus servicios:"
echo "  • Dashboard:  https://$DOMAIN"
echo "  • n8n:        https://$DOMAIN/n8n"
echo "  • Open WebUI: https://$DOMAIN/openwebui"
echo "  • Flowise:    https://$DOMAIN/flowise"
echo "  • Qdrant:     https://$DOMAIN/qdrant"
echo "  • Supabase:   https://$DOMAIN/supabase"
echo "  • SearXNG:    https://$DOMAIN/searxng"
echo ""
echo "⏱️  El tunnel puede tardar 1-2 minutos en conectarse"
echo "🔗 Estado tunnel: docker logs -f cloudflared"
echo "📊 Estado servicios: docker ps"
echo ""
echo "💡 Si hay problemas:"
echo "   - Verifica tunnel en Cloudflare Dashboard"
echo "   - DNS: nslookup $DOMAIN"
echo "   - Token: grep TUNNEL_TOKEN .env"
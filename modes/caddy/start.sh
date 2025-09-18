#!/bin/bash

# Modo Caddy - SSL automático con dominio
echo "🔐 Iniciando Stack AI en Modo Caddy (SSL + Dominio)..."

# Verificar que estamos en la carpeta correcta
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Ejecuta este script desde la carpeta modes/caddy/"
    exit 1
fi

# Crear .env si no existe
if [ ! -f ".env" ]; then
    echo "📄 Creando archivo .env..."
    cp .env.example .env
    echo "⚠️  IMPORTANTE: Edita el archivo .env y configura:"
    echo "   - CLOUDFLARE_DOMAIN=ai.tudominio.com"
    echo "   - LETSENCRYPT_EMAIL=tu@email.com"
    echo "   Después ejecuta este script nuevamente."
    exit 1
fi

# Verificar variables obligatorias
if ! grep -q "CLOUDFLARE_DOMAIN=.\+" .env || ! grep -q "LETSENCRYPT_EMAIL=.\+" .env; then
    echo "❌ Error: Variables obligatorias no configuradas en .env"
    echo "💡 Configura: CLOUDFLARE_DOMAIN y LETSENCRYPT_EMAIL"
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

# Verificar puertos 80 y 443
if netstat -tlnp 2>/dev/null | grep -E ":(80|443)" | grep -v docker >/dev/null; then
    echo "⚠️  Advertencia: Los puertos 80 o 443 pueden estar ocupados"
    echo "   Detén otros servicios web si es necesario:"
    echo "   sudo systemctl stop nginx apache2"
fi

echo "🚀 Iniciando servicios..."

# Iniciar Supabase primero
echo "📦 Iniciando Supabase..."
cd ../../supabase/docker
docker compose up -d
cd ../../modes/caddy

# Esperar un poco
echo "⏳ Esperando 10 segundos para que Supabase esté listo..."
sleep 10

# Iniciar servicios principales
echo "🔄 Iniciando servicios principales con Caddy..."
docker compose up -d

DOMAIN=$(grep CLOUDFLARE_DOMAIN .env | cut -d'=' -f2)

echo ""
echo "✅ ¡Stack AI con SSL iniciado!"
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
echo "⏱️  Los certificados SSL pueden tardar 2-3 minutos en generarse"
echo "🔒 Verifica SSL: docker logs -f caddy"
echo "📊 Estado: docker ps"
echo ""
echo "💡 Si hay problemas con SSL, verifica:"
echo "   - DNS: nslookup $DOMAIN"
echo "   - Puertos: sudo netstat -tlnp | grep -E \":(80|443)\""
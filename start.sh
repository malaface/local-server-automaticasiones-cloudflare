#!/bin/bash

# =============================================================================
# Stack AI Local - Cloudflare Tunnel Directo
# Arquitectura: Internet → Cloudflare Tunnel → Docker Services (directo)
# =============================================================================

set -e  # Salir en caso de error

echo "🚀 Stack AI Local - Cloudflare Tunnel Directo"
echo "==============================================="
echo "Arquitectura: Internet → Cloudflare Tunnel → Docker Services"
echo ""

# =============================================================================
# Verificaciones iniciales
# =============================================================================

echo "🔍 Verificando requisitos..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    echo "💡 Instala Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar Docker Compose
if ! docker compose version &> /dev/null; then
    echo "❌ Error: Docker Compose no está disponible"
    echo "💡 Instala Docker Compose v2"
    exit 1
fi

# Verificar permisos de Docker
if ! docker ps &> /dev/null; then
    echo "❌ Error: No tienes permisos para usar Docker"
    echo "💡 Ejecuta: sudo usermod -aG docker $USER"
    echo "💡 Luego reinicia sesión o ejecuta: newgrp docker"
    exit 1
fi

# Verificar OpenSSL para generar secretos
if ! command -v openssl &> /dev/null; then
    echo "❌ Error: OpenSSL no está instalado"
    echo "💡 Instala OpenSSL: sudo apt install openssl"
    exit 1
fi

echo "✅ Todos los requisitos están cumplidos"

# =============================================================================
# Configuración del archivo .env
# =============================================================================

echo ""
echo "📄 Configurando variables de entorno..."

# Crear .env si no existe
if [ ! -f ".env" ]; then
    echo "📝 Creando archivo .env desde .env.example..."
    cp .env.example .env
fi

# Función para generar y configurar variables
generate_if_empty() {
    local var_name="$1"
    local generator="$2"

    if ! grep -q "${var_name}=.\+" .env; then
        echo "🔐 Generando $var_name..."
        sed -i "s/^${var_name}=.*/${var_name}=$($generator)/" .env
    fi
}

# Generar todas las variables de seguridad automáticamente
generate_if_empty "POSTGRES_PASSWORD" "openssl rand -base64 32 | tr -d '/+' | head -c 32"
generate_if_empty "JWT_SECRET" "openssl rand -hex 64"
generate_if_empty "SECRET_KEY_BASE" "openssl rand -hex 64"
generate_if_empty "N8N_ENCRYPTION_KEY" "openssl rand -hex 32"
generate_if_empty "ANON_KEY" "openssl rand -base64 64 | tr -d '/+' | head -c 64"
generate_if_empty "SERVICE_ROLE_KEY" "openssl rand -base64 64 | tr -d '/+' | head -c 64"
generate_if_empty "VAULT_ENC_KEY" "openssl rand -hex 32"

# Asegurar que Docker socket está configurado
if ! grep -q "DOCKER_SOCKET_LOCATION=.\+" .env; then
    echo "🐳 Configurando Docker socket..."
    echo "DOCKER_SOCKET_LOCATION=/var/run/docker.sock" >> .env
fi

echo "✅ Variables de seguridad configuradas"

# =============================================================================
# Verificar configuración de Cloudflare
# =============================================================================

echo ""
echo "🌐 Verificando configuración de Cloudflare Tunnel..."

# Verificar variables obligatorias
TUNNEL_TOKEN=$(grep "TUNNEL_TOKEN=" .env | cut -d'=' -f2)
CLOUDFLARE_DOMAIN=$(grep "CLOUDFLARE_DOMAIN=" .env | cut -d'=' -f2)

if [ -z "$TUNNEL_TOKEN" ] || [ "$TUNNEL_TOKEN" = "eyJhIjoi...tu_token_cloudflare_tunnel_aqui" ]; then
    echo ""
    echo "⚠️  CONFIGURACIÓN REQUERIDA: Cloudflare Tunnel"
    echo ""
    echo "📋 Pasos para configurar:"
    echo ""
    echo "1. 🌐 Ir a Cloudflare Dashboard → Zero Trust → Networks → Tunnels"
    echo "2. ➕ Create a tunnel → Nombre: 'mi-stack-ai'"
    echo "3. 📝 Copiar el TOKEN y agregarlo al archivo .env:"
    echo "   TUNNEL_TOKEN=eyJhIjoi...tu_token_real"
    echo ""
    echo "4. 🔗 Configurar DNS en Cloudflare (registros CNAME):"
    echo "   n8n.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com"
    echo "   openwebui.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com"
    echo "   flowise.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com"
    echo "   qdrant.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com"
    echo "   supabase.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com"
    echo "   searxng.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com"
    echo ""
    echo "5. ✏️  Editar .env y config.yml con tu dominio real"
    echo ""
    echo "📖 Guía completa: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/"
    echo ""
    echo "⚡ Después de configurar, ejecuta este script nuevamente"
    exit 1
fi

if [ -z "$CLOUDFLARE_DOMAIN" ] || [ "$CLOUDFLARE_DOMAIN" = "tudominio.com" ]; then
    echo "⚠️  Por favor configura tu dominio real en .env:"
    echo "   CLOUDFLARE_DOMAIN=tu-dominio-real.com"
    exit 1
fi

# Verificar configuración del tunnel
if grep -q "tu-tunnel-id-aqui" config.yml || grep -q "tudominio.com" config.yml; then
    echo "⚠️  Por favor personaliza config.yml con tu tunnel ID y dominio reales"
    echo "💡 Reemplaza:"
    echo "   - tu-tunnel-id-aqui → tu tunnel ID real"
    echo "   - tudominio.com → $CLOUDFLARE_DOMAIN"
    exit 1
fi

echo "✅ Configuración de Cloudflare verificada"

# =============================================================================
# Validación final antes de iniciar
# =============================================================================

echo ""
echo "🔧 Validando configuración de Docker Compose..."

# Validar sintaxis
if ! docker compose config > /dev/null 2>&1; then
    echo "❌ Error en la configuración de Docker Compose"
    echo "🔍 Ejecuta: docker compose config"
    exit 1
fi

echo "✅ Configuración válida"

# =============================================================================
# Iniciar servicios
# =============================================================================

echo ""
echo "🚀 Iniciando Stack AI Local..."

# Limpiar contenedores anteriores si existen
if docker ps -a --format "table {{.Names}}" | grep -E "(n8n|cloudflared)" > /dev/null; then
    echo "🧹 Limpiando contenedores anteriores..."
    docker compose down 2>/dev/null || true
fi

# Iniciar Supabase primero (base de datos)
echo "📦 Iniciando Supabase (base de datos)..."
cd supabase/docker
docker compose up -d
cd ../..

# Esperar un poco para que Supabase esté listo
echo "⏳ Esperando que Supabase esté listo (15 segundos)..."
sleep 15

# Iniciar servicios principales
echo "🔄 Iniciando servicios principales..."
docker compose up -d

# =============================================================================
# Verificación post-inicio
# =============================================================================

echo ""
echo "✅ ¡Stack AI Local iniciado exitosamente!"
echo ""

# Mostrar información de acceso
echo "🌐 Accede a tus servicios:"
echo "  • n8n:        https://n8n.$CLOUDFLARE_DOMAIN"
echo "  • Open WebUI: https://openwebui.$CLOUDFLARE_DOMAIN"
echo "  • Flowise:    https://flowise.$CLOUDFLARE_DOMAIN"
echo "  • Qdrant:     https://qdrant.$CLOUDFLARE_DOMAIN"
echo "  • Supabase:   https://supabase.$CLOUDFLARE_DOMAIN"
echo "  • SearXNG:    https://searxng.$CLOUDFLARE_DOMAIN"
echo ""

# Información sobre tiempo de inicio
echo "⏱️  Los servicios pueden tardar 2-3 minutos en estar completamente listos"
echo "🔗 El tunnel puede tardar 1-2 minutos en conectarse"
echo ""

# Comandos útiles
echo "📋 Comandos útiles:"
echo "  Estado servicios: docker ps"
echo "  Logs tunnel:      docker logs -f cloudflared"
echo "  Logs servicio:    docker logs -f [nombre-servicio]"
echo "  Detener todo:     docker compose down"
echo ""

# Verificar que los contenedores principales están ejecutándose
echo "🔍 Verificando estado de servicios..."
sleep 5

RUNNING_SERVICES=$(docker ps --format "table {{.Names}}" | grep -E "(n8n|cloudflared|open-webui|flowise)" | wc -l)

if [ "$RUNNING_SERVICES" -ge 3 ]; then
    echo "✅ Servicios principales están ejecutándose"
    echo ""
    echo "🎯 Próximos pasos:"
    echo "  1. Espera 2-3 minutos para que todo esté listo"
    echo "  2. Verifica conexión: docker logs -f cloudflared"
    echo "  3. ¡Accede a https://n8n.$CLOUDFLARE_DOMAIN!"
else
    echo "⚠️  Algunos servicios pueden estar iniciando todavía"
    echo "🔧 Verifica con: docker ps"
    echo "📜 Ver logs: docker logs -f cloudflared"
fi

echo ""
echo "🎉 ¡Stack AI Local ultra-simplificado está listo!"
echo "⚡ Máximo rendimiento, mínima complejidad"
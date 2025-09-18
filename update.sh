#!/bin/bash

# =============================================================================
# Stack AI Local Mejorado - Script de Actualización Automática
# =============================================================================
# Este script actualiza todas las imágenes Docker y reinicia los servicios
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker no está ejecutándose"
        exit 1
    fi
}

# Function to get current mode from running containers
get_current_mode() {
    local mode="local"
    
    if docker ps --filter "name=caddy" --format "{{.Names}}" | grep -q caddy; then
        if docker ps --filter "name=cloudflared" --format "{{.Names}}" | grep -q cloudflared; then
            mode="full"
        else
            mode="caddy"
        fi
    elif docker ps --filter "name=cloudflared" --format "{{.Names}}" | grep -q cloudflared; then
        mode="cloudflare"
    fi
    
    echo $mode
}

# Main update function
main() {
    clear
    echo "=================================================================="
    echo "🔄 Stack AI Local - Actualización Automática"
    echo "=================================================================="
    echo "Este script actualizará todas las imágenes Docker y reiniciará"
    echo "los servicios manteniendo tu configuración actual."
    echo "=================================================================="
    echo

    # Check Docker
    log_info "Verificando Docker..."
    check_docker
    log_success "Docker está ejecutándose ✅"
    echo

    # Detect current mode
    log_info "Detectando modo actual..."
    CURRENT_MODE=$(get_current_mode)
    log_info "Modo detectado: $CURRENT_MODE"
    echo

    # Confirm update
    log_warning "⚠️  Esta operación detendrá temporalmente los servicios"
    echo "¿Deseas continuar con la actualización? (y/N)"
    read -r confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_info "Actualización cancelada por el usuario"
        exit 0
    fi
    echo

    # Step 1: Pull latest images
    log_info "Paso 1/4: Descargando últimas versiones de imágenes..."
    
    # Pull main stack images based on mode
    log_info "Actualizando imágenes principales..."
    case $CURRENT_MODE in
        "local")
            docker compose -p localai -f docker-compose.yml pull
            ;;
        "caddy")
            docker compose -p localai -f docker-compose.yml --profile caddy pull
            ;;
        "cloudflare")
            docker compose -p localai -f docker-compose.yml --profile cloudflare pull
            ;;
        "full")
            docker compose -p localai -f docker-compose.yml --profile caddy --profile cloudflare pull
            ;;
    esac
    
    # Pull Supabase images
    if [ -d "supabase/docker" ]; then
        log_info "Actualizando imágenes de Supabase..."
        cd supabase/docker
        docker compose pull
        cd ../..
    fi
    
    log_success "Todas las imágenes actualizadas ✅"
    echo

    # Step 2: Stop services
    log_info "Paso 2/4: Deteniendo servicios..."
    case $CURRENT_MODE in
        "local")
            docker compose -p localai -f docker-compose.yml down
            ;;
        "caddy")
            docker compose -p localai -f docker-compose.yml --profile caddy down
            ;;
        "cloudflare")
            docker compose -p localai -f docker-compose.yml --profile cloudflare down
            ;;
        "full")
            docker compose -p localai -f docker-compose.yml --profile caddy --profile cloudflare down
            ;;
    esac
    log_success "Servicios detenidos ✅"
    echo

    # Step 3: Clean up old images
    log_info "Paso 3/4: Limpiando imágenes antiguas..."
    docker image prune -f >/dev/null 2>&1 || true
    log_success "Limpieza completada ✅"
    echo

    # Step 4: Restart services
    log_info "Paso 4/4: Reiniciando servicios en modo $CURRENT_MODE..."
    python3 start_services.py --mode $CURRENT_MODE
    
    if [ $? -eq 0 ]; then
        log_success "🎉 Actualización completada exitosamente!"
        echo ""
        echo "=================================================================="
        echo "📊 RESUMEN DE ACTUALIZACIÓN:"
        echo "=================================================================="
        echo "• Modo: $CURRENT_MODE"
        echo "• Imágenes actualizadas: ✅"
        echo "• Servicios reiniciados: ✅"
        echo "• Limpieza realizada: ✅"
        echo ""
        echo "Los servicios deberían estar disponibles en unos momentos."
        echo "=================================================================="
    else
        log_error "Error al reiniciar los servicios"
        log_info "Puedes intentar iniciar manualmente con:"
        echo "  python3 start_services.py --mode $CURRENT_MODE"
        exit 1
    fi
}

# Check if script is run from correct directory
if [[ ! -f "start_services.py" ]]; then
    log_error "Este script debe ejecutarse desde el directorio del proyecto."
    log_info "Navega al directorio que contiene start_services.py y ejecuta:"
    echo "  ./update.sh"
    exit 1
fi

# Run main function
main "$@"
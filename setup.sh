#!/bin/bash

# =============================================================================
# Stack AI Local Mejorado - Setup Automático para Servidor Remoto
# =============================================================================
# Este script automatiza la configuración completa del entorno
# Especialmente diseñado para usuarios conectados via PuTTY/SSH
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if user is in docker group
check_docker_permissions() {
    if groups $USER | grep -q docker; then
        return 0
    else
        return 1
    fi
}

# Function to generate secure random values
generate_secure_value() {
    local length=${1:-32}
    if command_exists openssl; then
        openssl rand -hex $length
    else
        # Fallback if openssl is not available
        head /dev/urandom | tr -dc A-Za-z0-9 | head -c $length
    fi
}

# Function to generate base64 values
generate_base64_value() {
    local length=${1:-32}
    if command_exists openssl; then
        openssl rand -base64 $length
    else
        # Fallback if openssl is not available
        head /dev/urandom | tr -dc A-Za-z0-9 | head -c $length | base64
    fi
}

# Main setup function
main() {
    clear
    echo "=================================================================="
    echo "🚀 Stack AI Local Mejorado - Setup Automático"
    echo "=================================================================="
    echo "Este script configurará automáticamente todo el entorno necesario"
    echo "para ejecutar el stack de AI en tu servidor remoto."
    echo "=================================================================="
    echo

    # Step 1: Check basic requirements
    log_info "Paso 1/6: Verificando requisitos básicos..."
    
    # Check if we're on a supported OS
    if [[ ! "$OSTYPE" =~ ^linux ]]; then
        log_error "Este script está diseñado para sistemas Linux."
        log_info "Para otros sistemas operativos, consulta el README.md"
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command_exists docker; then
        log_error "Docker no está instalado."
        log_info "Por favor instala Docker primero:"
        echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
        echo "  sh get-docker.sh"
        exit 1
    fi
    
    # Check if Docker Compose is available
    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose no está disponible."
        log_info "Por favor instala Docker Compose plugin:"
        echo "  sudo apt update && sudo apt install docker-compose-plugin"
        exit 1
    fi
    
    # Check Docker service
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker service no está ejecutándose."
        log_info "Iniciando Docker service..."
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    
    # Check Docker permissions
    if ! check_docker_permissions; then
        log_warning "El usuario $USER no está en el grupo docker."
        log_info "Agregando al grupo docker..."
        sudo usermod -aG docker $USER
        log_warning "⚠️  IMPORTANTE: Necesitas cerrar sesión y volver a conectarte para que los cambios tengan efecto."
        log_info "Después de reconectarte, ejecuta este script nuevamente."
        exit 0
    fi
    
    # Test Docker permissions
    if ! docker ps >/dev/null 2>&1; then
        log_error "No se pueden ejecutar comandos Docker sin sudo."
        log_info "Hay un problema con los permisos de Docker."
        exit 1
    fi
    
    log_success "Requisitos básicos verificados ✅"
    echo

    # Step 2: Check if .env exists
    log_info "Paso 2/6: Configurando archivo de entorno..."
    
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.example" ]]; then
            log_info "Creando .env desde .env.example..."
            cp .env.example .env
        else
            log_error "No se encontró .env.example. Asegúrate de estar en el directorio correcto."
            exit 1
        fi
    fi
    
    log_success "Archivo .env preparado ✅"
    echo

    # Step 3: Generate secure values
    log_info "Paso 3/6: Generando valores seguros..."
    
    # Read current .env to check what needs to be generated
    declare -A current_values
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^[[:space:]]*# ]] && [[ $key ]] && [[ $value ]]; then
            current_values[$key]=$value
        fi
    done < .env
    
    # Function to update or add env variable
    update_env_var() {
        local key=$1
        local value=$2
        
        if grep -q "^${key}=" .env; then
            # Update existing
            sed -i "s|^${key}=.*|${key}=${value}|" .env
        else
            # Add new
            echo "${key}=${value}" >> .env
        fi
    }
    
    # Generate values only if they don't exist or are placeholder values
    need_generation() {
        local key=$1
        local current_value="${current_values[$key]}"
        
        [[ -z "$current_value" ]] || [[ "$current_value" =~ ^your_ ]] || [[ "$current_value" == "tu_"* ]] || [[ "$current_value" == "ultrasecretkey" ]]
    }
    
    # Critical variables that must be set
    if need_generation "POSTGRES_PASSWORD"; then
        update_env_var "POSTGRES_PASSWORD" "$(generate_base64_value 32)"
        log_info "✅ POSTGRES_PASSWORD generado"
    fi
    
    if need_generation "JWT_SECRET"; then
        update_env_var "JWT_SECRET" "$(generate_secure_value 64)"
        log_info "✅ JWT_SECRET generado"
    fi
    
    if need_generation "SECRET_KEY_BASE"; then
        update_env_var "SECRET_KEY_BASE" "$(generate_secure_value 64)"
        log_info "✅ SECRET_KEY_BASE generado"
    fi
    
    if need_generation "ANON_KEY"; then
        update_env_var "ANON_KEY" "$(generate_secure_value 64)"
        log_info "✅ ANON_KEY generado"
    fi
    
    if need_generation "SERVICE_ROLE_KEY"; then
        update_env_var "SERVICE_ROLE_KEY" "$(generate_secure_value 64)"
        log_info "✅ SERVICE_ROLE_KEY generado"
    fi
    
    if need_generation "N8N_ENCRYPTION_KEY"; then
        update_env_var "N8N_ENCRYPTION_KEY" "$(generate_secure_value 32)"
        log_info "✅ N8N_ENCRYPTION_KEY generado"
    fi
    
    if need_generation "N8N_USER_MANAGEMENT_JWT_SECRET"; then
        update_env_var "N8N_USER_MANAGEMENT_JWT_SECRET" "$(generate_secure_value 32)"
        log_info "✅ N8N_USER_MANAGEMENT_JWT_SECRET generado"
    fi
    
    if need_generation "VAULT_ENC_KEY"; then
        update_env_var "VAULT_ENC_KEY" "$(generate_secure_value 32)"
        log_info "✅ VAULT_ENC_KEY generado"
    fi
    
    # Set Docker socket location
    update_env_var "DOCKER_SOCKET_LOCATION" "/var/run/docker.sock"
    log_info "✅ DOCKER_SOCKET_LOCATION configurado"
    
    # Set default passwords for services
    if need_generation "N8N_BASIC_AUTH_PASSWORD"; then
        update_env_var "N8N_BASIC_AUTH_PASSWORD" "$(generate_base64_value 16)"
        log_info "✅ N8N_BASIC_AUTH_PASSWORD generado"
    fi
    
    if need_generation "FLOWISE_PASSWORD"; then
        update_env_var "FLOWISE_PASSWORD" "$(generate_base64_value 16)"
        log_info "✅ FLOWISE_PASSWORD generado"
    fi
    
    # Variables adicionales para evitar warnings de Supabase
    if need_generation "POOLER_DEFAULT_POOL_SIZE"; then
        update_env_var "POOLER_DEFAULT_POOL_SIZE" "20"
    fi
    
    if need_generation "POOLER_DB_POOL_SIZE"; then
        update_env_var "POOLER_DB_POOL_SIZE" "10"
    fi
    
    if need_generation "POOLER_MAX_CLIENT_CONN"; then
        update_env_var "POOLER_MAX_CLIENT_CONN" "100"
    fi
    
    if need_generation "POOLER_PROXY_PORT_TRANSACTION"; then
        update_env_var "POOLER_PROXY_PORT_TRANSACTION" "5432"
    fi
    
    if need_generation "STUDIO_DEFAULT_ORGANIZATION"; then
        update_env_var "STUDIO_DEFAULT_ORGANIZATION" "Default Organization"
    fi
    
    if need_generation "STUDIO_DEFAULT_PROJECT"; then
        update_env_var "STUDIO_DEFAULT_PROJECT" "Default Project"
    fi
    
    if need_generation "SUPABASE_PUBLIC_URL"; then
        update_env_var "SUPABASE_PUBLIC_URL" "http://localhost:8000"
    fi
    
    if need_generation "IMGPROXY_ENABLE_WEBP_DETECTION"; then
        update_env_var "IMGPROXY_ENABLE_WEBP_DETECTION" "true"
    fi
    
    if need_generation "KONG_HTTP_PORT"; then
        update_env_var "KONG_HTTP_PORT" "8000"
    fi
    
    if need_generation "KONG_HTTPS_PORT"; then
        update_env_var "KONG_HTTPS_PORT" "8443"
    fi
    
    # Variables de email/SMTP (valores por defecto)
    if need_generation "SMTP_ADMIN_EMAIL"; then
        update_env_var "SMTP_ADMIN_EMAIL" "admin@yourcompany.com"
    fi
    
    if need_generation "SMTP_HOST"; then
        update_env_var "SMTP_HOST" "smtp.gmail.com"
    fi
    
    if need_generation "SMTP_PORT"; then
        update_env_var "SMTP_PORT" "587"
    fi
    
    if need_generation "SMTP_USER"; then
        update_env_var "SMTP_USER" "your_email@gmail.com"
    fi
    
    if need_generation "SMTP_PASS"; then
        update_env_var "SMTP_PASS" "your_email_password"
    fi
    
    if need_generation "SMTP_SENDER_NAME"; then
        update_env_var "SMTP_SENDER_NAME" "Stack AI Local"
    fi
    
    # Variables de Mailer
    if need_generation "MAILER_URLPATHS_CONFIRMATION"; then
        update_env_var "MAILER_URLPATHS_CONFIRMATION" "/auth/v1/verify"
    fi
    
    if need_generation "MAILER_URLPATHS_INVITE"; then
        update_env_var "MAILER_URLPATHS_INVITE" "/auth/v1/verify"
    fi
    
    if need_generation "MAILER_URLPATHS_RECOVERY"; then
        update_env_var "MAILER_URLPATHS_RECOVERY" "/auth/v1/verify"
    fi
    
    if need_generation "MAILER_URLPATHS_EMAIL_CHANGE"; then
        update_env_var "MAILER_URLPATHS_EMAIL_CHANGE" "/auth/v1/verify"
    fi
    
    # Variables adicionales de configuración
    if need_generation "ENABLE_ANONYMOUS_USERS"; then
        update_env_var "ENABLE_ANONYMOUS_USERS" "false"
    fi
    
    if need_generation "FUNCTIONS_VERIFY_JWT"; then
        update_env_var "FUNCTIONS_VERIFY_JWT" "true"
    fi
    
    # Variables de logging (vacías para evitar warnings)
    if need_generation "LOGFLARE_PUBLIC_ACCESS_TOKEN"; then
        update_env_var "LOGFLARE_PUBLIC_ACCESS_TOKEN" ""
    fi
    
    if need_generation "LOGFLARE_PRIVATE_ACCESS_TOKEN"; then
        update_env_var "LOGFLARE_PRIVATE_ACCESS_TOKEN" ""
    fi
    
    log_success "Valores seguros generados ✅"
    log_info "Variables adicionales configuradas para evitar warnings"
    echo

    # Step 4: Validate configuration
    log_info "Paso 4/6: Validando configuración..."
    
    if python3 start_services.py --validate-only --mode local; then
        log_success "Configuración validada ✅"
    else
        log_error "Error en la validación de la configuración"
        exit 1
    fi
    echo

    # Step 5: Show user credentials
    log_info "Paso 5/6: Credenciales generadas..."
    echo "=================================================================="
    echo "🔑 CREDENCIALES IMPORTANTES - GUÁRDALAS EN UN LUGAR SEGURO"
    echo "=================================================================="
    echo "n8n Admin:"
    echo "  Usuario: $(grep "^N8N_BASIC_AUTH_USER=" .env | cut -d'=' -f2)"
    echo "  Contraseña: $(grep "^N8N_BASIC_AUTH_PASSWORD=" .env | cut -d'=' -f2)"
    echo ""
    echo "Flowise Admin:" 
    echo "  Usuario: $(grep "^FLOWISE_USERNAME=" .env | cut -d'=' -f2)"
    echo "  Contraseña: $(grep "^FLOWISE_PASSWORD=" .env | cut -d'=' -f2)"
    echo ""
    echo "PostgreSQL:"
    echo "  Usuario: postgres"
    echo "  Contraseña: $(grep "^POSTGRES_PASSWORD=" .env | cut -d'=' -f2)"
    echo "=================================================================="
    echo

    # Step 6: Final confirmation
    log_info "Paso 6/6: Confirmación final..."
    echo "Tu entorno está listo para ejecutarse."
    echo ""
    echo "¿Deseas iniciar los servicios ahora? (y/N)"
    read -r start_now
    
    if [[ $start_now =~ ^[Yy]$ ]]; then
        log_info "Iniciando servicios en modo local..."
        python3 start_services.py --mode local
        
        log_success "🎉 ¡Stack AI Local iniciado exitosamente!"
        echo ""
        echo "=================================================================="
        echo "📍 SERVICIOS DISPONIBLES:"
        echo "=================================================================="
        echo "• n8n: http://$(hostname -I | awk '{print $1}'):5678"
        echo "• Open WebUI: http://$(hostname -I | awk '{print $1}'):3000"
        echo "• Flowise: http://$(hostname -I | awk '{print $1}'):3001"
        echo "• Qdrant: http://$(hostname -I | awk '{print $1}'):6333"
        echo "• Supabase: http://$(hostname -I | awk '{print $1}'):8000"
        echo "• SearXNG: http://$(hostname -I | awk '{print $1}'):8080"
        echo ""
        echo "Si estás conectado via SSH, reemplaza $(hostname -I | awk '{print $1}') con la IP de tu servidor"
        echo "=================================================================="
    else
        log_info "Para iniciar los servicios manualmente, ejecuta:"
        echo "  python3 start_services.py --mode local"
    fi
    
    echo ""
    log_success "¡Setup completado exitosamente! 🎉"
}

# Check if script is run from correct directory
if [[ ! -f "start_services.py" ]]; then
    log_error "Este script debe ejecutarse desde el directorio del proyecto."
    log_info "Navega al directorio que contiene start_services.py y ejecuta:"
    echo "  ./setup.sh"
    exit 1
fi

# Run main function
main "$@"
#!/bin/bash

# =============================================================================
# update.sh - Script de actualización simplificado
#
# Basado en el approach de coleam00/local-ai-packaged
# Workflow: down → pull → start_services.py
# =============================================================================

set -e  # Exit on any error

echo "Iniciando actualización de servicios..."
echo "============================================================"

# Function to print colored output
print_status() {
    echo -e "\e[32m[OK] $1\e[0m"
}

print_info() {
    echo -e "\e[34m[INFO] $1\e[0m"
}

print_error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo "Please copy .env.example to .env and configure it:"
    echo "cp .env.example .env"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running!"
    echo "Please start Docker service"
    exit 1
fi

print_info "Deteniendo servicios existentes..."
# Stop all services using the unified project name
docker compose -p localai down 2>/dev/null || {
    print_info "No hay servicios corriendo, continuando..."
}

print_status "Servicios detenidos"

print_info "Actualizando imágenes de contenedores..."
# Pull latest versions of all containers
docker compose -p localai pull

print_status "Imágenes actualizadas"

print_info "Reiniciando servicios..."
# Restart services using the original start script approach
if [ -f "start.sh" ]; then
    ./start.sh
else
    print_error "start.sh not found!"
    echo "Using fallback method with start_services.py..."
    python3 start_services.py --mode cloudflare
fi

print_status "Actualización completada exitosamente!"
echo ""
echo "Todos los servicios han sido actualizados y están corriendo"
echo "============================================================"
echo ""
echo "Para verificar el estado de los servicios:"
echo "   docker ps"
echo ""
echo "Para ver los logs:"
echo "   docker compose -p localai logs -f"
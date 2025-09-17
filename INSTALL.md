# 🚀 Guía de Instalación Rápida

> **Basado en**: [Local AI Packaged](https://github.com/coleam00/local-ai-packaged) por [Cole McDonald](https://github.com/coleam00)

## Verificación Rápida de Prerrequisitos

```bash
# ✅ Verificar que todo esté instalado
docker --version && python3 --version && git --version
```

Si algo falla, instala lo que falte:
- **Linux**: `sudo apt install docker.io python3 git`
- **macOS**: `brew install docker python3 git`
- **Windows**: `choco install docker-desktop python3 git`

## Instalación en 4 Pasos

### 1. Clonar y Preparar
```bash
git clone https://github.com/malaface/local-ai-mejorado.git
cd local-ai-mejorado
cp .env.example .env
```

### 2. Generar Configuración Automáticamente
```bash
# Generar todas las claves seguras de una vez
echo "N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)" >> .env
echo "N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -hex 32)" >> .env
echo "POSTGRES_PASSWORD=$(openssl rand -base64 32)" >> .env
echo "JWT_SECRET=$(openssl rand -hex 32)" >> .env
echo "DASHBOARD_PASSWORD=$(openssl rand -base64 16)" >> .env
echo "FLOWISE_PASSWORD=$(openssl rand -base64 16)" >> .env
echo "POOLER_TENANT_ID=tenant001" >> .env
echo "DASHBOARD_USERNAME=admin" >> .env
echo "FLOWISE_USERNAME=admin" >> .env
```

### 3. Verificar y Iniciar
```bash
# Verificar Docker
docker info

# Iniciar servicios
python3 start_services.py
```

### 4. Verificar Instalación
```bash
# Esperar 1-2 minutos y verificar
docker ps
curl -s http://localhost:5678 && echo "✅ n8n listo"
curl -s http://localhost:3000 && echo "✅ Open WebUI listo"
```

## ✅ Verificar Instalación

Una vez iniciado, verifica que todo funcione:

- **n8n**: http://localhost:5678
- **Open WebUI**: http://localhost:3000
- **Flowise**: http://localhost:3001
- **Qdrant**: http://localhost:6333/dashboard
- **SearXNG**: http://localhost:8080
- **Supabase**: http://localhost:8000

## 🔧 Comandos Útiles

```bash
# Ver estado de servicios
docker ps

# Ver logs
docker logs n8n -f

# Detener todo
docker compose -p localai down

# Actualizar servicios
docker compose -p localai pull
python3 start_services.py
```

## 🛠️ Troubleshooting Rápido

**Puerto ocupado:**
```bash
sudo netstat -tlnp | grep :5678
docker compose -p localai down
```

**Falta Docker Compose:**
```bash
# Linux/Ubuntu
sudo apt install docker-compose-plugin

# O instalar manualmente
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**Permisos:**
```bash
sudo chown -R $USER:$USER .
```

¡Listo! Tu Stack AI Local Mejorado debería estar funcionando.
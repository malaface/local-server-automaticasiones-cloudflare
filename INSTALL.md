# 🚀 Guía de Instalación Rápida

> **Basado en**: [Local AI Packaged](https://github.com/coleam00/local-ai-packaged) por [Cole McDonald](https://github.com/coleam00)

## 🖥️ Instalación para Servidor Remoto (PuTTY/SSH) - RECOMENDADO

### Opción A: Setup Automático (Más Fácil) ⭐

```bash
# 1. Clonar el repositorio
git clone https://github.com/malaface/local-server-automaticasiones-cloudflare.git
cd local-server-automaticasiones-cloudflare

# 2. Ejecutar setup automático
./setup.sh
```

**¡Eso es todo!** El script automático:
- ✅ Verifica todos los requisitos
- ✅ Configura Docker y permisos
- ✅ Genera todas las claves seguras
- ✅ Valida la configuración
- ✅ Inicia los servicios

---

### Opción B: Setup Manual

#### 1. Verificación de Prerrequisitos

```bash
# ✅ Verificar que todo esté instalado
docker --version && python3 --version && git --version
```

Si algo falla, instala lo que falte:
- **Ubuntu/Debian**: `sudo apt update && sudo apt install docker.io python3 git openssl`
- **CentOS/RHEL**: `sudo yum install docker python3 git openssl`
- **Arch Linux**: `sudo pacman -S docker python git openssl`

#### 2. Configurar Docker (Crítico para PuTTY/SSH)

```bash
# Iniciar Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Agregar usuario al grupo docker (IMPORTANTE)
sudo usermod -aG docker $USER

# ⚠️ DEBES CERRAR SESIÓN Y RECONECTARTE VIA SSH/PuTTY
# Los cambios de grupo requieren nueva sesión
exit
```

**Reconéctate a tu servidor via PuTTY/SSH** y verifica:

```bash
# Verificar que puedes usar Docker sin sudo
docker ps
# Si funciona sin pedir contraseña, continúa
```

## 💻 Instalación Local (PC/Laptop)

### Verificación Rápida de Prerrequisitos

```bash
# ✅ Verificar que todo esté instalado  
docker --version && python3 --version && git --version
```

Si algo falla, instala lo que falte:
- **Linux**: `sudo apt install docker.io python3 git`
- **macOS**: `brew install docker python3 git`
- **Windows**: `choco install docker-desktop python3 git`

## 📦 Instalación en 4 Pasos (Manual)

### 1. Clonar y Preparar
```bash
git clone https://github.com/malaface/local-server-automaticasiones-cloudflare.git
cd local-server-automaticasiones-cloudflare
cp .env.example .env
```

### 2. Completar Configuración Mínima
```bash
# Editar .env y agregar tus API keys (OPCIONAL para testing básico)
nano .env

# Cambiar SOLO estas líneas:
# OPENAI_API_KEY=sk-tu_api_key_real_aqui
# ANTHROPIC_API_KEY=sk-ant-tu_api_key_real_aqui

# TODAS las demás variables se generan automáticamente en el siguiente paso
```

### 3. Generar Variables y Validar
```bash
# Opción A: Usar el setup automático (RECOMENDADO)
./setup.sh

# Opción B: Solo generar variables críticas manualmente
echo "POSTGRES_PASSWORD=$(openssl rand -base64 32)" >> .env
echo "JWT_SECRET=$(openssl rand -hex 64)" >> .env
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> .env
echo "DOCKER_SOCKET_LOCATION=/var/run/docker.sock" >> .env

# Luego validar y ejecutar
python3 start_services.py --validate-only
python3 start_services.py --mode local
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

## 🔧 Troubleshooting Específico para Servidores Remotos

### Error: "invalid spec: :/var/run/docker.sock:ro,z: empty section between colons"

**Causa**: Variable `DOCKER_SOCKET_LOCATION` no configurada  
**Solución**:
```bash
echo "DOCKER_SOCKET_LOCATION=/var/run/docker.sock" >> .env
```

### Error: "Command 'docker' returned non-zero exit status 1"

**Causa**: Permisos de Docker incorrectos  
**Solución**:
```bash
# Verificar si estás en el grupo docker
groups $USER | grep docker

# Si no aparece 'docker', agregarte al grupo
sudo usermod -aG docker $USER

# IMPORTANTE: Reconectarte via SSH/PuTTY
exit
# Reconectarse...

# Verificar permisos
docker ps
```

### Error: "docker-compose.override.public.supabase.yml not found"

**Causa**: Archivo faltante (ya solucionado en esta versión)  
**Solución**: El archivo ahora se incluye automáticamente

### Error: Variables de entorno no configuradas

**Causa**: .env incompleto  
**Solución rápida**:
```bash
# Usar el script automático
./setup.sh

# O validar configuración actual
python3 start_services.py --validate-only
```

### Acceso desde PuTTY/SSH a servicios

**Para acceder a servicios desde tu PC local:**

1. **Obtener IP del servidor**:
```bash
hostname -I | awk '{print $1}'
# Ejemplo: 192.168.1.100
```

2. **URLs de acceso**:
- n8n: `http://IP_SERVIDOR:5678`
- Open WebUI: `http://IP_SERVIDOR:3000`  
- Flowise: `http://IP_SERVIDOR:3001`
- Qdrant: `http://IP_SERVIDOR:6333`
- Supabase: `http://IP_SERVIDOR:8000`
- SearXNG: `http://IP_SERVIDOR:8080`

### Firewall en servidor remoto

**Si no puedes acceder desde tu PC:**
```bash
# Ubuntu/Debian
sudo ufw allow 3000:8080/tcp

# CentOS/RHEL
sudo firewall-cmd --add-port=3000-8080/tcp --permanent
sudo firewall-cmd --reload
```

## 🛠️ Troubleshooting General

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

**Verificar logs si algo falla:**
```bash
# Ver logs de servicios específicos
docker logs n8n -f
docker logs open-webui -f

# Ver todos los logs
docker compose -p localai logs -f
```

¡Listo! Tu Stack AI Local Mejorado debería estar funcionando.

## 📞 Soporte Adicional

Si sigues teniendo problemas:

1. **Ejecuta el diagnóstico completo**:
```bash
python3 start_services.py --validate-only
```

2. **Verifica el estado de Docker**:
```bash
docker info
docker ps -a
```

3. **Revisa los logs**:
```bash
docker compose -p localai logs --tail=50
```
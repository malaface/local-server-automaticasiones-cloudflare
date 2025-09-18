# 🚀 Stack AI Local - Cloudflare Tunnel Directo

**Arquitectura Ultra-Simplificada:** `Internet → Cloudflare Tunnel → Docker Services`

Una solución completa de AI local con acceso remoto seguro usando únicamente Cloudflare Tunnel sin proxy intermedio.

## ⚡ ¿Por qué esta arquitectura?

- **🔥 Máxima simplicidad**: Sin Caddy, sin Nginx, solo Cloudflare + Docker
- **⚡ Mejor rendimiento**: Acceso directo a servicios, sin proxy intermedio
- **🔒 Seguridad total**: SSL automático, sin puertos abiertos, protección DDoS
- **🛠️ Fácil expansión**: Agregar servicios = editar 2 archivos

## 🏗️ Arquitectura

```
Internet
   ↓
Cloudflare Tunnel (un solo contenedor)
   ↓
Servicios Docker (acceso directo)
├── n8n.tudominio.com → n8n:5678
├── openwebui.tudominio.com → open-webui:8080
├── flowise.tudominio.com → flowise:3001
├── qdrant.tudominio.com → qdrant:6333
├── supabase.tudominio.com → supabase:3000
└── searxng.tudominio.com → searxng:8080
```

## 🎯 Servicios Incluidos

| Servicio | Descripción | URL de Acceso |
|----------|-------------|---------------|
| **n8n** | Automatización y workflows | https://n8n.tudominio.com |
| **Open WebUI** | Interfaz de chat AI | https://openwebui.tudominio.com |
| **Flowise** | Constructor de agentes AI | https://flowise.tudominio.com |
| **Qdrant** | Base de datos vectorial | https://qdrant.tudominio.com |
| **Supabase** | Backend completo | https://supabase.tudominio.com |
| **SearXNG** | Motor de búsqueda privado | https://searxng.tudominio.com |

## ⚡ Instalación en 3 Pasos

### 1. Configurar Cloudflare Tunnel

1. **Crear Tunnel en Cloudflare Dashboard**:
   - Zero Trust → Networks → Tunnels → Create a tunnel
   - Nombre: `mi-stack-ai`
   - **Anotar**: Tunnel ID y Token

2. **Configurar DNS** (crear estos registros CNAME):
   ```
   n8n.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
   openwebui.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
   flowise.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
   qdrant.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
   supabase.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
   searxng.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
   ```

### 2. Configurar el Stack

```bash
# Clonar repositorio
git clone https://github.com/malaface/local-server-automaticasiones-cloudflare.git
cd local-server-automaticasiones-cloudflare

# Configurar variables
cp .env.example .env
nano .env
```

**Editar `.env` con tu información:**
```bash
TUNNEL_TOKEN=eyJhIjoi...tu_token_real
CLOUDFLARE_DOMAIN=tudominio.com
```

**Editar `config.yml` con tu información:**
```bash
nano config.yml
# Reemplazar:
# - tu-tunnel-id-aqui → TU_TUNNEL_ID_REAL
# - tudominio.com → tu-dominio-real.com
```

### 3. Ejecutar

```bash
# Un solo comando
./start.sh
```

**¡Eso es todo!** En 2-3 minutos tendrás todo funcionando.

## 🎮 Comandos Útiles

```bash
# Ver estado de servicios
docker ps

# Ver logs del tunnel
docker logs -f cloudflared

# Ver logs de un servicio específico
docker logs -f n8n

# Reiniciar todo
docker compose down && docker compose up -d

# Solo reiniciar tunnel (tras cambiar config.yml)
docker restart cloudflared

# Detener todo
docker compose down
```

## 🔧 Agregar Nuevos Servicios

### Paso 1: Agregar al Docker Compose
```yaml
# docker-compose.yml
mi-nuevo-servicio:
  image: imagen/servicio:latest
  restart: unless-stopped
  container_name: mi-nuevo-servicio
  environment:
    - CONFIG=${MI_CONFIG}
```

### Paso 2: Agregar al Tunnel
```yaml
# config.yml
- hostname: mi-servicio.tudominio.com
  service: http://mi-nuevo-servicio:puerto
  originRequest:
    httpHostHeader: mi-servicio.tudominio.com
    noTLSVerify: true
```

### Paso 3: Configurar DNS
```
mi-servicio.tudominio.com → TU-TUNNEL-ID.cfargotunnel.com
```

### Paso 4: Aplicar
```bash
docker compose up -d
docker restart cloudflared
```

**¡Nuevo servicio disponible en https://mi-servicio.tudominio.com!**

## 🛡️ Características de Seguridad

- ✅ **Cero puertos abiertos** en el servidor
- ✅ **SSL automático** via Cloudflare
- ✅ **Protección DDoS** incluida
- ✅ **Filtrado de tráfico** a nivel DNS
- ✅ **Logs de acceso** centralizados
- ✅ **Rate limiting** configurable

## 🚨 Troubleshooting

### Tunnel no conecta
```bash
# Verificar token
grep TUNNEL_TOKEN .env

# Verificar logs
docker logs cloudflared

# Verificar configuración
docker exec cloudflared cloudflared tunnel validate --config /etc/cloudflared/config.yml
```

### Servicio no responde
```bash
# Verificar que está corriendo
docker ps | grep nombre-servicio

# Verificar conectividad interna
docker exec cloudflared ping nombre-servicio

# Verificar logs del servicio
docker logs nombre-servicio
```

### DNS no resuelve
```bash
# Verificar desde el servidor
nslookup servicio.tudominio.com

# Debe apuntar a xxx.cfargotunnel.com
# Si no, revisar configuración DNS en Cloudflare
```

## 📊 Monitoreo

```bash
# Dashboard en tiempo real
docker stats

# Logs unificados
docker compose logs -f

# Métricas del tunnel (opcional)
curl http://localhost:2000/metrics
```

## 🔄 Actualizaciones

```bash
# Actualizar imágenes
docker compose pull

# Aplicar actualizaciones
docker compose down
docker compose up -d

# Limpiar imágenes antiguas
docker image prune -f
```

## 📞 Soporte

### Diagnóstico rápido
```bash
python3 start_services.py --validate-only
```

### Logs importantes
- **Tunnel**: `docker logs cloudflared`
- **Base datos**: `docker logs db`
- **Servicios**: `docker logs [nombre-servicio]`

### Enlaces útiles
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

---

**🎉 ¡Disfruta tu Stack AI Local ultra-simplificado!**

*Máximo rendimiento, mínima complejidad* 🚀
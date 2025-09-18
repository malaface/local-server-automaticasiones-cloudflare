# 🌐 Modo Cloudflare - Acceso Remoto Seguro

## ¿Cuándo usar este modo?
- ✅ Quieres acceso remoto sin abrir puertos
- ✅ No tienes IP pública fija
- ✅ Quieres protección DDoS de Cloudflare
- ✅ Tu ISP bloquea puertos 80/443

## 📋 Requisitos
- Cuenta de Cloudflare (gratuita disponible)
- Dominio en Cloudflare
- Cloudflare Tunnel configurado

## ⚡ Instalación en 5 pasos

### 1. Configurar Cloudflare Tunnel
1. Ve a **Cloudflare Dashboard** → Zero Trust → Networks → Tunnels
2. **Create a tunnel** → Nombre: `mi-stack-ai`
3. **Anotar información**:
   - Tunnel ID: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Token: `eyJhIjoi...muy_largo_token`

### 2. Configurar DNS en Cloudflare
Crear registro CNAME:
```
ai.midominio.com → TU-TUNNEL-ID.cfargotunnel.com
```

### 3. Configurar variables
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar y agregar tu información
nano .env
```

**Variables OBLIGATORIAS:**
- `TUNNEL_TOKEN=eyJhIjoi...` (token del paso 1)
- `CLOUDFLARE_DOMAIN=ai.midominio.com`

### 4. Configurar tunnel
```bash
# Editar configuración del tunnel
nano config.yml

# Reemplazar:
# - tu-tunnel-id-aqui → TU_TUNNEL_ID_REAL
# - tudominio.com → ai.midominio.com
```

### 5. Ejecutar setup
```bash
# Generar variables automáticamente e iniciar
./start.sh
```

## 🌐 Acceso a servicios
Después de 2-3 minutos:

- **Dashboard**: https://ai.midominio.com
- **n8n**: https://ai.midominio.com/n8n
- **Open WebUI**: https://ai.midominio.com/openwebui
- **Flowise**: https://ai.midominio.com/flowise
- **Qdrant**: https://ai.midominio.com/qdrant
- **Supabase**: https://ai.midominio.com/supabase
- **SearXNG**: https://ai.midominio.com/searxng

## 🎮 Comandos útiles

```bash
# Ver estado de servicios
docker ps

# Ver logs del tunnel
docker logs -f cloudflared

# Ver estado del tunnel en Cloudflare
docker exec cloudflared cloudflared tunnel info tu-tunnel-id

# Detener todos los servicios
docker compose down

# Reiniciar solo el tunnel
docker restart cloudflared
```

## 🔧 Troubleshooting

**Tunnel no conecta:**
```bash
# Verificar token
grep TUNNEL_TOKEN .env
# Verificar logs
docker logs cloudflared
# Verificar config
cat config.yml
```

**Dominio no resuelve:**
```bash
# Verificar DNS en Cloudflare
nslookup ai.midominio.com
# Debe apuntar a xxx.cfargotunnel.com
```

**Error 1033 (Argo Tunnel error):**
```bash
# Verificar que el tunnel esté activo en Cloudflare Dashboard
# Regenerar token si es necesario
```

## 🔧 Configuración DNS alternativa

**Subdominios individuales (opcional):**
Si prefieres n8n.midominio.com:

1. Crear múltiples registros CNAME en Cloudflare:
```
n8n.midominio.com → TU-TUNNEL-ID.cfargotunnel.com
openwebui.midominio.com → TU-TUNNEL-ID.cfargotunnel.com
flowise.midominio.com → TU-TUNNEL-ID.cfargotunnel.com
```

2. Cambiar variable:
```bash
CLOUDFLARE_DOMAIN=midominio.com
```

3. Usar config alternativo:
```bash
cp config.subdomains.yml config.yml
```

## 📞 Soporte
- Status tunnel: `docker logs cloudflared`
- Dashboard CF: https://dash.cloudflare.com
- Diagnóstico: `python3 ../../start_services.py --validate-only`

## 💡 Consejos
- El tunnel puede tardar 1-2 minutos en activarse
- Usa el dashboard de Cloudflare para monitorear tráfico
- Los logs del tunnel muestran todas las conexiones
- Puedes pausar/reanudar el tunnel desde Cloudflare Dashboard
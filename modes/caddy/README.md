# 🔐 Modo Caddy - SSL Automático con Dominio

## ¿Cuándo usar este modo?
- ✅ Tienes un servidor con IP pública
- ✅ Tienes tu propio dominio
- ✅ Quieres SSL automático (HTTPS)
- ✅ Prefieres acceso directo sin Cloudflare

## 📋 Requisitos
- Servidor con IP pública
- Dominio propio (ej: `midominio.com`)
- Puertos 80 y 443 abiertos
- DNS configurado hacia tu servidor

## ⚡ Instalación en 4 pasos

### 1. Configurar DNS
Crear registro A en tu proveedor DNS:
```
ai.midominio.com → IP_DE_TU_SERVIDOR
```

### 2. Configurar variables
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar y agregar tu información
nano .env
```

**Variables OBLIGATORIAS:**
- `CLOUDFLARE_DOMAIN=ai.midominio.com`
- `LETSENCRYPT_EMAIL=tu@email.com`
- `OPENAI_API_KEY=sk-tu_key` (opcional)

### 3. Ejecutar setup
```bash
# Generar variables automáticamente e iniciar
./start.sh
```

### 4. Verificar instalación
Espera 2-3 minutos para que SSL se configure y accede a:

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

# Ver logs de Caddy (SSL)
docker logs -f caddy

# Verificar certificados SSL
docker exec caddy caddy list-certificates

# Detener todos los servicios
docker compose down

# Renovar certificados SSL (automático)
docker restart caddy
```

## 🔧 Troubleshooting

**Error SSL/Certificados:**
```bash
# Verificar DNS
nslookup ai.midominio.com
# Verificar puertos
sudo netstat -tlnp | grep -E ":(80|443)"
# Ver logs de Caddy
docker logs caddy
```

**Dominio no resuelve:**
```bash
# Verificar configuración
grep CLOUDFLARE_DOMAIN .env
# Verificar DNS desde servidor
dig ai.midominio.com
```

**Puertos ocupados:**
```bash
# Ver qué usa los puertos
sudo netstat -tlnp | grep -E ":(80|443)"
# Detener otros servicios web si necesario
sudo systemctl stop nginx apache2
```

## 🌐 Configuración DNS alternativa

**Subdominios individuales (opcional):**
Si prefieres n8n.midominio.com en lugar de ai.midominio.com/n8n:

1. Crear registros DNS:
```
n8n.midominio.com → IP_SERVIDOR
openwebui.midominio.com → IP_SERVIDOR
flowise.midominio.com → IP_SERVIDOR
```

2. Cambiar variable:
```bash
CLOUDFLARE_DOMAIN=midominio.com
```

3. Usar Caddyfile alternativo:
```bash
cp Caddyfile.subdomains Caddyfile
```

## 📞 Soporte
- Verificar DNS: `dig ai.midominio.com`
- Logs SSL: `docker logs caddy`
- Diagnóstico: `python3 ../../start_services.py --validate-only`
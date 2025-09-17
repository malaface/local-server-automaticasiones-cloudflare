# Configuración de Cloudflare Tunnel

Este directorio contiene la configuración para Cloudflare Tunnel que permite exponer los servicios de forma segura sin abrir puertos.

## Archivos Necesarios

### 1. `config.yml`
Configuración principal del tunnel. Usa `config.yml.example` como base:

```bash
cp config.yml.example config.yml
# Edita config.yml con tu configuración
```

### 2. `credentials.json`
Archivo de credenciales generado por Cloudflare. Se obtiene al crear el tunnel.

## Configuración Paso a Paso

### 1. Crear el Tunnel en Cloudflare

1. Ve a Cloudflare Dashboard → Zero Trust → Networks → Tunnels
2. Crea un nuevo tunnel
3. Anota el **Tunnel ID** y **Token**
4. Descarga las credenciales (credentials.json)

### 2. Configurar DNS

Para cada servicio, crea un registro CNAME en Cloudflare:

| Nombre | Tipo | Destino |
|--------|------|---------|
| n8n | CNAME | tu-tunnel-id.cfargotunnel.com |
| openwebui | CNAME | tu-tunnel-id.cfargotunnel.com |
| flowise | CNAME | tu-tunnel-id.cfargotunnel.com |
| qdrant | CNAME | tu-tunnel-id.cfargotunnel.com |
| supabase | CNAME | tu-tunnel-id.cfargotunnel.com |
| searxng | CNAME | tu-tunnel-id.cfargotunnel.com |

### 3. Configurar Variables de Entorno

En tu archivo `.env`:

```bash
# Token del tunnel (obligatorio)
TUNNEL_TOKEN=tu_token_de_cloudflare_tunnel

# Tu dominio (obligatorio)
CLOUDFLARE_DOMAIN=tudominio.com

# Email para Let's Encrypt (opcional con Cloudflare)
LETSENCRYPT_EMAIL=tu@email.com
```

### 4. Actualizar config.yml

Edita `cloudflare/config.yml`:

1. Reemplaza `tu-tunnel-id-aqui` con tu Tunnel ID real
2. Reemplaza `tudominio.com` con tu dominio real
3. Asegúrate que `credentials.json` esté en este directorio

### 5. Iniciar el Stack

```bash
# Modo solo Cloudflare
python3 start_services.py --mode cloudflare

# Modo completo (Caddy + Cloudflare)
python3 start_services.py --mode full
```

## Verificación

Una vez configurado, tus servicios estarán disponibles en:

- **n8n**: https://n8n.tudominio.com
- **Open WebUI**: https://openwebui.tudominio.com
- **Flowise**: https://flowise.tudominio.com
- **Qdrant**: https://qdrant.tudominio.com
- **Supabase**: https://supabase.tudominio.com
- **SearXNG**: https://searxng.tudominio.com

## Troubleshooting

### Tunnel no conecta
- Verifica que `TUNNEL_TOKEN` esté correcto
- Revisa que `credentials.json` esté en este directorio
- Verifica los logs: `docker logs cloudflared`

### Servicios no accesibles
- Verifica los registros DNS en Cloudflare
- Revisa que los hostnames en `config.yml` coincidan con los DNS
- Verifica que Caddy esté corriendo: `docker logs caddy`

### SSL/TLS Issues
- Cloudflare maneja SSL automáticamente
- Asegúrate que SSL/TLS esté en "Full" en Cloudflare Dashboard
- Los certificados internos son manejados por Caddy

## Seguridad

✅ **Beneficios del Tunnel:**
- Sin puertos abiertos en tu servidor
- Protección DDoS automática de Cloudflare
- SSL/TLS automático
- Autenticación Zero Trust opcional

⚠️ **Consideraciones:**
- Todo el tráfico pasa por Cloudflare
- Requiere cuenta de Cloudflare (gratuita disponible)
- Dependencia de servicios externos
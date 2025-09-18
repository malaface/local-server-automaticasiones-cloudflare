# 🚀 Stack AI Local - Organizado por Modos

Una solución completa de AI local con tres modos de despliegue organizados en carpetas separadas para máxima simplicidad.

## 🎯 ¿Qué modo elegir?

### 🏠 **Modo Local** - `modes/local/`
**Ideal para:** Desarrollo y testing en tu PC
- ✅ Setup más simple (5 minutos)
- ✅ Sin configuración de dominios
- ✅ Acceso directo por puertos
- ❌ Solo accesible localmente

### 🔐 **Modo Caddy** - `modes/caddy/`
**Ideal para:** Servidor propio con dominio
- ✅ SSL automático (HTTPS)
- ✅ Acceso con dominio personalizado
- ✅ Sin dependencias externas
- ⚠️ Requiere dominio y puertos 80/443 abiertos

### 🌐 **Modo Cloudflare** - `modes/cloudflare/`
**Ideal para:** Acceso remoto sin abrir puertos
- ✅ Sin puertos abiertos necesarios
- ✅ Protección DDoS incluida
- ✅ Funciona detrás de NAT/firewall
- ⚠️ Requiere cuenta de Cloudflare

## ⚡ Instalación Rápida

1. **Elige tu modo** y ve a su carpeta:
   ```bash
   cd modes/local/     # Para desarrollo local
   cd modes/caddy/     # Para servidor con dominio
   cd modes/cloudflare/ # Para acceso remoto
   ```

2. **Sigue el README** de esa carpeta (20-30 líneas)

3. **Ejecuta el script**:
   ```bash
   ./start.sh
   ```

¡Eso es todo! Cada modo tiene su propio README con instrucciones específicas y concisas.

## 🛠️ Servicios Incluidos

| Servicio | Descripción | Puerto Local |
|----------|-------------|--------------|
| **n8n** | Automatización y workflows | 5678 |
| **Open WebUI** | Interfaz de chat AI | 3000 |
| **Flowise** | Constructor de agentes AI | 3001 |
| **Qdrant** | Base de datos vectorial | 6333 |
| **Supabase** | Backend completo | 8000 |
| **SearXNG** | Motor de búsqueda privado | 8080 |

## 📞 Soporte

¿Problemas? Cada modo tiene su sección de troubleshooting en su README específico.

**Diagnóstico general:**
```bash
python3 start_services.py --validate-only
docker ps
docker logs [nombre-servicio]
```

---

**¡Disfruta tu stack de AI local simplificado! 🚀**
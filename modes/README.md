# 📁 Modos de Despliegue

Esta carpeta contiene los tres modos de despliegue organizados para máxima simplicidad.

## 🎯 Elige tu modo según tu necesidad:

### 🏠 [**local/**](local/) - Desarrollo y Testing
- **Tiempo setup:** 5 minutos
- **Complejidad:** ⭐ Muy fácil
- **Acceso:** Solo local (localhost:puerto)
- **Ideal para:** Desarrollo, experimentación, aprendizaje

### 🔐 [**caddy/**](caddy/) - Servidor con Dominio
- **Tiempo setup:** 10 minutos
- **Complejidad:** ⭐⭐ Fácil
- **Acceso:** https://ai.tudominio.com
- **Ideal para:** Servidor propio, equipo pequeño, uso personal

### 🌐 [**cloudflare/**](cloudflare/) - Acceso Remoto Seguro
- **Tiempo setup:** 15 minutos
- **Complejidad:** ⭐⭐⭐ Moderado
- **Acceso:** https://ai.tudominio.com (sin puertos abiertos)
- **Ideal para:** Trabajo remoto, servidor doméstico, máxima seguridad

## 📋 Cada carpeta contiene:
- `README.md` - Guía específica del modo (20-30 líneas)
- `docker-compose.yml` - Configuración específica
- `.env.example` - Variables necesarias
- `start.sh` - Script todo-en-uno
- Archivos de configuración específicos

## 🚀 Uso rápido:
```bash
cd local/     # o caddy/ o cloudflare/
./start.sh    # ¡Un solo comando!
```

---
**💡 Consejo:** Empieza con `local/` para familiarizarte, luego migra a `caddy/` o `cloudflare/` según necesites.
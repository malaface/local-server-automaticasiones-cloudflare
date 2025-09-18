# 🏠 Modo Local - Desarrollo y Testing

## ¿Cuándo usar este modo?
- ✅ Desarrollo local en tu PC/laptop
- ✅ Testing y experimentación
- ✅ No necesitas acceso remoto
- ✅ Setup más simple y rápido

## 📋 Requisitos
- Docker y Docker Compose
- Python 3.8+
- 8GB+ RAM recomendado

## ⚡ Instalación en 3 pasos

### 1. Configurar variables
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar y agregar tus API keys (opcional para testing)
nano .env
```

**Variables mínimas requeridas:**
- `POSTGRES_PASSWORD` - Se genera automáticamente
- `JWT_SECRET` - Se genera automáticamente
- `OPENAI_API_KEY` - Tu API key (opcional)
- `ANTHROPIC_API_KEY` - Tu API key (opcional)

### 2. Ejecutar setup
```bash
# Generar variables automáticamente e iniciar
./start.sh
```

### 3. Verificar instalación
Espera 1-2 minutos y accede a:

- **n8n**: http://localhost:5678
- **Open WebUI**: http://localhost:3000
- **Flowise**: http://localhost:3001
- **Qdrant**: http://localhost:6333
- **Supabase**: http://localhost:8000
- **SearXNG**: http://localhost:8080

## 🎮 Comandos útiles

```bash
# Ver estado de servicios
docker ps

# Ver logs de un servicio
docker logs -f n8n

# Detener todos los servicios
docker compose down

# Reiniciar un servicio específico
docker restart open-webui

# Actualizar servicios
docker compose pull && docker compose up -d
```

## 🔧 Troubleshooting

**Puerto ocupado:**
```bash
# Ver qué usa el puerto
sudo netstat -tlnp | grep :3000
# Detener servicios si necesario
docker compose down
```

**Variables no configuradas:**
```bash
# Verificar archivo .env
cat .env | grep -v "^#" | grep -v "^$"
# Regenerar si necesario
./start.sh
```

**No puedo acceder a los servicios:**
- Verifica que Docker esté ejecutándose: `docker ps`
- Espera 1-2 minutos después de iniciar
- Verifica que no haya otros servicios usando los puertos

## 📞 Soporte
Si tienes problemas, ejecuta: `python3 ../../start_services.py --validate-only`
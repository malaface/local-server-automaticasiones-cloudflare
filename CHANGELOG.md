# 📝 Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

## [1.0.0] - 2025-01-17

### ✨ Nuevo
- Stack AI Local completamente optimizado y simplificado basado en [Local AI Packaged](https://github.com/coleam00/local-ai-packaged)
- Solo 8 servicios esenciales (eliminado bloatware)
- Configuración automática de Supabase
- Scripts de inicio automatizados
- Soporte para modos privado y público
- Documentación completa en español

### 🙏 Créditos
- Basado en el excelente trabajo de [Cole McDonald](https://github.com/coleam00) en [local-ai-packaged](https://github.com/coleam00/local-ai-packaged)
- Optimizado y simplificado para casos de uso específicos

### 🛠️ Servicios Incluidos
- **n8n** - Automatización y workflows
- **Supabase** - Backend completo con PostgreSQL
- **Open WebUI** - Interfaz de chat AI
- **Flowise** - Constructor de agentes AI
- **Qdrant** - Base de datos vectorial
- **SearXNG** - Motor de búsqueda privado
- **Redis/Valkey** - Cache y colas
- **PostgreSQL** - Base de datos (vía Supabase)

### 🔧 Características
- Instalación en 3 pasos simples
- Configuración con archivo `.env` simplificado
- Workflows RAG preconfigurados
- Acceso localhost seguro por defecto
- Soporte para deployment en producción

### 📖 Documentación
- README completo en español
- Guía de instalación rápida
- Troubleshooting detallado
- Ejemplos de configuración
- Comandos útiles de administración

### 🚫 Eliminado (vs versión original)
- Ollama (LLM local) - simplifica stack
- Neo4j - no esencial para casos básicos
- Langfuse - observabilidad opcional
- ClickHouse - no necesario sin Langfuse
- MinIO - no necesario sin Langfuse
- Caddy - acceso directo por puertos
- Configuraciones GPU complejas

### 🔒 Seguridad
- Servicios expuestos solo en localhost por defecto
- Modo público que cierra todos los puertos externos
- Variables de entorno simplificadas
- Configuración segura por defecto

### 📁 Estructura
```
local-ai-mejorado/
├── docker-compose.yml
├── docker-compose.override.private.yml
├── docker-compose.override.public.yml
├── start_services.py
├── .env.example
├── README.md
├── INSTALL.md
├── CHANGELOG.md
├── LICENSE
├── .gitignore
├── n8n/backup/
├── shared/
└── searxng/
```

### 🎯 Casos de Uso Optimizados
- Desarrollo de agentes AI locales
- Aplicaciones RAG (Retrieval Augmented Generation)
- Workflows de automatización con IA
- Prototipado rápido de soluciones AI
- Learning y experimentación con IA local

### 🚀 Rendimiento
- Tiempo de inicio reducido (sin servicios innecesarios)
- Menor uso de memoria y CPU
- Configuración más simple y mantenible
- Menos puntos de falla

---

## [Próximas Versiones]

### 🔮 Planificado
- [ ] Integración opcional con Ollama
- [ ] Templates de workflows adicionales
- [ ] Guías de integración con APIs externas
- [ ] Docker Compose para ARM64
- [ ] Scripts de backup automatizados
- [ ] Métricas de monitoreo opcionales

---

**Formato basado en [Keep a Changelog](https://keepachangelog.com/)**
# 🚀 Stack AI Local Mejorado con Cloudflare

Una solución completa y optimizada para ejecutar un stack de AI local con múltiples opciones de deployment, incluyendo soporte para Cloudflare Tunnel para acceso seguro remoto.

> **Basado en**: [Local AI Packaged](https://github.com/coleam00/local-ai-packaged) por [Cole McDonald](https://github.com/coleam00)
> Esta versión incluye integración con Cloudflare Tunnel y múltiples modos de deployment.

## 🌟 Características

- **🧠 Stack AI Completo**: n8n, Open WebUI, Flowise, Qdrant, SearXNG, Supabase
- **🔄 4 Modos de Deployment**: Local, Caddy, Cloudflare, Full
- **🔒 SSL Automático**: Con Caddy y Let's Encrypt
- **🌐 Acceso Remoto Seguro**: Con Cloudflare Tunnel
- **📦 Setup Automático**: Script Python todo-en-uno
- **🛡️ Configuración de Seguridad**: Headers y políticas optimizadas

## 📋 Tabla de Contenidos

- [Servicios Incluidos](#-servicios-incluidos)
- [Modos de Deployment](#-modos-de-deployment)
- [Requisitos](#-requisitos)
- [Instalación Rápida](#-instalación-rápida)
- [Guías por Modo](#-guías-por-modo)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [Troubleshooting](#-troubleshooting)
- [Contribuir](#-contribuir)

## 🛠️ Servicios Incluidos

| Servicio | Descripción | Puerto Local | URL con Dominio |
|----------|-------------|--------------|----------------|
| **n8n** | Automatización y workflows | 5678 | n8n.tudominio.com |
| **Open WebUI** | Interfaz de chat AI moderna | 3000 | openwebui.tudominio.com |
| **Flowise** | Constructor visual de agentes AI | 3001 | flowise.tudominio.com |
| **Qdrant** | Base de datos vectorial para RAG | 6333 | qdrant.tudominio.com |
| **Supabase** | Backend as a Service completo | 8000 | supabase.tudominio.com |
| **SearXNG** | Motor de búsqueda privado | 8080 | searxng.tudominio.com |
| **PostgreSQL** | Base de datos principal | 5432 | (interno) |
| **Redis** | Cache y cola de mensajes | 6379 | (interno) |

## 🎯 Modos de Deployment

### 1. 🏠 Modo Local
**Ideal para**: Desarrollo local y testing
- ✅ Setup más simple
- ✅ Sin configuración de DNS
- ✅ Acceso directo por puertos
- ❌ Solo accesible localmente

### 2. 🔐 Modo Caddy
**Ideal para**: Deployment en servidor propio con dominio
- ✅ SSL automático con Let's Encrypt
- ✅ Reverse proxy optimizado
- ✅ Headers de seguridad
- ⚠️ Requiere dominio y puertos 80/443 abiertos

### 3. 🌐 Modo Cloudflare
**Ideal para**: Acceso remoto sin abrir puertos
- ✅ Sin puertos abiertos en el servidor
- ✅ Protección DDoS de Cloudflare
- ✅ SSL automático
- ⚠️ Requiere cuenta de Cloudflare

### 4. 🚀 Modo Full
**Ideal para**: Máxima flexibilidad y rendimiento
- ✅ Combina Caddy + Cloudflare
- ✅ Redundancia y flexibilidad
- ✅ Acceso local + remoto
- ⚠️ Configuración más compleja

## 📋 Requisitos

### Requisitos Básicos
- **Docker**: v20.10+
- **Docker Compose**: v2.0+
- **Python**: 3.8+
- **Sistema**: Linux, macOS, Windows con WSL2
- **RAM**: 8GB+ recomendado
- **Almacenamiento**: 20GB+ libres

### Requisitos por Modo

#### Modo Local
- Solo requisitos básicos

#### Modo Caddy
- Dominio propio
- Puertos 80 y 443 abiertos
- DNS apuntando al servidor

#### Modo Cloudflare
- Cuenta de Cloudflare (gratuita disponible)
- Dominio en Cloudflare
- Tunnel configurado

#### Modo Full
- Todos los anteriores

## ⚡ Instalación Rápida

### 1. Clonar y Preparar
```bash
# Clonar el repositorio
git clone https://github.com/malaface/local-server-automaticasiones-cloudflare.git
cd local-server-automaticasiones-cloudflare

# Crear archivo de configuración
cp .env.example .env
```

### 2. Configurar Variables
```bash
# Editar configuración básica
nano .env

# Variables mínimas requeridas:
POSTGRES_PASSWORD=tu_password_seguro
JWT_SECRET=tu_jwt_secret_de_32_caracteres_minimo
OPENAI_API_KEY=sk-tu_api_key_aqui
```

### 3. Ejecutar
```bash
# Modo local (más simple)
python3 start_services.py --mode local

# Otros modos
python3 start_services.py --mode caddy
python3 start_services.py --mode cloudflare
python3 start_services.py --mode full
```

## 📖 Guías por Modo

### 🏠 Guía: Modo Local

El modo más simple para desarrollo y testing local.

#### Configuración
1. **Variables mínimas en `.env`**:
```bash
POSTGRES_PASSWORD=mi_password_seguro
JWT_SECRET=mi_jwt_secret_de_al_menos_32_caracteres
OPENAI_API_KEY=sk-mi_api_key_de_openai
ANTHROPIC_API_KEY=sk-ant-mi_api_key_de_claude
```

2. **Iniciar servicios**:
```bash
python3 start_services.py --mode local
```

#### Acceso a Servicios
- **n8n**: http://localhost:5678
- **Open WebUI**: http://localhost:3000
- **Flowise**: http://localhost:3001
- **Qdrant**: http://localhost:6333
- **Supabase**: http://localhost:8000
- **SearXNG**: http://localhost:8080

---

### 🔐 Guía: Modo Caddy

Para deployment en servidor con dominio propio y SSL automático.

#### Prerequisitos
1. **Servidor con IP pública**
2. **Dominio propio** (ej: `midominio.com`)
3. **DNS configurado** apuntando al servidor
4. **Puertos abiertos**: 80, 443

#### 🎯 Opciones de Dominio: Subdominios vs Dominios Dedicados

Tienes varias opciones para configurar tus dominios. Aquí te explico las ventajas y desventajas de cada enfoque:

##### **Opción 1: Subdominios de tu Dominio Principal** ⭐ **RECOMENDADO**
```
ai.tudominio.com/n8n          → n8n
ai.tudominio.com/openwebui    → Open WebUI
ai.tudominio.com/flowise      → Flowise
ai.tudominio.com/qdrant       → Qdrant
ai.tudominio.com/supabase     → Supabase
ai.tudominio.com/searxng      → SearXNG
```

**✅ Ventajas:**
- **Un solo certificado SSL** para ai.tudominio.com
- **Gestión DNS simplificada** (solo un registro A)
- **Menor costo** (no necesitas subdominios adicionales)
- **Organización clara** bajo una ruta principal
- **Fácil de recordar** y gestionar

**⚠️ Consideraciones:**
- URLs ligeramente más largas
- Requiere configuración de rutas en Caddy

##### **Opción 2: Subdominios Individuales**
```
n8n.tudominio.com      → n8n
openwebui.tudominio.com → Open WebUI
flowise.tudominio.com   → Flowise
qdrant.tudominio.com    → Qdrant
supabase.tudominio.com  → Supabase
searxng.tudominio.com   → SearXNG
```

**✅ Ventajas:**
- **URLs más limpias** y profesionales
- **Certificados SSL individuales** (mayor aislamiento)
- **Fácil escalabilidad** para diferentes servidores
- **Configuración independiente** por servicio

**⚠️ Consideraciones:**
- **6 registros DNS** que gestionar
- **6 certificados SSL** que renovar
- **Mayor complejidad** de configuración inicial

##### **Opción 3: Dominio Dedicado para AI**
```
n8n.ai-stack.com      → n8n
openwebui.ai-stack.com → Open WebUI
flowise.ai-stack.com   → Flowise
```

**✅ Ventajas:**
- **Separación total** del dominio principal
- **Branding específico** para servicios AI
- **Flexibilidad máxima** de configuración

**⚠️ Consideraciones:**
- **Costo adicional** del dominio
- **Gestión de dos dominios** diferentes

#### 🏆 **Recomendación Final: Subdominios con Rutas**

**Para la mayoría de usuarios, recomiendo la Opción 1** por las siguientes razones:

1. **🎯 Simplicidad Operacional**:
   - Solo necesitas gestionar `ai.tudominio.com` en tu DNS
   - Un solo certificado SSL que renovar
   - Configuración más simple de firewall y proxies

2. **💰 Costo-Eficiencia**:
   - No requiere subdominios adicionales en algunos proveedores DNS
   - Menor overhead de certificados SSL
   - Una sola configuración de Cloudflare si usas ese modo

3. **🔒 Seguridad Centralizada**:
   - Todas las rutas bajo un mismo dominio facilita políticas de seguridad
   - Headers de seguridad unificados
   - Más fácil implementar autenticación centralizada si es necesario

4. **🚀 Escalabilidad**:
   - Fácil agregar nuevos servicios como `ai.tudominio.com/nuevo-servicio`
   - No necesitas configurar DNS cada vez que agregues un servicio
   - Migración más simple entre servidores

#### Configuración DNS

##### **Para Opción 1 (Recomendado): Subdominio con Rutas**
Crear un solo registro A:
```
ai.midominio.com → IP_DEL_SERVIDOR
```

##### **Para Opción 2: Subdominios Individuales**
Crear registros A para cada subdominio:
```
n8n.midominio.com      → IP_DEL_SERVIDOR
openwebui.midominio.com → IP_DEL_SERVIDOR
flowise.midominio.com  → IP_DEL_SERVIDOR
qdrant.midominio.com   → IP_DEL_SERVIDOR
supabase.midominio.com → IP_DEL_SERVIDOR
searxng.midominio.com  → IP_DEL_SERVIDOR
```

**Usando comodín (wildcard) - Alternativa avanzada:**
```
*.midominio.com → IP_DEL_SERVIDOR
```
⚠️ *Solo recomendado si tienes control total del dominio*

#### Configuración

##### **Para Opción 1 (Recomendado): Subdominio con Rutas**

1. **Variables en `.env`**:
```bash
# Variables básicas
POSTGRES_PASSWORD=mi_password_seguro
JWT_SECRET=mi_jwt_secret_de_al_menos_32_caracteres

# Variables específicas para Caddy - IMPORTANTE: usar subdominio
CLOUDFLARE_DOMAIN=ai.midominio.com
LETSENCRYPT_EMAIL=mi@email.com

# APIs
OPENAI_API_KEY=sk-mi_api_key
```

2. **Usar Caddyfile con rutas**:
```bash
# Copiar el Caddyfile optimizado para rutas
cp Caddyfile.routes Caddyfile
```

3. **Iniciar servicios**:
```bash
python3 start_services.py --mode caddy
```

**🎯 Acceso a Servicios:**
- **Dashboard**: https://ai.midominio.com
- **n8n**: https://ai.midominio.com/n8n
- **Open WebUI**: https://ai.midominio.com/openwebui
- **Flowise**: https://ai.midominio.com/flowise
- **Qdrant**: https://ai.midominio.com/qdrant
- **Supabase**: https://ai.midominio.com/supabase
- **SearXNG**: https://ai.midominio.com/searxng

##### **Para Opción 2: Subdominios Individuales**

1. **Variables en `.env`**:
```bash
# Variables básicas
POSTGRES_PASSWORD=mi_password_seguro
JWT_SECRET=mi_jwt_secret_de_al_menos_32_caracteres

# Variables específicas para Caddy - IMPORTANTE: dominio base
CLOUDFLARE_DOMAIN=midominio.com
LETSENCRYPT_EMAIL=mi@email.com

# APIs
OPENAI_API_KEY=sk-mi_api_key
```

2. **Usar Caddyfile estándar**:
```bash
# El Caddyfile por defecto ya está configurado para subdominios
# No necesitas cambiar nada
```

3. **Iniciar servicios**:
```bash
python3 start_services.py --mode caddy
```

**🎯 Acceso a Servicios:**
- **n8n**: https://n8n.midominio.com
- **Open WebUI**: https://openwebui.midominio.com
- **Flowise**: https://flowise.midominio.com
- **Qdrant**: https://qdrant.midominio.com
- **Supabase**: https://supabase.midominio.com
- **SearXNG**: https://searxng.midominio.com

---

### 🌐 Guía: Modo Cloudflare

Para acceso remoto seguro sin abrir puertos usando Cloudflare Tunnel.

#### Prerequisitos
1. **Cuenta de Cloudflare** (gratuita disponible)
2. **Dominio en Cloudflare**
3. **Cloudflare Tunnel creado**

#### Paso 1: Crear Tunnel en Cloudflare
1. **Ir a Cloudflare Dashboard**
   - Zero Trust → Networks → Tunnels
   - Create a tunnel
   - Nombre: `mi-stack-ai`

2. **Anotar información**:
   - **Tunnel ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - **Token**: `muy_largo_token_aqui`

3. **Descargar credenciales**:
   - Descargar `credentials.json`
   - Guardar en `cloudflare/credentials.json`

#### Paso 2: Configurar DNS en Cloudflare

##### **Opción 1 (Recomendado): Subdominio con Rutas**
Crear un solo registro CNAME:

| Nombre | Tipo | Destino |
|--------|------|---------|
| ai | CNAME | TU-TUNNEL-ID.cfargotunnel.com |

**Ventajas**: Un solo registro DNS, configuración más simple, menor mantenimiento.

##### **Opción 2: Subdominios Individuales**
Crear registros CNAME para cada servicio:

| Nombre | Tipo | Destino |
|--------|------|---------|
| n8n | CNAME | TU-TUNNEL-ID.cfargotunnel.com |
| openwebui | CNAME | TU-TUNNEL-ID.cfargotunnel.com |
| flowise | CNAME | TU-TUNNEL-ID.cfargotunnel.com |
| qdrant | CNAME | TU-TUNNEL-ID.cfargotunnel.com |
| supabase | CNAME | TU-TUNNEL-ID.cfargotunnel.com |
| searxng | CNAME | TU-TUNNEL-ID.cfargotunnel.com |

**Nota**: Para ambas opciones, el tunnel apunta al mismo lugar. La diferencia está en cómo Caddy maneja las rutas internamente.

#### Paso 3: Configurar Variables

##### **Para Opción 1 (Recomendado): Subdominio con Rutas**
1. **Variables en `.env`**:
```bash
# Variables básicas
POSTGRES_PASSWORD=mi_password_seguro
JWT_SECRET=mi_jwt_secret_de_al_menos_32_caracteres

# Variables específicas para Cloudflare - IMPORTANTE: usar subdominio
TUNNEL_TOKEN=tu_token_de_cloudflare_tunnel
CLOUDFLARE_DOMAIN=ai.midominio.com

# APIs
OPENAI_API_KEY=sk-mi_api_key
```

2. **Configurar tunnel**:
```bash
# Copiar y editar configuración
cp cloudflare/config.yml.example cloudflare/config.yml
nano cloudflare/config.yml

# Reemplazar:
# - tu-tunnel-id-aqui → TU_TUNNEL_ID_REAL
# - tudominio.com → ai.midominio.com
```

3. **Usar Caddyfile con rutas**:
```bash
# Copiar el Caddyfile optimizado para rutas
cp Caddyfile.routes Caddyfile
```

##### **Para Opción 2: Subdominios Individuales**
1. **Variables en `.env`**:
```bash
# Variables básicas
POSTGRES_PASSWORD=mi_password_seguro
JWT_SECRET=mi_jwt_secret_de_al_menos_32_caracteres

# Variables específicas para Cloudflare - IMPORTANTE: dominio base
TUNNEL_TOKEN=tu_token_de_cloudflare_tunnel
CLOUDFLARE_DOMAIN=midominio.com

# APIs
OPENAI_API_KEY=sk-mi_api_key
```

2. **Configurar tunnel**:
```bash
# Copiar y editar configuración
cp cloudflare/config.yml.example cloudflare/config.yml
nano cloudflare/config.yml

# Reemplazar:
# - tu-tunnel-id-aqui → TU_TUNNEL_ID_REAL
# - tudominio.com → midominio.com
```

#### Paso 4: Iniciar Servicios
```bash
python3 start_services.py --mode cloudflare
```

#### 🎯 Acceso a Servicios

##### **Opción 1 (Subdominio con Rutas)**:
- **Dashboard**: https://ai.midominio.com
- **n8n**: https://ai.midominio.com/n8n
- **Open WebUI**: https://ai.midominio.com/openwebui
- **Flowise**: https://ai.midominio.com/flowise
- **Qdrant**: https://ai.midominio.com/qdrant
- **Supabase**: https://ai.midominio.com/supabase
- **SearXNG**: https://ai.midominio.com/searxng

##### **Opción 2 (Subdominios Individuales)**:
- **n8n**: https://n8n.midominio.com
- **Open WebUI**: https://openwebui.midominio.com
- **Flowise**: https://flowise.midominio.com
- **Qdrant**: https://qdrant.midominio.com
- **Supabase**: https://supabase.midominio.com
- **SearXNG**: https://searxng.midominio.com

---

### 🚀 Guía: Modo Full

Combina Caddy + Cloudflare para máxima flexibilidad.

#### ¿Cuándo usar Modo Full?
- Necesitas acceso tanto local como remoto
- Quieres redundancia en el acceso
- Planeas migrar entre modos
- Necesitas máximo rendimiento y flexibilidad

#### Configuración
1. **Seguir AMBAS guías**:
   - Configuración de Modo Caddy
   - Configuración de Modo Cloudflare

2. **Variables en `.env`**:
```bash
# Variables básicas
POSTGRES_PASSWORD=mi_password_seguro
JWT_SECRET=mi_jwt_secret_de_al_menos_32_caracteres

# Variables para Caddy
CLOUDFLARE_DOMAIN=midominio.com
LETSENCRYPT_EMAIL=mi@email.com

# Variables para Cloudflare
TUNNEL_TOKEN=tu_token_de_cloudflare_tunnel

# APIs
OPENAI_API_KEY=sk-mi_api_key
```

3. **Iniciar servicios**:
```bash
python3 start_services.py --mode full
```

#### Opciones de Acceso
- **Vía Caddy**: https://servicio.midominio.com (directo al servidor)
- **Vía Cloudflare**: https://servicio.midominio.com (a través de tunnel)
- **Local**: http://localhost:puerto (solo desde servidor)

## ⚙️ Configuración

### Archivo .env
El archivo `.env` contiene todas las configuraciones. Consulta `.env.example` para ver todas las opciones disponibles.

#### Variables Críticas
```bash
# Seguridad (OBLIGATORIAS)
POSTGRES_PASSWORD=password_muy_seguro_aqui
JWT_SECRET=jwt_secret_de_al_menos_32_caracteres

# APIs (Recomendadas)
OPENAI_API_KEY=sk-tu_api_key_openai
ANTHROPIC_API_KEY=sk-ant-tu_api_key_claude

# Dominio (Para Caddy/Cloudflare/Full)
CLOUDFLARE_DOMAIN=tudominio.com
LETSENCRYPT_EMAIL=tu@email.com

# Cloudflare (Para Cloudflare/Full)
TUNNEL_TOKEN=tu_token_cloudflare
```

### Configuración Avanzada

#### Personalizar Puertos
```bash
# En modo local, puedes cambiar puertos externos
N8N_PORT_EXTERNAL=5678
OPENWEBUI_PORT_EXTERNAL=3000
FLOWISE_PORT_EXTERNAL=3001
```

#### Configuración de Servicios
```bash
# n8n
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=tu_password

# Flowise
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=tu_password

# Qdrant
QDRANT_API_KEY=tu_api_key_qdrant
```

## 🎯 Mejores Prácticas y Recomendaciones

### 🏆 Resumen de Recomendaciones por Caso de Uso

#### **Para Desarrollo Local**
- **Modo**: `local`
- **Configuración**: Mínima, solo variables básicas
- **Ventajas**: Setup rápido, sin complejidad de DNS/SSL
- **Ideal para**: Desarrollo, testing, aprendizaje

#### **Para Servidor Personal/Pequeña Empresa**
- **Modo**: `caddy` con **subdominios + rutas** (ai.midominio.com/servicio)
- **Configuración DNS**: Un solo registro A
- **Ventajas**: SSL automático, gestión simplificada, costo-eficiente
- **Ideal para**: Uso personal, equipos pequeños, presupuesto limitado

#### **Para Acceso Remoto sin VPS Propio**
- **Modo**: `cloudflare` con **subdominios + rutas**
- **Configuración**: Cloudflare Tunnel + un registro CNAME
- **Ventajas**: Sin puertos abiertos, protección DDoS, SSL incluido
- **Ideal para**: Trabajo remoto, servidores domésticos, equipos distribuidos

#### **Para Empresas/Producción**
- **Modo**: `full` con **subdominios individuales**
- **Configuración**: Ambos métodos disponibles para redundancia
- **Ventajas**: Máxima flexibilidad, escalabilidad, opciones de failover
- **Ideal para**: Entornos de producción, equipos grandes, alta disponibilidad

### 🎭 Comparativa Detallada: Subdominios vs Rutas

| Aspecto | Subdominios + Rutas | Subdominios Individuales |
|---------|---------------------|---------------------------|
| **DNS Records** | 1 registro | 6+ registros |
| **SSL Certificates** | 1 certificado | 6+ certificados |
| **Gestión** | ⭐⭐⭐⭐⭐ Muy Simple | ⭐⭐⭐ Moderada |
| **Escalabilidad** | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐ Buena |
| **URLs** | ai.domain.com/n8n | n8n.domain.com |
| **Aislamiento** | ⭐⭐⭐ Bueno | ⭐⭐⭐⭐⭐ Excelente |
| **Costo DNS** | ⭐⭐⭐⭐⭐ Mínimo | ⭐⭐⭐ Variable |
| **Configuración Firewall** | ⭐⭐⭐⭐⭐ Simple | ⭐⭐⭐ Más complejo |
| **Backup/Migración** | ⭐⭐⭐⭐⭐ Muy fácil | ⭐⭐⭐ Moderado |

### 💡 Recomendaciones Específicas

#### **🎯 Elige Subdominios + Rutas si:**
- ✅ Eres nuevo en administración de servidores
- ✅ Tienes presupuesto limitado para DNS
- ✅ Quieres configuración simple y rápida
- ✅ Planeas agregar más servicios en el futuro
- ✅ Trabajas en un equipo pequeño (1-5 personas)
- ✅ Prefieres mantener todo centralizado

#### **🎯 Elige Subdominios Individuales si:**
- ✅ Tienes experiencia en administración de sistemas
- ✅ Necesitas máximo aislamiento entre servicios
- ✅ Planeas distribuir servicios en diferentes servidores
- ✅ Trabajas en entorno empresarial/producción
- ✅ Requieres certificates SSL por separado
- ✅ Tienes políticas de seguridad estrictas

### 🚀 Estrategia de Migración Recomendada

#### **Fase 1: Desarrollo** (Semanas 1-2)
```bash
# Comenzar en modo local para familiarizarse
python3 start_services.py --mode local
```

#### **Fase 2: Testing** (Semanas 3-4)
```bash
# Migrar a Caddy con rutas para probar SSL y dominios
cp Caddyfile.routes Caddyfile
python3 start_services.py --mode caddy
```

#### **Fase 3: Producción** (Mes 2+)
```bash
# Agregar Cloudflare para seguridad adicional
python3 start_services.py --mode full
```

### 🔧 Configuraciones Recomendadas por Entorno

#### **🏠 Hogar/Personal**
```bash
# .env
CLOUDFLARE_DOMAIN=ai.midominio.com
LETSENCRYPT_EMAIL=mi@email.com

# Comando
python3 start_services.py --mode caddy
```

#### **🏢 Oficina/Empresa**
```bash
# .env
CLOUDFLARE_DOMAIN=midominio.com
TUNNEL_TOKEN=token_empresa
LETSENCRYPT_EMAIL=admin@empresa.com

# Comando
python3 start_services.py --mode full
```

#### **☁️ Servidor VPS**
```bash
# .env
CLOUDFLARE_DOMAIN=ai.miempresa.com
TUNNEL_TOKEN=token_seguro
LETSENCRYPT_EMAIL=devops@miempresa.com

# Comando
python3 start_services.py --mode cloudflare
```

### ⚖️ Decisión Final: ¿Qué Elegir?

**Para el 80% de usuarios, recomendamos:**

🏆 **Modo Caddy + Subdominios con Rutas** (`ai.tudominio.com/servicio`)

**Razones justificadas:**

1. **🎯 Simplicidad Operacional**: Una sola configuración DNS que gestionar
2. **💰 Eficiencia de Costos**: Mínimo overhead en DNS y certificados
3. **🔧 Fácil Mantenimiento**: Actualizaciones y cambios centralizados
4. **📈 Escalabilidad Natural**: Agregar servicios no requiere cambios DNS
5. **🛡️ Seguridad Adecuada**: Headers y políticas unificadas
6. **⚡ Tiempo de Setup**: 5-10 minutos vs 30+ minutos para subdominios múltiples

**Solo elige subdominios individuales si:**
- Trabajas en entorno empresarial grande (50+ usuarios)
- Necesitas compliance estricto de seguridad
- Planeas distribuir servicios en múltiples servidores
- Tienes equipo DevOps dedicado

## 🎮 Uso

### Comandos Principales

```bash
# Iniciar en modo específico
python3 start_services.py --mode local
python3 start_services.py --mode caddy
python3 start_services.py --mode cloudflare
python3 start_services.py --mode full

# Con environment específico
python3 start_services.py --mode local --environment public

# Ver ayuda
python3 start_services.py --help
```

### Gestión de Servicios

```bash
# Ver estado de los contenedores
docker ps

# Ver logs de un servicio específico
docker logs -f n8n
docker logs -f open-webui
docker logs -f flowise

# Reiniciar un servicio
docker restart n8n

# Parar todos los servicios
docker compose -p localai down

# Parar y eliminar volúmenes (CUIDADO: borra datos)
docker compose -p localai down -v
```

### Actualización de Contenedores

#### Opción A: Script Automático (Recomendado) ⭐

```bash
# Actualización completa automática
./update.sh

# Detecta automáticamente el modo actual y actualiza todo
# Incluye: imágenes principales, Supabase, Cloudflare, limpieza
```

#### Opción B: Comandos Manuales por Modo

```bash
# MODO LOCAL
# Detener servicios
docker compose -p localai -f docker-compose.yml down

# Actualizar imágenes
docker compose -p localai -f docker-compose.yml pull

# Reiniciar servicios
python3 start_services.py --mode local

# MODO CADDY
# Detener servicios
docker compose -p localai -f docker-compose.yml --profile caddy down

# Actualizar imágenes
docker compose -p localai -f docker-compose.yml --profile caddy pull

# Reiniciar servicios
python3 start_services.py --mode caddy

# MODO CLOUDFLARE
# Detener servicios
docker compose -p localai -f docker-compose.yml --profile cloudflare down

# Actualizar imágenes
docker compose -p localai -f docker-compose.yml --profile cloudflare pull

# Reiniciar servicios
python3 start_services.py --mode cloudflare

# MODO FULL
# Detener servicios
docker compose -p localai -f docker-compose.yml --profile caddy --profile cloudflare down

# Actualizar imágenes
docker compose -p localai -f docker-compose.yml --profile caddy --profile cloudflare pull

# Reiniciar servicios
python3 start_services.py --mode full
```

#### Comandos Adicionales

```bash
# Actualizar solo servicios específicos
docker compose -p localai pull n8n open-webui flowise

# Actualizar solo Supabase
cd supabase/docker && docker compose pull && cd ../..

# Limpiar imágenes antiguas
docker image prune -f
```

### Monitoreo

```bash
# Ver uso de recursos
docker stats

# Ver logs en tiempo real
docker compose -p localai logs -f

# Ver logs de Caddy (modos caddy/full)
docker logs -f caddy

# Ver logs de Cloudflare (modos cloudflare/full)
docker logs -f cloudflared
```

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Servicios no inician
```bash
# Verificar logs
docker compose -p localai logs

# Verificar configuración
python3 start_services.py --mode local --environment private

# Verificar puertos ocupados
netstat -tlnp | grep :5678
```

#### 2. Error de autenticación en Supabase
```bash
# Verificar variables JWT
grep JWT_SECRET .env
grep ANON_KEY .env

# Regenerar claves si es necesario
# Usar: https://supabase.com/docs/guides/hosting/overview#api-keys
```

#### 3. Cloudflare Tunnel no conecta
```bash
# Verificar token
grep TUNNEL_TOKEN .env

# Verificar configuración
cat cloudflare/config.yml

# Ver logs del tunnel
docker logs cloudflared

# Verificar credenciales
ls -la cloudflare/credentials.json
```

#### 4. SSL/TLS Errors con Caddy
```bash
# Verificar dominio
grep CLOUDFLARE_DOMAIN .env

# Verificar DNS
nslookup n8n.tudominio.com

# Ver logs de Caddy
docker logs caddy

# Verificar puertos
sudo netstat -tlnp | grep :443
```

#### 5. SearXNG no funciona
```bash
# Verificar secret key generada
grep -A5 -B5 secret_key searxng/settings.yml

# Regenerar si es necesario
python3 -c "
import os, subprocess
key = subprocess.check_output(['openssl', 'rand', '-hex', '32']).decode().strip()
print(f'Generated key: {key}')
"

# Actualizar manualmente
sed -i "s/ultrasecretkey/$(openssl rand -hex 32)/g" searxng/settings.yml
```

### Diagnóstico Completo

```bash
# Script de diagnóstico completo
echo "=== Docker Status ==="
docker --version
docker compose version

echo "=== Container Status ==="
docker ps -a

echo "=== Network Status ==="
docker network ls | grep localai

echo "=== Volume Status ==="
docker volume ls | grep localai

echo "=== Port Status ==="
netstat -tlnp | grep -E ":(3000|3001|5678|6333|8000|8080|80|443)"

echo "=== Environment Check ==="
if [ -f .env ]; then
    echo "✅ .env file exists"
    grep -v "^#" .env | grep -v "^$" | wc -l | xargs echo "Variables configured:"
else
    echo "❌ .env file missing"
fi

echo "=== Cloudflare Config Check ==="
if [ -f cloudflare/config.yml ]; then
    echo "✅ Cloudflare config exists"
else
    echo "❌ Cloudflare config missing"
fi

if [ -f cloudflare/credentials.json ]; then
    echo "✅ Cloudflare credentials exist"
else
    echo "❌ Cloudflare credentials missing"
fi
```

### Recuperación de Datos

#### Backup
```bash
# Backup de volúmenes
docker run --rm -v localai_supabase_db_data:/data -v $(pwd):/backup ubuntu tar czf /backup/supabase_backup.tar.gz /data

# Backup de configuraciones
tar czf config_backup.tar.gz .env searxng/ cloudflare/
```

#### Restore
```bash
# Restore de volúmenes
docker run --rm -v localai_supabase_db_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/supabase_backup.tar.gz -C /

# Restore de configuraciones
tar xzf config_backup.tar.gz
```

## 🤝 Contribuir

### Reportar Issues
1. Usar el [sistema de issues](https://github.com/malaface/local-server-automaticasiones-cloudflare/issues)
2. Incluir información del sistema
3. Incluir logs relevantes
4. Especificar modo de deployment

### Desarrollo
1. Fork del repositorio
2. Crear branch feature: `git checkout -b feature/nueva-caracteristica`
3. Commit cambios: `git commit -am 'Agregar nueva característica'`
4. Push al branch: `git push origin feature/nueva-caracteristica`
5. Crear Pull Request

### Agregar Nuevos Servicios
1. Editar `docker-compose.yml`
2. Crear override files si necesario
3. Actualizar `Caddyfile`
4. Actualizar `cloudflare/config.yml.example`
5. Documentar en README

## 📄 Licencia

Este proyecto está bajo la [Licencia MIT](LICENSE).

## 🙏 Créditos

- **Proyecto base**: [Cole McDonald](https://github.com/colemcmahon01) - [local-ai-stack](https://github.com/colemcmahon01/local-ai-stack)
- **Optimizaciones y Cloudflare**: [malaface](https://github.com/malaface)
- **Servicios utilizados**: n8n, Open WebUI, Flowise, Qdrant, Supabase, SearXNG

---

## 📞 Soporte

¿Problemas o preguntas?

1. **Issues**: [GitHub Issues](https://github.com/malaface/local-server-automaticasiones-cloudflare/issues)
2. **Documentación**: Este README y documentos en `/docs`
3. **Ejemplos**: Archivos `.example` en el repositorio

---

**¡Disfruta tu stack de AI local! 🚀**
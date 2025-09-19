# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **ultra-simplified** AI stack deployment system using only **Cloudflare Tunnel + Docker**.

**Architecture**: `Internet → Cloudflare Tunnel → Docker Services (direct)`

**Philosophy**: Maximum performance, minimum complexity. One proven architecture, fully validated and production-ready.

## Ultra-Simplified Structure

```bash
# One command deployment:
python3 start_services.py           # Handles everything automatically!

# With automatic updates:
python3 start_services.py --update  # Updates + deploys in one command
```

**That's it!** No mode selection, no complex configurations, just one robust architecture.

### Service Management
```bash
# View running containers
docker ps

# View logs
docker logs -f n8n
docker logs -f open-webui
docker logs -f flowise

# Stop all services
docker compose -p localai down

# Stop and remove volumes (DESTRUCTIVE)
docker compose -p localai down -v

# View service status and resource usage
docker stats
```

### Container Updates (Simplificado - Inspirado en coleam00/local-ai-packaged)
```bash
# Ultra-simplified update (recommended)
./update.sh               # down → pull → start automatically

# Manual update (3 simple steps)
docker compose -p localai down      # Stop all services
docker compose -p localai pull      # Update all images
./start.sh                          # Restart with current configuration

# Update specific services only
docker compose -p localai pull n8n open-webui flowise

# Clean up old images
docker image prune -f
```

### Diagnostics
```bash
# Check ports
netstat -tlnp | grep -E ":(3000|3001|5678|6333|8000|8080|80|443)"

# View all stack logs
docker compose -p localai logs -f
```

## Ultra-Simplified Architecture

### Project Structure
```
├── docker-compose.yml       # All services in one file
├── config.yml              # Cloudflare Tunnel configuration
├── .env.example            # Environment template
├── start.sh                # One-command deployment
├── README.md               # Simple setup guide
└── supabase/               # Database components
```

### The ONLY Architecture
**Internet → Cloudflare Tunnel → Docker Services (direct)**

No modes, no options, no complexity. One proven path that works.

### Core Services
- **n8n** → https://n8n.domain.com: Workflow automation
- **Open WebUI** → https://openwebui.domain.com: AI chat interface
- **Flowise** → https://flowise.domain.com: AI agent builder
- **Qdrant** → https://qdrant.domain.com: Vector database
- **Supabase** → https://supabase.domain.com: Backend service
- **SearXNG** → https://searxng.domain.com: Private search

### Key Benefits
- **🔥 Maximum simplicity**: No proxy layers, direct access
- **⚡ Best performance**: Zero intermediate hops
- **🔒 Total security**: No ports open, SSL automatic
- **🛠️ Easy scaling**: Add service = edit 2 files

## Environment Setup

### Required Variables (Auto-generated)
```bash
# Security (generated automatically by start.sh)
POSTGRES_PASSWORD=auto_generated
JWT_SECRET=auto_generated
SECRET_KEY_BASE=auto_generated
N8N_ENCRYPTION_KEY=auto_generated
ANON_KEY=auto_generated
SERVICE_ROLE_KEY=auto_generated
VAULT_ENC_KEY=auto_generated

# Docker
DOCKER_SOCKET_LOCATION=/var/run/docker.sock
```

### User Must Configure
```bash
# Cloudflare Tunnel (MANDATORY)
TUNNEL_TOKEN=eyJhIjoi...your_tunnel_token
CLOUDFLARE_DOMAIN=yourdomain.com

# API Keys (OPTIONAL)
OPENAI_API_KEY=sk-your_key
GOOGLE_API_KEY=your_google_ai_studio_key    # Google AI Studio para OpenWebUI
```

## Development Workflow (Ultra-Simplified)

### One-Command Deployment
1. **Setup Cloudflare**: Create tunnel, get token, configure DNS
2. **Configure**: Edit `.env` and `config.yml` with your details
3. **Deploy**: Run `./start.sh`
4. **Access**: https://service.yourdomain.com

That's it. No choices to make, no complexity to navigate.

### Adding New Services
1. **Add to docker-compose.yml**: Define the service
2. **Add to config.yml**: Configure tunnel ingress
3. **Configure DNS**: Add CNAME record in Cloudflare
4. **Restart**: `docker restart cloudflared`

Simple, predictable, scalable.

## Alternative: Using Caddy (Optional Advanced Configuration)

### When to Use Caddy vs Cloudflare Tunnel

#### Use **Cloudflare Tunnel** (Default - Recommended) when:
- 🔥 **Single server setup**: All services on one machine
- 🚀 **Maximum simplicity**: Zero port management, automatic SSL
- 🔒 **Enhanced security**: No open ports, DDoS protection included
- ⚡ **Best performance**: Direct connection, minimal latency
- 🌐 **Cloudflare ecosystem**: Using Cloudflare DNS, CDN, etc.

#### Use **Caddy** (Advanced) when:
- 🏢 **Multiple servers**: Domain shared across different IPs/servers
- 🔄 **Hybrid setup**: Some services via tunnel, others via traditional proxy
- 🛠️ **Custom headers**: Need specific proxy configurations
- 📊 **Local development**: Testing without external dependencies
- ⚖️ **Load balancing**: Multiple instances of same service

### Caddy Setup Instructions

#### 1. Enable Caddy Configuration

Uncomment Caddy service in `docker-compose.yml`:
```yaml
# Remove the '#' from these lines:
caddy:
  image: caddy:2-alpine
  restart: unless-stopped
  # ... rest of configuration
```

Uncomment Caddy volumes:
```yaml
volumes:
  # Remove the '#' from these lines:
  caddy_data:
  caddy_config:
```

#### 2. Configure Environment

Add to your `.env` file:
```bash
LETSENCRYPT_EMAIL=your@email.com
```

#### 3. DNS Configuration Options

**Option A: CNAME Records (Recommended for shared domains)**
```
n8n.yourdomain.com    CNAME  server1.yourdomain.com
flowise.yourdomain.com CNAME  server1.yourdomain.com
# Point all subdomains to your server's A record
```

**Option B: Direct A Records**
```
n8n.yourdomain.com     A      YOUR_SERVER_IP
flowise.yourdomain.com A      YOUR_SERVER_IP
```

#### 4. Deploy with Caddy

```bash
# Standard deployment (Cloudflare Tunnel only)
python3 start_services.py

# After enabling Caddy configuration
docker compose -p localai up -d caddy
```

### Hybrid Configuration (Advanced)

For maximum flexibility, run both Caddy and Cloudflare Tunnel:
- **Caddy**: Handles subdomains for local/specific services
- **Cloudflare Tunnel**: Handles main application access and security

Example use case:
```
# Via Cloudflare Tunnel (primary access)
https://app.yourdomain.com → All services

# Via Caddy (direct server access)
https://n8n.server1.yourdomain.com → n8n only
https://admin.server1.yourdomain.com → Admin panel
```

### Performance Comparison

| Feature | Cloudflare Tunnel | Caddy | Hybrid |
|---------|------------------|-------|--------|
| **Setup Complexity** | ⭐⭐⭐⭐⭐ Minimal | ⭐⭐⭐ Moderate | ⭐⭐ Complex |
| **Security** | ⭐⭐⭐⭐⭐ Maximum | ⭐⭐⭐⭐ High | ⭐⭐⭐⭐⭐ Maximum |
| **Performance** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Very Good | ⭐⭐⭐⭐ Very Good |
| **Port Management** | ⭐⭐⭐⭐⭐ None needed | ⭐⭐ Manual (80/443) | ⭐⭐ Manual |
| **Multi-server** | ⭐⭐ Limited | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐⭐ Excellent |

### Common Use Cases

#### Case 1: Development Team (Multiple Servers)
```
# Developer 1 Server
n8n.dev.company.com → Server IP 1 (via Caddy)

# Developer 2 Server
n8n.staging.company.com → Server IP 2 (via Caddy)

# Production
n8n.company.com → Production (via Cloudflare Tunnel)
```

#### Case 2: Microservices Architecture
```
# AI Services (this stack)
ai.company.com → Cloudflare Tunnel → This server

# Web Services (different server)
web.company.com → Caddy → Different server

# Database Services (third server)
db.company.com → Caddy → Database server
```

#### Case 3: Legacy Integration
```
# New services via tunnel
modern.company.com → Cloudflare Tunnel

# Legacy services via proxy
legacy.company.com → Caddy → Old servers
```

## Recent Major Simplification: Single Architecture

### New Philosophy (v3.0 - Ultra-Simplified)
- 🔥 **One architecture only**: Cloudflare Tunnel + Docker (direct)
- 🚀 **Zero complexity**: No modes, no choices, one proven path
- ⚡ **Maximum performance**: Direct service access, no intermediate proxies
- 🛠️ **Easy scaling**: Add service = edit 2 files
- 🔒 **Total security**: Zero open ports, SSL automatic

### Why This Approach
- **Validated in production**: One tested, proven architecture
- **Performance focused**: Direct access eliminates proxy overhead
- **Security first**: Cloudflare handles SSL, DDoS, and access control
- **Developer friendly**: Predictable, simple, extensible

## Latest Improvements (Inspired by coleam00/local-ai-packaged)

### v3.1 - Update Process Simplification & API Migration
- ✨ **Ultra-simplified updates**: `./update.sh` (down → pull → start automatically)
- 🔄 **3-step manual updates**: `down` → `pull` → `start.sh`
- 🤖 **Google AI Studio integration**: Replaced Anthropic with Google AI for OpenWebUI
- 📦 **Better image management**: All services use `:latest` for auto-updates

### Benefits of New Update Process
- **Faster deployments**: No complex override file management
- **Consistent workflow**: Same pattern as successful open-source projects
- **Reduced errors**: Simplified command sequence eliminates mistakes
- **Better maintenance**: One script handles entire update lifecycle

## Important Notes

- All services use unified project name "localai" for Docker Compose
- Supabase starts first, main services follow with 15-second delay
- Secrets generated automatically by `start.sh`
- **Direct subdomain routing**: service.domain.com (no paths)
- **Production ready**: Fully validated architecture
- **No legacy complexity**: Clean, focused implementation
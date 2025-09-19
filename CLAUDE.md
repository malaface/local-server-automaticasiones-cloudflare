# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **ultra-simplified** AI stack deployment system using only **Cloudflare Tunnel + Docker**.

**Architecture**: `Internet → Cloudflare Tunnel → Docker Services (direct)`

**Philosophy**: Maximum performance, minimum complexity. One proven architecture, fully validated and production-ready.

## Ultra-Simplified Structure

```bash
# One command deployment:
./start.sh           # Handles everything automatically!
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
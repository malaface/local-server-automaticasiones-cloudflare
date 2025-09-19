#!/usr/bin/env python3
"""
start_services.py

Stack AI Local Mejorado con Cloudflare - Script de inicio multi-modo

Modos disponibles:
- local: Solo servicios básicos con puertos en localhost
- caddy: Servicios + Caddy con SSL automático
- cloudflare: Servicios + Cloudflare Tunnel
- full: Caddy + Cloudflare para máxima flexibilidad

Este script inicia Supabase primero, luego los servicios locales con el modo seleccionado.
"""

import os
import subprocess
import shutil
import time
import argparse
import platform
import sys

def run_command(cmd, cwd=None):
    """Run a shell command and print it."""
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, cwd=cwd, check=True)

def clone_supabase_repo():
    """Clone the Supabase repository using sparse checkout if not already present."""
    if not os.path.exists("supabase"):
        print("Cloning the Supabase repository...")
        run_command([
            "git", "clone", "--filter=blob:none", "--no-checkout",
            "https://github.com/supabase/supabase.git"
        ])
        os.chdir("supabase")
        run_command(["git", "sparse-checkout", "init", "--cone"])
        run_command(["git", "sparse-checkout", "set", "docker"])
        run_command(["git", "checkout", "master"])
        os.chdir("..")
    else:
        print("Supabase repository already exists, updating...")
        os.chdir("supabase")
        run_command(["git", "pull"])
        os.chdir("..")

def prepare_supabase_env():
    """Copy .env to .env in supabase/docker."""
    env_path = os.path.join("supabase", "docker", ".env")
    env_example_path = os.path.join(".env")
    print("Copying .env in root to .env in supabase/docker...")
    shutil.copyfile(env_example_path, env_path)

def stop_existing_containers():
    print("Stopping and removing existing containers for the unified project 'localai'...")
    cmd = ["docker", "compose", "-p", "localai", "-f", "docker-compose.yml", "down"]
    run_command(cmd)

def start_supabase(environment=None):
    """Start the Supabase services (using its compose file)."""
    print("Starting Supabase services...")
    cmd = ["docker", "compose", "-p", "localai", "-f", "supabase/docker/docker-compose.yml"]
    if environment and environment == "public":
        cmd.extend(["-f", "docker-compose.override.public.supabase.yml"])
    cmd.extend(["up", "-d"])
    run_command(cmd)

def start_local_ai(mode="local", environment=None):
    """Start the local AI services with the specified mode."""
    print(f"Starting local AI services in {mode} mode...")
    cmd = ["docker", "compose", "-p", "localai", "-f", "docker-compose.yml"]

    # Add mode-specific override files
    if mode == "local":
        cmd.extend(["-f", "docker-compose.override.local.yml"])
    elif mode == "caddy":
        cmd.extend(["-f", "docker-compose.override.caddy.yml"])
    elif mode == "cloudflare":
        cmd.extend(["-f", "docker-compose.override.cloudflare.yml"])
    elif mode == "full":
        cmd.extend(["-f", "docker-compose.override.full.yml"])

    # Add environment-specific overrides if specified
    if environment and environment == "private":
        cmd.extend(["-f", "docker-compose.override.private.yml"])
    if environment and environment == "public":
        cmd.extend(["-f", "docker-compose.override.public.yml"])

    # Set Docker Compose profiles based on mode
    if mode in ["caddy", "full"]:
        cmd.extend(["--profile", "caddy"])
    if mode in ["cloudflare", "full"]:
        cmd.extend(["--profile", "cloudflare"])

    cmd.extend(["up", "-d"])
    run_command(cmd)

def generate_searxng_secret_key():
    """Generate a secret key for SearXNG based on the current platform."""
    print("Checking SearXNG settings...")
    
    # Define paths for SearXNG settings files
    settings_path = os.path.join("searxng", "settings.yml")
    settings_base_path = os.path.join("searxng", "settings-base.yml")
    
    # Check if settings-base.yml exists
    if not os.path.exists(settings_base_path):
        print(f"Warning: SearXNG base settings file not found at {settings_base_path}")
        return
    
    # Check if settings.yml exists, if not create it from settings-base.yml
    if not os.path.exists(settings_path):
        print(f"SearXNG settings.yml not found. Creating from {settings_base_path}...")
        try:
            shutil.copyfile(settings_base_path, settings_path)
            print(f"Created {settings_path} from {settings_base_path}")
        except Exception as e:
            print(f"Error creating settings.yml: {e}")
            return
    else:
        print(f"SearXNG settings.yml already exists at {settings_path}")
    
    print("Generating SearXNG secret key...")
    
    # Detect the platform and run the appropriate command
    system = platform.system()
    
    try:
        if system == "Windows":
            print("Detected Windows platform, using PowerShell to generate secret key...")
            # PowerShell command to generate a random key and replace in the settings file
            ps_command = [
                "powershell", "-Command",
                "$randomBytes = New-Object byte[] 32; " +
                "(New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes); " +
                "$secretKey = -join ($randomBytes | ForEach-Object { \"{0:x2}\" -f $_ }); " +
                "(Get-Content searxng/settings.yml) -replace 'ultrasecretkey', $secretKey | Set-Content searxng/settings.yml"
            ]
            subprocess.run(ps_command, check=True)
            
        elif system == "Darwin":  # macOS
            print("Detected macOS platform, using sed command with empty string parameter...")
            # macOS sed command requires an empty string for the -i parameter
            openssl_cmd = ["openssl", "rand", "-hex", "32"]
            random_key = subprocess.check_output(openssl_cmd).decode('utf-8').strip()
            sed_cmd = ["sed", "-i", "", f"s|ultrasecretkey|{random_key}|g", settings_path]
            subprocess.run(sed_cmd, check=True)
            
        else:  # Linux and other Unix-like systems
            print("Detected Linux/Unix platform, using standard sed command...")
            # Standard sed command for Linux
            openssl_cmd = ["openssl", "rand", "-hex", "32"]
            random_key = subprocess.check_output(openssl_cmd).decode('utf-8').strip()
            sed_cmd = ["sed", "-i", f"s|ultrasecretkey|{random_key}|g", settings_path]
            subprocess.run(sed_cmd, check=True)
            
        print("SearXNG secret key generated successfully.")
        
    except Exception as e:
        print(f"Error generating SearXNG secret key: {e}")
        print("You may need to manually generate the secret key using the commands:")
        print("  - Linux: sed -i \"s|ultrasecretkey|$(openssl rand -hex 32)|g\" searxng/settings.yml")
        print("  - macOS: sed -i '' \"s|ultrasecretkey|$(openssl rand -hex 32)|g\" searxng/settings.yml")
        print("  - Windows (PowerShell):")
        print("    $randomBytes = New-Object byte[] 32")
        print("    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes)")
        print("    $secretKey = -join ($randomBytes | ForEach-Object { \"{0:x2}\" -f $_ })")
        print("    (Get-Content searxng/settings.yml) -replace 'ultrasecretkey', $secretKey | Set-Content searxng/settings.yml")

def validate_basic_requirements():
    """Validate basic requirements before starting any services."""
    print(" Validating basic requirements...")
    
    # Check if .env file exists
    if not os.path.exists(".env"):
        print(" Error: .env file not found!")
        print("   Please copy .env.example to .env and configure it:")
        print("   cp .env.example .env")
        return False
    
    # Load environment variables from .env file
    try:
        with open(".env", "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ[key] = value
    except Exception as e:
        print(f" Error reading .env file: {e}")
        return False
    
    # Check critical environment variables
    critical_vars = [
        "POSTGRES_PASSWORD",
        "JWT_SECRET", 
        "DOCKER_SOCKET_LOCATION",
        "SECRET_KEY_BASE"
    ]
    
    missing_vars = []
    for var in critical_vars:
        if not os.getenv(var) or os.getenv(var).startswith("your_"):
            missing_vars.append(var)
    
    if missing_vars:
        print(" Error: Critical environment variables not configured:")
        for var in missing_vars:
            print(f"   - {var}")
        print("\n Quick fix - run these commands to generate secure values:")
        print("echo 'POSTGRES_PASSWORD='$(openssl rand -base64 32) >> .env")
        print("echo 'JWT_SECRET='$(openssl rand -hex 32) >> .env") 
        print("echo 'SECRET_KEY_BASE='$(openssl rand -hex 64) >> .env")
        print("echo 'DOCKER_SOCKET_LOCATION=/var/run/docker.sock' >> .env")
        return False
    
    # Check Docker
    try:
        subprocess.run(["docker", "info"], capture_output=True, check=True)
        print(" Docker is running")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(" Error: Docker is not running or not installed!")
        print("   Please start Docker service:")
        print("   sudo systemctl start docker")
        return False
    
    # Check Docker Compose
    try:
        subprocess.run(["docker", "compose", "version"], capture_output=True, check=True)
        print(" Docker Compose is available")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(" Error: Docker Compose is not installed!")
        print("   Please install Docker Compose plugin")
        return False
    
    # Check Docker permissions
    try:
        subprocess.run(["docker", "ps"], capture_output=True, check=True)
        print(" Docker permissions are correct")
    except subprocess.CalledProcessError:
        print(" Error: Cannot run docker commands without sudo!")
        print("   Add your user to docker group:")
        print(f"   sudo usermod -aG docker {os.getenv('USER', 'youruser')}")
        print("   Then logout and login again")
        return False
    
    print(" Basic requirements validated successfully")
    return True

def validate_required_files(mode, environment):
    """Validate that all required files exist for the selected mode and environment."""
    print(f" Validating files for mode: {mode}, environment: {environment}")
    
    required_files = ["docker-compose.yml"]
    
    # Add mode-specific files
    if mode == "local":
        required_files.append("docker-compose.override.local.yml")
    elif mode == "caddy":
        required_files.extend(["docker-compose.override.caddy.yml", "Caddyfile"])
    elif mode == "cloudflare":
        required_files.extend(["docker-compose.override.cloudflare.yml"])
    elif mode == "full":
        required_files.extend([
            "docker-compose.override.full.yml", 
            "Caddyfile",
            "docker-compose.override.caddy.yml",
            "docker-compose.override.cloudflare.yml"
        ])
    
    # Add environment-specific files
    if environment == "private":
        required_files.append("docker-compose.override.private.yml")
    elif environment == "public":
        required_files.extend([
            "docker-compose.override.public.yml",
            "docker-compose.override.public.supabase.yml"
        ])
    
    # Check Cloudflare specific files
    if mode in ["cloudflare", "full"]:
        cloudflare_files = [
            "cloudflare/config.yml",
            "cloudflare/credentials.json"
        ]
        required_files.extend(cloudflare_files)
    
    # Validate all files exist
    missing_files = []
    for file_path in required_files:
        if not os.path.exists(file_path):
            missing_files.append(file_path)
    
    if missing_files:
        print(" Error: Required files missing:")
        for file_path in missing_files:
            print(f"   - {file_path}")
            # Provide specific help for missing files
            if file_path.startswith("cloudflare/"):
                if "config.yml" in file_path:
                    print(f"     Copy cloudflare/config.yml.example to {file_path}")
                elif "credentials.json" in file_path:
                    print(f"     Download from Cloudflare Dashboard to {file_path}")
        return False
    
    print(" All required files found")
    return True

def validate_mode_requirements(mode):
    """Validate that required environment variables exist for the selected mode."""
    print(f" Validating requirements for {mode} mode...")
    
    if mode in ["cloudflare", "full"]:
        # Check for required environment variables
        tunnel_token = os.getenv("TUNNEL_TOKEN")
        cloudflare_domain = os.getenv("CLOUDFLARE_DOMAIN")

        if not tunnel_token:
            print(" Error: TUNNEL_TOKEN environment variable not set!")
            print("   Add TUNNEL_TOKEN=your_token to your .env file.")
            return False

        if not cloudflare_domain:
            print(" Error: CLOUDFLARE_DOMAIN environment variable not set!")
            print("   Add CLOUDFLARE_DOMAIN=yourdomain.com to your .env file.")
            return False
    
    if mode in ["caddy", "full"]:
        letsencrypt_email = os.getenv("LETSENCRYPT_EMAIL")
        cloudflare_domain = os.getenv("CLOUDFLARE_DOMAIN")
        
        if not letsencrypt_email:
            print(" Error: LETSENCRYPT_EMAIL environment variable not set!")
            print("   Add LETSENCRYPT_EMAIL=your@email.com to your .env file.")
            return False
            
        if not cloudflare_domain:
            print(" Error: CLOUDFLARE_DOMAIN environment variable not set!")
            print("   Add CLOUDFLARE_DOMAIN=yourdomain.com to your .env file.")
            return False

    print(f" All requirements for {mode} mode are satisfied.")
    return True

def check_and_fix_docker_compose_for_searxng():
    """Check and modify docker-compose.yml for SearXNG first run."""
    docker_compose_path = "docker-compose.yml"
    if not os.path.exists(docker_compose_path):
        print(f"Warning: Docker Compose file not found at {docker_compose_path}")
        return
    
    try:
        # Read the docker-compose.yml file
        with open(docker_compose_path, 'r') as file:
            content = file.read()
        
        # Default to first run
        is_first_run = True
        
        # Check if Docker is running and if the SearXNG container exists
        try:
            # Check if the SearXNG container is running
            container_check = subprocess.run(
                ["docker", "ps", "--filter", "name=searxng", "--format", "{{.Names}}"],
                capture_output=True, text=True, check=True
            )
            searxng_containers = container_check.stdout.strip().split('\n')
            
            # If SearXNG container is running, check inside for uwsgi.ini
            if any(container for container in searxng_containers if container):
                container_name = next(container for container in searxng_containers if container)
                print(f"Found running SearXNG container: {container_name}")
                
                # Check if uwsgi.ini exists inside the container
                container_check = subprocess.run(
                    ["docker", "exec", container_name, "sh", "-c", "[ -f /etc/searxng/uwsgi.ini ] && echo 'found' || echo 'not_found'"],
                    capture_output=True, text=True, check=False
                )
                
                if "found" in container_check.stdout:
                    print("Found uwsgi.ini inside the SearXNG container - not first run")
                    is_first_run = False
                else:
                    print("uwsgi.ini not found inside the SearXNG container - first run")
                    is_first_run = True
            else:
                print("No running SearXNG container found - assuming first run")
        except Exception as e:
            print(f"Error checking Docker container: {e} - assuming first run")
        
        if is_first_run and "cap_drop: - ALL" in content:
            print("First run detected for SearXNG. Temporarily removing 'cap_drop: - ALL' directive...")
            # Temporarily comment out the cap_drop line
            modified_content = content.replace("cap_drop: - ALL", "# cap_drop: - ALL  # Temporarily commented out for first run")
            
            # Write the modified content back
            with open(docker_compose_path, 'w') as file:
                file.write(modified_content)
                
            print("Note: After the first run completes successfully, you should re-add 'cap_drop: - ALL' to docker-compose.yml for security reasons.")
        elif not is_first_run and "# cap_drop: - ALL  # Temporarily commented out for first run" in content:
            print("SearXNG has been initialized. Re-enabling 'cap_drop: - ALL' directive for security...")
            # Uncomment the cap_drop line
            modified_content = content.replace("# cap_drop: - ALL  # Temporarily commented out for first run", "cap_drop: - ALL")
            
            # Write the modified content back
            with open(docker_compose_path, 'w') as file:
                file.write(modified_content)
    
    except Exception as e:
        print(f"Error checking/modifying docker-compose.yml for SearXNG: {e}")

def update_services():
    """Update all container images following coleam00 approach: down -> pull -> start."""
    print("Iniciando actualización de servicios...")
    print("=" * 60)

    # Step 1: Stop all services
    print("Deteniendo servicios existentes...")
    try:
        run_command(["docker", "compose", "-p", "localai", "down"])
        print("Servicios detenidos exitosamente")
    except subprocess.CalledProcessError:
        print("No hay servicios corriendo, continuando...")

    # Step 2: Pull latest images
    print("Actualizando imágenes de contenedores...")
    run_command(["docker", "compose", "-p", "localai", "pull"])
    print("Imágenes actualizadas exitosamente")

    print("Actualización completada. Los servicios se reiniciarán automáticamente.")
    print("=" * 60)

def main():
    parser = argparse.ArgumentParser(description='Stack AI Local Mejorado con soporte para múltiples modos de deployment.')
    parser.add_argument('--mode', choices=['local', 'caddy', 'cloudflare', 'full'], default='cloudflare',
                      help='Modo de deployment: local (puertos directos), caddy (SSL automático), cloudflare (tunnel), full (caddy+cloudflare)')
    parser.add_argument('--environment', choices=['private', 'public'], default='private',
                      help='Environment para Supabase (default: private)')
    parser.add_argument('--validate-only', action='store_true',
                      help='Solo validar configuración sin iniciar servicios')
    parser.add_argument('--update', action='store_true',
                      help='Actualizar imágenes de contenedores antes de iniciar servicios')
    args = parser.parse_args()

    print(f" Iniciando Stack AI Local Mejorado en modo: {args.mode}")
    print("=" * 60)

    # Step 1: Validate basic requirements
    if not validate_basic_requirements():
        print("\n Basic validation failed. Please fix the issues above before continuing.")
        sys.exit(1)

    # Step 2: Validate required files
    if not validate_required_files(args.mode, args.environment):
        print("\n File validation failed. Please fix the issues above before continuing.")
        sys.exit(1)

    # Step 3: Validate mode-specific requirements
    if not validate_mode_requirements(args.mode):
        print("\n Mode validation failed. Please fix the issues above before continuing.")
        sys.exit(1)
    
    # If only validation was requested, exit here
    if args.validate_only:
        print("\n All validations passed! You can now run without --validate-only flag.")
        sys.exit(0)

    # If update was requested, do it first
    if args.update:
        update_services()

    clone_supabase_repo()
    prepare_supabase_env()

    # Generate SearXNG secret key and check docker-compose.yml
    generate_searxng_secret_key()
    check_and_fix_docker_compose_for_searxng()

    # Only stop containers if not updating (update already stops them)
    if not args.update:
        stop_existing_containers()

    # Start Supabase first
    start_supabase(args.environment)

    # Give Supabase some time to initialize
    print("Waiting for Supabase to initialize...")
    time.sleep(10)

    # Then start the local AI services with the specified mode
    start_local_ai(args.mode, args.environment)

    print(f"\n Stack AI Local Mejorado iniciado exitosamente en modo: {args.mode}")
    print("=" * 60)

    if args.mode == "local":
        print(" Servicios disponibles en:")
        print("   - n8n: http://localhost:5678")
        print("   - Open WebUI: http://localhost:3000")
        print("   - Flowise: http://localhost:3001")
        print("   - Qdrant: http://localhost:6333")
        print("   - Supabase: http://localhost:8000")
        print("   - SearXNG: http://localhost:8080")
    elif args.mode in ["caddy", "cloudflare", "full"]:
        domain = os.getenv("CLOUDFLARE_DOMAIN", "tudominio.com")
        if args.mode == "caddy":
            print(" Servicios disponibles en:")
            print(f"   - n8n: https://n8n.{domain}")
            print(f"   - Open WebUI: https://openwebui.{domain}")
            print(f"   - Flowise: https://flowise.{domain}")
            print(f"   - Qdrant: https://qdrant.{domain}")
            print(f"   - Supabase: https://supabase.{domain}")
            print(f"   - SearXNG: https://searxng.{domain}")
        else:
            print(" Servicios disponibles a través de Cloudflare Tunnel:")
            print(f"   - n8n: https://n8n.{domain}")
            print(f"   - Open WebUI: https://openwebui.{domain}")
            print(f"   - Flowise: https://flowise.{domain}")
            print(f"   - Qdrant: https://qdrant.{domain}")
            print(f"   - Supabase: https://supabase.{domain}")
            print(f"   - SearXNG: https://searxng.{domain}")

if __name__ == "__main__":
    main()

# Ralph Docker Setup

This is a complete Docker setup for Ralph Asset Management system.

## Port Configuration

- **Ralph Web Interface**: http://localhost:8086
- **Nginx (with static files)**: http://localhost:8087 (optional, recommended)
- **MySQL Database**: localhost:3308 (internal: 3306)
- **Redis**: localhost:6380 (internal: 6379)

## Quick Start

### 1. Build and Start Services

```bash
# Build the Docker image
docker-compose build

# Start all services in detached mode
docker-compose up -d
```

### 2. Initialize Database

```bash
# Run database migrations and create superuser
docker-compose run --rm web init
```

This will:
- Create database tables
- Sync the menu structure
- Create a superuser (username: `admin`, password: `admin`)

### 3. Access Ralph

Open your browser and navigate to:
- **Direct access**: http://localhost:8086
- **Via Nginx** (recommended): http://localhost:8087

Login credentials:
- **Username**: admin
- **Password**: admin

## Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
docker-compose logs -f db
```

### Stop Services
```bash
docker-compose stop
```

### Start Services
```bash
docker-compose start
```

### Restart Ralph
```bash
docker-compose restart web
```

### Access Ralph Shell
```bash
docker-compose exec web bash
```

### Run Ralph Management Commands
```bash
# Create a new superuser
docker-compose exec web ralph createsuperuser

# Load demo data
docker-compose exec web ralph demodata

# Run migrations
docker-compose exec web ralph migrate
```

### Clean Up Everything
```bash
# Stop and remove containers, networks
docker-compose down

# Also remove volumes (WARNING: deletes all data)
docker-compose down -v
```

## Customization

### Change Default Credentials

Edit the `docker-compose.yml` file and modify these environment variables:

```yaml
RALPH_SUPERUSER_USERNAME: your_username
RALPH_SUPERUSER_PASSWORD: your_password
RALPH_SUPERUSER_EMAIL: your_email@example.com
```

### Load Demo Data

To automatically load demo data during initialization, set in `docker-compose.yml`:

```yaml
LOAD_DEMO_DATA: "true"
```

### Production Deployment

For production use:

1. Change the `SECRET_KEY` to a random string
2. Set `RALPH_DEBUG: "0"`
3. Update `ALLOWED_HOSTS` to your domain
4. Use strong passwords for database and superuser
5. Consider using environment files (`.env`) instead of hardcoding values
6. Set up proper SSL/TLS termination

## Troubleshooting

### Port Conflicts

If you get port conflicts:

1. **MySQL**: Change `"3308:3306"` to another port in `docker-compose.yml`
2. **Ralph**: Change `"8086:8000"` to another port
3. **Redis**: Change `"6380:6379"` to another port

### Database Connection Issues

```bash
# Check if database is running
docker-compose ps db

# Check database logs
docker-compose logs db

# Verify database is healthy
docker-compose exec db mysql -u ralph_ng -pralph_ng -e "SHOW DATABASES;"
```

### Ralph Won't Start

```bash
# Check Ralph logs
docker-compose logs web

# Rebuild the image
docker-compose build --no-cache web
docker-compose up -d
```

### Reset Everything

```bash
# Stop everything
docker-compose down -v

# Remove old images
docker-compose build --no-cache

# Start fresh
docker-compose up -d
docker-compose run --rm web init
```

## File Structure

```
.
├── Dockerfile              # Ralph application image
├── docker-compose.yml      # Service orchestration
├── docker-entrypoint.sh    # Container startup script
├── nginx.conf             # Nginx configuration (for static files)
├── .env.example           # Environment variables template
└── README.md              # This file
```

## Volumes

Persistent data is stored in Docker volumes:

- `ralph_dbdata`: MySQL database files
- `ralph_media`: User-uploaded media files
- `ralph_static`: Static assets (CSS, JS, images)

## Support

- Ralph Documentation: https://ralph-ng.readthedocs.io/
- Ralph GitHub: https://github.com/allegro/ralph


# Ralph

## Update - 2025/02

As Allegro, we continue to publish Ralph's source code and will maintain its development under a "Sources only" model, without guarantees. We believe this approach will be beneficial, allowing everyone to use and build upon the software. Our current goal is to modernize the software and ensure its long-term maintainability, and we're investing into it in 2025.

However, we are not operating under a contribution-based model. While we welcome discussions, we do not guarantee responses to issues or support for pull requests. If you require commercial support, please visit http://ralph.discourse.group.

We sincerely appreciate all past contributions that have shaped Ralph into the powerful tool it is today, and encourage the community to continue using it.


## Overview

Ralph is full-featured Asset Management, DCIM and CMDB system for data centers and back offices.

Features:

* keep track of assets purchases and their life cycle
* flexible flow system for assets life cycle
* data center and back office support
* dc visualization built-in

It is an Open Source project provided on Apache v2.0 License.

[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/allegro/ralph?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![packagecloud](https://img.shields.io/badge/deb-packagecloud.io-844fec.svg)](https://packagecloud.io/allegro/ralph)
[![Build Status](https://github.com/allegro/ralph/actions/workflows/main.yml/badge.svg)](https://github.com/allegro/ralph/actions/workflows/main.yml)
[![Coverage Status](https://coveralls.io/repos/allegro/ralph/badge.svg?branch=ng&service=github)](https://coveralls.io/github/allegro/ralph?branch=ng)

## Live demo:

http://ralph-demo.allegro.tech/

* login: ralph
* password: ralph

## Screenshots

![img](https://github.com/allegro/ralph/blob/ng/docs/img/welcome-screen-1.png?raw=true)

![img](https://github.com/allegro/ralph/blob/ng/docs/img/welcome-screen-2.png?raw=true)

![img](https://github.com/allegro/ralph/blob/ng/docs/img/welcome-screen-3.png?raw=true)


## Documentation
Visit our documentation on [readthedocs.org](https://ralph-ng.readthedocs.org)

## Getting help

* Online forum for Ralph community: https://ralph.discourse.group

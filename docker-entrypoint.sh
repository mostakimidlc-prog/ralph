#!/bin/bash
set -e

# Wait for database to be ready
echo "Waiting for database..."
for i in {1..60}; do
    if nc -z $DATABASE_HOST 3306 2>/dev/null; then
        echo "Database is ready!"
        break
    fi
    echo "Attempt $i/60: Database not ready yet..."
    sleep 2
done

# Wait for Redis to be ready
echo "Waiting for Redis..."
for i in {1..30}; do
    if nc -z $REDIS_HOST $REDIS_PORT 2>/dev/null; then
        echo "Redis is ready!"
        break
    fi
    echo "Attempt $i/30: Redis not ready yet..."
    sleep 2
done

# Run migrations on first start
if [ "$1" = "init" ]; then
    echo "Initializing database..."
    ralph migrate --noinput
    ralph sitetree_resync_apps
    
    # Create superuser if credentials are provided
    if [ ! -z "$RALPH_SUPERUSER_USERNAME" ] && [ ! -z "$RALPH_SUPERUSER_PASSWORD" ]; then
        echo "Creating superuser..."
        python3 << END
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ralph.settings')
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
username = os.environ.get('RALPH_SUPERUSER_USERNAME', 'admin')
email = os.environ.get('RALPH_SUPERUSER_EMAIL', 'admin@example.com')
password = os.environ.get('RALPH_SUPERUSER_PASSWORD', 'admin')
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password)
    print(f'Superuser {username} created successfully')
else:
    print(f'Superuser {username} already exists')
END
    fi
    
    # Load demo data if requested
    if [ "$LOAD_DEMO_DATA" = "true" ]; then
        echo "Loading demo data..."
        ralph demodata
    fi
    
    echo "Initialization complete!"
    exit 0
fi

# Collect static files
echo "Collecting static files..."
ralph collectstatic --noinput --clear

# Start Ralph
if [ "$1" = "start" ]; then
    echo "Starting Ralph..."
    exec ralph runserver 0.0.0.0:8000
fi

exec "$@"

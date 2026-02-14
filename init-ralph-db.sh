#!/bin/bash
# Ralph Database Setup Script
# This script initializes the Ralph database properly

echo "=========================================="
echo "Ralph Database Initialization"
echo "=========================================="

# Step 1: Check if containers are running
echo -e "\n[1/5] Checking container status..."
if ! docker-compose ps | grep -q "Up"; then
    echo "ERROR: Containers are not running!"
    echo "Run: docker-compose up -d"
    exit 1
fi
echo "✓ Containers are running"

# Step 2: Wait for database to be ready
echo -e "\n[2/5] Waiting for database to be ready..."
for i in {1..30}; do
    if docker-compose exec -T db mysql -u ralph_ng -pralph_ng -e "SELECT 1" &>/dev/null; then
        echo "✓ Database is ready"
        break
    fi
    echo "Attempt $i/30: Waiting for database..."
    sleep 2
done

# Step 3: Run migrations
echo -e "\n[3/5] Running database migrations..."
docker-compose exec -T web ralph migrate --noinput
if [ $? -eq 0 ]; then
    echo "✓ Migrations completed successfully"
else
    echo "✗ Migration failed!"
    exit 1
fi

# Step 4: Sync menu/site tree
echo -e "\n[4/5] Syncing menu structure..."
docker-compose exec -T web ralph sitetree_resync_apps
if [ $? -eq 0 ]; then
    echo "✓ Menu structure synced"
else
    echo "✗ Menu sync failed!"
    exit 1
fi

# Step 5: Create superuser
echo -e "\n[5/5] Creating superuser..."
docker-compose exec -T web bash -c 'python3 << END
import os
import django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ralph.settings")
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
username = "admin"
email = "admin@example.com"
password = "admin"
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password)
    print(f"✓ Superuser {username} created successfully")
else:
    print(f"✓ Superuser {username} already exists")
END'

# Step 6: Collect static files
echo -e "\n[6/6] Collecting static files..."
docker-compose exec -T web ralph collectstatic --noinput --clear
echo "✓ Static files collected"

echo -e "\n=========================================="
echo "✓ Database initialization complete!"
echo "=========================================="
echo ""
echo "Ralph is now ready to use:"
echo "  URL: http://localhost:8086"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "=========================================="

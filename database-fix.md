# FIX: Database Table Missing Error

## The Problem
```
ProgrammingError at /login/
(1146, "Table 'ralph_ng.accounts_ralphuser' doesn't exist")
```

This means the database exists but the tables haven't been created yet. You need to run migrations.

## ✅ SOLUTION 1: Quick Fix (Recommended)

Run these commands one by one:

```bash
# 1. Make sure containers are running
docker-compose ps

# 2. Run migrations to create tables
docker-compose exec web ralph migrate --noinput

# 3. Sync the menu structure
docker-compose exec web ralph sitetree_resync_apps

# 4. Create admin user
docker-compose exec web bash -c 'python3 << END
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
    print("Superuser created successfully")
else:
    print("Superuser already exists")
END'

# 5. Collect static files
docker-compose exec web ralph collectstatic --noinput --clear
```

After running these commands, refresh your browser and try logging in with:
- **Username**: admin
- **Password**: admin

## ✅ SOLUTION 2: Using the Automated Script

I've created a script that does everything for you:

```bash
# Make it executable
chmod +x init-ralph-db.sh

# Run it
./init-ralph-db.sh
```

This script will:
1. Check container status
2. Wait for database
3. Run migrations
4. Sync menu
5. Create superuser
6. Collect static files

## ✅ SOLUTION 3: Complete Reset (if above doesn't work)

If you're still having issues, reset everything:

```bash
# Stop and remove everything including volumes
docker-compose down -v

# Start fresh
docker-compose up -d

# Wait for services to be healthy (30-60 seconds)
sleep 60

# Check database is ready
docker-compose exec db mysql -u ralph_ng -pralph_ng -e "SHOW DATABASES;"

# Initialize database
docker-compose exec web ralph migrate --noinput
docker-compose exec web ralph sitetree_resync_apps
docker-compose exec web ralph createsuperuser --username admin --email admin@example.com --noinput
docker-compose exec web ralph collectstatic --noinput --clear
```

## 🔍 Verify It Worked

Check if tables were created:

```bash
docker-compose exec db mysql -u ralph_ng -pralph_ng ralph_ng -e "SHOW TABLES;" | grep accounts_ralphuser
```

You should see: `accounts_ralphuser`

## 🎯 Why This Happened

The `docker-compose run --rm web init` command didn't work because:
1. The entrypoint script got stuck waiting for database
2. You pressed Ctrl+C before migrations could run
3. Database was created but tables weren't

## 📝 What Each Command Does

| Command | Purpose |
|---------|---------|
| `ralph migrate` | Creates all database tables |
| `ralph sitetree_resync_apps` | Sets up the menu structure |
| `ralph createsuperuser` | Creates the admin user |
| `ralph collectstatic` | Copies CSS/JS files |

## 🚨 Still Having Issues?

### Check if database is empty:
```bash
docker-compose exec db mysql -u ralph_ng -pralph_ng ralph_ng -e "SHOW TABLES;"
```

If you see NO tables, run migrations again:
```bash
docker-compose exec web ralph migrate --noinput
```

### Check for migration errors:
```bash
docker-compose logs web | grep -i error
docker-compose logs web | grep -i migration
```

### Verify Python can connect to database:
```bash
docker-compose exec web python3 -c "
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ralph.settings')
import django
django.setup()
from django.db import connection
cursor = connection.cursor()
cursor.execute('SELECT 1')
print('✓ Database connection works!')
"
```

## 🎉 Success!

Once migrations complete successfully:

1. Open browser: http://localhost:8086
2. Login with:
   - Username: **admin**
   - Password: **admin**
3. You should see the Ralph dashboard!

## 💡 Pro Tip

For future deployments, always run this after `docker-compose up -d`:

```bash
docker-compose exec web ralph migrate --noinput && \
docker-compose exec web ralph sitetree_resync_apps && \
docker-compose exec web ralph collectstatic --noinput
```

Or add this to your docker-compose.yml as a healthcheck command.

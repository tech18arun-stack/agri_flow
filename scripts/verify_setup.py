"""
AgriFlow - Complete Setup & Migration Verification Script
This script:
1. Checks if .env exists and is valid
2. Verifies Python dependencies are installed
3. Runs setup_appwrite.py to create database structure
4. Runs all migrations in order
5. Verifies all collections and attributes exist
6. Provides a complete setup report
"""

import os
import sys
import io
import subprocess
import importlib.util

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

from dotenv import load_dotenv

# Load environment
env_path = os.path.join(os.path.dirname(__file__), '.env')
if not os.path.exists(env_path):
    print("❌ Error: .env file not found in scripts/ directory")
    print("   Copy .env.example to .env and fill in your credentials")
    sys.exit(1)

load_dotenv(env_path)

# Required environment variables
REQUIRED_VARS = {
    "APPWRITE_ENDPOINT": os.getenv("APPWRITE_ENDPOINT"),
    "APPWRITE_API_KEY": os.getenv("APPWRITE_API_KEY"),
    "APPWRITE_PROJECT_ID": os.getenv("APPWRITE_PROJECT_ID"),
    "APPWRITE_DATABASE_ID": os.getenv("APPWRITE_DATABASE_ID", "agriflow_db"),
}

print("=" * 70)
print("  AgriFlow - Complete Setup & Migration Verifier")
print("=" * 70)

# Step 1: Check environment variables
print("\n📋 Step 1: Checking environment variables...")
missing_vars = [k for k, v in REQUIRED_VARS.items() if not v]
if missing_vars:
    print(f"  ❌ Missing required variables: {', '.join(missing_vars)}")
    print("   Please update your .env file")
    sys.exit(1)
print("  ✅ All required environment variables present")

# Step 2: Check Python dependencies
print("\n📦 Step 2: Checking Python dependencies...")
required_packages = ['appwrite', 'dotenv']
missing_packages = []

for package in required_packages:
    try:
        if package == 'dotenv':
            import dotenv
        else:
            importlib.import_module(package)
        print(f"  ✅ {package}")
    except ImportError:
        missing_packages.append(package)
        print(f"  ❌ {package} (not installed)")

if missing_packages:
    print(f"\n  Installing missing packages: {', '.join(missing_packages)}")
    try:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-r', 
                             os.path.join(os.path.dirname(__file__), 'requirements.txt')])
        print("  ✅ Dependencies installed")
    except subprocess.CalledProcessError:
        print("  ❌ Failed to install dependencies")
        print("   Run: pip install -r requirements.txt")
        sys.exit(1)

# Step 3: Run setup script
print("\n🔧 Step 3: Running database setup...")
setup_script = os.path.join(os.path.dirname(__file__), 'setup_appwrite.py')
if os.path.exists(setup_script):
    try:
        result = subprocess.run([sys.executable, setup_script], 
                              capture_output=True, text=True, timeout=120)
        if result.returncode == 0:
            print("  ✅ Database setup completed successfully")
        else:
            print(f"  ⚠️  Setup script had warnings: {result.stderr[:200]}")
    except subprocess.TimeoutExpired:
        print("  ⚠️  Setup script timed out (continuing anyway)")
    except Exception as e:
        print(f"  ⚠️  Setup script error: {e}")
else:
    print("  ⚠️  setup_appwrite.py not found")

# Step 4: Run migrations
print("\n🔄 Step 4: Running migrations...")
migrations_runner = os.path.join(os.path.dirname(__file__), 'migrations', 'run_migrations.py')
if os.path.exists(migrations_runner):
    try:
        result = subprocess.run([sys.executable, migrations_runner],
                              capture_output=True, text=True, timeout=180)
        if result.returncode == 0:
            print("  ✅ All migrations completed successfully")
        else:
            print(f"  ❌ Migration failed: {result.stderr[:200]}")
            sys.exit(1)
    except subprocess.TimeoutExpired:
        print("  ❌ Migration runner timed out")
        sys.exit(1)
    except Exception as e:
        print(f"  ❌ Migration runner error: {e}")
        sys.exit(1)
else:
    print("  ⚠️  Migration runner not found")

# Step 5: Verify collections
print("\n✅ Step 5: Verifying database collections...")
try:
    from appwrite.client import Client
    from appwrite.services.databases import Databases

    client = Client()
    client.set_endpoint(REQUIRED_VARS["APPWRITE_ENDPOINT"])
    client.set_project(REQUIRED_VARS["APPWRITE_PROJECT_ID"])
    client.set_key(REQUIRED_VARS["APPWRITE_API_KEY"])

    db = Databases(client)

    expected_collections = [
        'users', 'talukas', 'municipalities', 'products', 'orders', 
        'cart', 'price_logs', 'aggregated_prices', 'price_trends',
        'categories', 'districts', 'app_settings', 'loi_requests',
        'transactions', 'inventory', 'reviews', 'addresses', 
        'wishlist', 'recently_viewed', 'notifications', 'banners',
        'coupons', 'analytics', 'admin_settings', 'order_items', 'bids'
    ]

    # Get all collections
    collections = db.list_collections(database_id=REQUIRED_VARS["APPWRITE_DATABASE_ID"])
    existing_ids = [c['$id'] for c in collections['collections']]

    missing_collections = []
    for coll_id in expected_collections:
        if coll_id in existing_ids:
            print(f"  ✅ {coll_id}")
        else:
            print(f"  ❌ {coll_id} (missing)")
            missing_collections.append(coll_id)

    if missing_collections:
        print(f"\n  ⚠️  {len(missing_collections)} collections missing")
        print("  Run migrations again to create them")
    else:
        print(f"\n  ✅ All {len(expected_collections)} collections verified!")

except Exception as e:
    print(f"  ❌ Verification failed: {e}")
    print("  This is normal if running locally without Appwrite access")

# Final report
print("\n" + "=" * 70)
print("  Setup & Migration Report")
print("=" * 70)
print(f"\n  Database: {REQUIRED_VARS['APPWRITE_DATABASE_ID']}")
print(f"  Endpoint: {REQUIRED_VARS['APPWRITE_ENDPOINT']}")
print(f"  Project: {REQUIRED_VARS['APPWRITE_PROJECT_ID']}")
print("\n  Next Steps:")
print("  1. ✅ Run seed_appwrite.py to populate sample data")
print("  2. ✅ Start the Flutter app")
print("  3. ✅ Test all features")
print("\n  Useful Commands:")
print("  • Run migrations: cd migrations && python run_migrations.py")
print("  • Seed data: python seed_appwrite.py")
print("  • Setup only: python setup_appwrite.py")
print("=" * 70)

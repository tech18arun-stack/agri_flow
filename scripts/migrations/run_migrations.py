"""
Migration Runner - Run all migrations in order
Usage: python run_migrations.py [migration_number]
  python run_migrations.py        # Run all pending migrations
  python run_migrations.py 1      # Run only migration 001
  python run_migrations.py 2      # Run only migration 002
  python run_migrations.py 3      # Run only migration 003
"""

import os
import sys
import importlib.util
import warnings
import io

# Fix UTF-8 printing on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# Suppress deprecation warnings from Appwrite SDK
warnings.filterwarnings("ignore", category=DeprecationWarning)

MIGRATIONS_DIR = os.path.dirname(__file__)

MIGRATIONS = [
    ("001", "Core Feature Collections", "001_core_features.py"),
    ("002", "Admin & Platform Features", "002_admin_platform.py"),
    ("003", "Storage Buckets & Missing Fields", "003_storage_fields.py"),
    ("004", "Fix Collection Permissions", "004_fix_permissions.py"),
    ("005", "Add Missing Product Attributes", "005_fix_product_attributes.py"),
    ("006", "Add User Profile Fields", "006_user_profile_fields.py"),
    ("007", "Product Templates Collection", "007_product_templates.py"),
    ("007a", "Seed Product Templates (Master Catalog)", "007a_seed_product_templates.py"),
]

def run_migration(number, name, filename):
    filepath = os.path.join(MIGRATIONS_DIR, filename)
    if not os.path.exists(filepath):
        print(f"ERROR: Migration file not found: {filename}")
        return False

    print(f"\n{'='*60}")
    print(f"  Running Migration {number}: {name}")
    print(f"{'='*60}")
    sys.stdout.flush()

    spec = importlib.util.spec_from_file_location(f"migration_{number}", filepath)
    module = importlib.util.module_from_spec(spec)
    try:
        spec.loader.exec_module(module)
        module.run()
        sys.stdout.flush()
        return True
    except Exception as e:
        sys.stderr.write(f"\nERROR in migration {number}: {e}\n")
        import traceback
        traceback.print_exc()
        sys.stderr.flush()
        return False

def main():
    specific = None
    if len(sys.argv) > 1:
        try:
            specific = int(sys.argv[1])
        except ValueError:
            print("Usage: python run_migrations.py [migration_number]")
            print("Example: python run_migrations.py 1")
            sys.exit(1)

    print("=" * 60)
    print("  AgriFlow Migration Runner")
    print("=" * 60)
    print("\nAvailable migrations:")
    for num, name, _ in MIGRATIONS:
        print(f"  {num}: {name}")

    if specific:
        mig = next((m for m in MIGRATIONS if m[0] == f"{specific:03d}"), None)
        if mig:
            success = run_migration(*mig)
            if success:
                print(f"\nMigration {mig[0]} completed successfully!")
            else:
                print(f"\nMigration {mig[0]} failed!")
                sys.exit(1)
        else:
            print(f"Migration {specific} not found!")
            sys.exit(1)
    else:
        all_success = True
        for num, name, filename in MIGRATIONS:
            success = run_migration(num, name, filename)
            if not success:
                all_success = False
                print(f"\nStopping at migration {num} due to error!")
                break

        if all_success:
            print("\n" + "=" * 60)
            print("  ALL MIGRATIONS COMPLETED SUCCESSFULLY")
            print("=" * 60)
        else:
            print("\n" + "=" * 60)
            print("  SOME MIGRATIONS FAILED")
            print("=" * 60)
            sys.exit(1)

if __name__ == "__main__":
    main()

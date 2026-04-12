"""
Migration 007a: Seed Product Templates from JSON
Date: 2026-04-11
Description: Load 120+ product templates from product_templates.json
Supports create + update (idempotent), UTF-8 safe, JSON-based dataset
"""

import os
import json
import sys
import io
import time
from dotenv import load_dotenv

# Fix UTF-8 printing on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases

ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://api.websitescorp.com/v1")
API_KEY = os.getenv("APPWRITE_API_KEY", "")
PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")
COLLECTION = "product_templates"

if not API_KEY or not PROJECT_ID:
    print("ERROR: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
    sys.exit(1)

client = Client()
client.set_endpoint(ENDPOINT)
client.set_project(PROJECT_ID)
client.set_key(API_KEY)

db = Databases(client)

print("=" * 60)
print("  Migration 007a: Seed Product Templates from JSON")
print("=" * 60)

# -----------------------------------
# 🔧 CREATE ATTRIBUTES (SAFE)
# -----------------------------------

def create_attr(func, *args):
    try:
        func(*args)
        print(f"  ✅ Created attribute: {args[2]}")
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  ~ Attribute exists: {args[2]}")
        else:
            print(f"  ❌ Error creating {args[2]}: {e}")

print("\n🔧 Setting up collection attributes:")
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "id", 100, True)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "nameEn", 100, True)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "nameTa", 100, True)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "category", 50, True)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "unit", 20, False)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "imageUrl", 500, False)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "icon", 10, False)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "color", 20, False)
create_attr(db.create_string_attribute, DATABASE_ID, COLLECTION, "keywords", 500, False)
create_attr(db.create_boolean_attribute, DATABASE_ID, COLLECTION, "active", False)
create_attr(db.create_integer_attribute, DATABASE_ID, COLLECTION, "sortOrder", False)

# -----------------------------------
# 📦 LOAD DATASET FROM JSON
# -----------------------------------

DATA_FILE = os.path.join(os.path.dirname(__file__), "product_templates.json")

if not os.path.exists(DATA_FILE):
    print(f"\n❌ product_templates.json not found at: {DATA_FILE}")
    sys.exit(1)

with open(DATA_FILE, "r", encoding="utf-8") as f:
    products = json.load(f)

print(f"\n📊 Loaded {len(products)} products from JSON\n")

# -----------------------------------
# 🚀 SEED DATA (CREATE + UPDATE)
# -----------------------------------

added, updated, failed = 0, 0, 0

for i, product in enumerate(products):
    try:
        db.create_document(
            database_id=DATABASE_ID,
            collection_id=COLLECTION,
            document_id=product["id"],
            data=product,
        )
        print(f"  ✅ [{i+1}/{len(products)}] Created: {product['nameEn']} ({product['nameTa']})")
        added += 1

    except Exception as e:
        if "already exists" in str(e).lower():
            try:
                db.update_document(
                    database_id=DATABASE_ID,
                    collection_id=COLLECTION,
                    document_id=product["id"],
                    data=product,
                )
                print(f"  🔄 [{i+1}/{len(products)}] Updated: {product['nameEn']}")
                updated += 1
            except Exception as err:
                print(f"  ❌ [{i+1}/{len(products)}] Update failed: {product['nameEn']} → {err}")
                failed += 1
        else:
            print(f"  ❌ [{i+1}/{len(products)}] Create failed: {product['nameEn']} → {e}")
            failed += 1

    # Small delay to avoid rate limiting (Appwrite: 60 req/min)
    if (i + 1) % 10 == 0:
        time.sleep(0.5)

# -----------------------------------
# ✅ SUMMARY
# -----------------------------------

print("\n" + "=" * 60)
print("  Migration 007a Complete")
print("=" * 60)
print(f"\n  📊 Summary:")
print(f"  ➕ Added   : {added}")
print(f"  🔄 Updated : {updated}")
print(f"  ❌ Failed  : {failed}")
print(f"  📦 Total   : {len(products)}")
print("\n  Categories:")
categories = {}
for p in products:
    cat = p.get('category', 'unknown')
    categories[cat] = categories.get(cat, 0) + 1

for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
    print(f"    - {cat}: {count} products")

print("\n  Next steps:")
print("  1. Add indexes in Appwrite Console (category, sortOrder, keywords)")
print("  2. Cache templates in Flutter for offline support")
print("  3. Build smart search (Tamil + English)")
print("=" * 60)

"""
Fix: Update all product templates with correct image URLs
This script updates existing products that were seeded without image URLs
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
print("  Fix: Update Product Templates with Image URLs")
print("=" * 60)

# Load JSON data
DATA_FILE = os.path.join(os.path.dirname(__file__), "product_templates.json")

if not os.path.exists(DATA_FILE):
    print(f"\n❌ product_templates.json not found at: {DATA_FILE}")
    sys.exit(1)

with open(DATA_FILE, "r", encoding="utf-8") as f:
    products = json.load(f)

print(f"\n📊 Loaded {len(products)} products from JSON\n")

# Update each product with correct image URL
updated = 0
failed = 0

for i, product in enumerate(products):
    try:
        # Try to update existing document
        db.update_document(
            database_id=DATABASE_ID,
            collection_id=COLLECTION,
            document_id=product["id"],
            data={
                "imageUrl": product.get("imageUrl", ""),
                "nameEn": product.get("nameEn", ""),
                "nameTa": product.get("nameTa", ""),
                "category": product.get("category", ""),
                "unit": product.get("unit", "kg"),
                "icon": product.get("icon", ""),
                "color": product.get("color", "#4CAF50"),
                "keywords": product.get("keywords", ""),
                "active": product.get("active", True),
                "sortOrder": product.get("sortOrder", 0),
            },
        )
        print(f"  ✅ [{i+1}/{len(products)}] Updated: {product['nameEn']}")
        updated += 1

    except Exception as e:
        # If document not found, create it
        if "not found" in str(e).lower() or "404" in str(e):
            try:
                db.create_document(
                    database_id=DATABASE_ID,
                    collection_id=COLLECTION,
                    document_id=product["id"],
                    data={
                        "imageUrl": product.get("imageUrl", ""),
                        "nameEn": product.get("nameEn", ""),
                        "nameTa": product.get("nameTa", ""),
                        "category": product.get("category", ""),
                        "unit": product.get("unit", "kg"),
                        "icon": product.get("icon", ""),
                        "color": product.get("color", "#4CAF50"),
                        "keywords": product.get("keywords", ""),
                        "active": product.get("active", True),
                        "sortOrder": product.get("sortOrder", 0),
                    },
                )
                print(f"  🆕 [{i+1}/{len(products)}] Created: {product['nameEn']}")
                updated += 1
            except Exception as e2:
                print(f"  ❌ [{i+1}/{len(products)}] Failed to create: {product['nameEn']} → {e2}")
                failed += 1
        else:
            print(f"  ❌ [{i+1}/{len(products)}] Failed to update: {product['nameEn']} → {e}")
            failed += 1

    # Small delay to avoid rate limiting
    if (i + 1) % 10 == 0:
        time.sleep(0.5)

print("\n" + "=" * 60)
print("  Fix Complete")
print("=" * 60)
print(f"\n  📊 Summary:")
print(f"  ✅ Updated : {updated}")
print(f"  ❌ Failed  : {failed}")
print(f"  📦 Total   : {len(products)}")
print("\n  Next: Clear app cache and restart the app")
print("  The product selector should now show real images!")
print("=" * 60)

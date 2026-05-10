"""
Agri Flow - Appwrite Cleanup Script
Deletes ALL data from collections (products, price_logs, orders, bids, etc.)
and all non-admin auth users. Preserves the admin account (admin_01).
Preserves database structure (collections, attributes, indexes).
"""

import os
import sys
import io
import warnings
from dotenv import load_dotenv

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

warnings.filterwarnings("ignore", category=DeprecationWarning)
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.users import Users
from appwrite.query import Query

APPWRITE_ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://cloud.appwrite.io/v1")
APPWRITE_API_KEY = os.getenv("APPWRITE_API_KEY", "")
APPWRITE_PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

# Collections to wipe (all documents deleted)
# NOTE: product_templates is EXCLUDED from this list to preserve admin-added image URLs.
# To update templates safely, use ensure_products.py instead.
COLLECTIONS_TO_WIPE = [
    "products",
]


# Collections where we keep reference data (categories, districts, talukas, municipalities, app_settings)
# These are NOT wiped - they are re-seeded by seed_appwrite.py

# Admin user ID to preserve
ADMIN_USER_ID = "admin_01"


def delete_collection_documents(db, collection_id):
    """Delete all documents in a collection using SDK v15 API."""
    print(f"\n  Wiping collection: {collection_id}")
    try:
        while True:
            # SDK v15: list_documents returns a dict, not an object
            result = db.list_documents(
                database_id=DATABASE_ID,
                collection_id=collection_id,
            )
            docs = result.get('documents', [])
            if not docs:
                print("     Already empty")
                break
            
            count = 0
            for doc in docs:
                try:
                    doc_id = doc.get('$id', '')
                    db.delete_document(DATABASE_ID, collection_id, doc_id)
                    count += 1
                except Exception as e:
                    print(f"     Failed to delete {doc.get('$id', '')}: {e}")
            print(f"     Deleted {count} documents in this batch")

    except Exception as e:
        if "not found" in str(e).lower():
            print("     Collection not found, skipping")
        else:
            print(f"     Error: {e}")


def delete_non_admin_users(users_svc, db):
    """Delete all auth users except admin_01, and their DB profiles."""
    print("\nDeleting non-admin auth users...")
    try:
        # SDK v15: users.list() has no limit param, use offset/iteration
        result = users_svc.list()
        users_list = result.get('users', [])
        for user in users_list:
            uid = user.get('userId', '')
            email = user.get('email', '')
            if uid != ADMIN_USER_ID:
                try:
                    users_svc.delete(user_id=uid)
                    print(f"  Deleted auth user: {email} ({uid})")
                    try:
                        db.delete_document(DATABASE_ID, "users", uid)
                    except Exception:
                        pass
                except Exception as e:
                    if "not found" not in str(e).lower():
                        print(f"  Failed to delete {uid}: {e}")
            else:
                print(f"  Preserving admin: {email}")
    except Exception as e:
        print(f"  Error listing users: {e}")


def main():
    print("=" * 60)
    print("  Agri Flow - Appwrite Cleanup (Preserve Admin)")
    print("=" * 60)

    if not APPWRITE_API_KEY or not APPWRITE_PROJECT_ID:
        print("❌ Error: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
        sys.exit(1)

    client = Client()
    client.set_endpoint(APPWRITE_ENDPOINT)
    client.set_project(APPWRITE_PROJECT_ID)
    client.set_key(APPWRITE_API_KEY)

    db = Databases(client)
    users_svc = Users(client)

    # 1. Wipe all data collections
    print("\n📦 Wiping data collections...")
    for col in COLLECTIONS_TO_WIPE:
        delete_collection_documents(db, col)

    print("\n" + "=" * 60)
    print("  ✨ Product Reset complete!")
    print("=" * 60)



if __name__ == "__main__":
    main()

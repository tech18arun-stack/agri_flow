"""
Migration 003: Storage Buckets & Missing Fields
Date: 2026-04-10
Description: Add storage buckets and missing fields to existing collections
"""

import os
import sys
from dotenv import load_dotenv

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.storage import Storage
from appwrite.id import ID
from appwrite.permission import Permission
from appwrite.role import Role

ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://api.websitescorp.com/v1")
API_KEY = os.getenv("APPWRITE_API_KEY", "")
PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

if not API_KEY or not PROJECT_ID:
    print("ERROR: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
    sys.exit(1)

client = Client()
client.set_endpoint(ENDPOINT)
client.set_project(PROJECT_ID)
client.set_key(API_KEY)

db = Databases(client)
storage = Storage(client)

def safe_attr(col_id, attr_type, key, **kwargs):
    try:
        if attr_type == "string":
            kwargs.setdefault("required", False)
            kwargs.setdefault("size", 255)
            db.create_string_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "integer":
            kwargs.setdefault("required", False)
            db.create_integer_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "float":
            kwargs.setdefault("required", False)
            db.create_float_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "boolean":
            kwargs.setdefault("required", False)
            db.create_boolean_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "enum":
            kwargs.setdefault("required", False)
            db.create_enum_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "datetime":
            kwargs.setdefault("required", False)
            db.create_datetime_attribute(DATABASE_ID, col_id, key, **kwargs)
        print(f"    + {key}")
        return True
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"    ~ {key} exists")
            return True
        else:
            print(f"    ! {key}: {e}")
            return False

def safe_index(col_id, key, idx_type, attrs):
    try:
        db.create_index(DATABASE_ID, col_id, key, idx_type, attrs)
        print(f"    [idx] {key}")
        return True
    except Exception as e:
        print(f"    [idx] {key} skip")
        return False

def run():
    print("=" * 60)
    print("  Migration 003: Storage Buckets & Missing Fields")
    print("=" * 60)

    # 1. ADDITIONAL STORAGE BUCKETS
    print("\nStorage Buckets:")
    buckets = [
        {
            "id": "product_images",
            "name": "Product Images",
            "max_size": 5_000_000,
        },
        {
            "id": "profile_images",
            "name": "Profile Images",
            "max_size": 2_000_000,
        },
        {
            "id": "banner_images",
            "name": "Banner Images",
            "max_size": 5_000_000,
        },
        {
            "id": "review_images",
            "name": "Review Images",
            "max_size": 5_000_000,
        },
        {
            "id": "document_uploads",
            "name": "Document Uploads",
            "max_size": 10_000_000,
        },
    ]

    for bucket in buckets:
        try:
            storage.create_bucket(
                bucket_id=bucket["id"],
                name=bucket["name"],
                permissions=[
                    Permission.read(Role.any()),
                    Permission.create(Role.users()),
                    Permission.update(Role.users()),
                    Permission.delete(Role.users()),
                ],
                maximum_file_size=bucket["max_size"],
                enabled=True,
            )
            print(f"  Created: {bucket['name']} ({bucket['id']})")
        except Exception as e:
            if "already exists" in str(e).lower():
                print(f"  Exists: {bucket['name']} ({bucket['id']})")
            else:
                print(f"  ERROR: {bucket['name']}: {e}")

    # 2. MISSING FIELDS ON EXISTING COLLECTIONS
    print("\nMissing fields on existing collections:")

    # Add status field to products if not exists (for moderation)
    print("\nCollection: products")
    safe_attr("products", "string", "status", size=50, default="pending")
    safe_index("products", "idx_status", "key", ["status"])

    # Add totalAmount alias to orders (for admin stats compatibility)
    print("\nCollection: orders")
    safe_attr("orders", "float", "totalAmount")

    # Add updatedAt field to users
    print("\nCollection: users")
    safe_attr("users", "datetime", "updatedAt")
    safe_attr("users", "string", "lastLoginAt", size=255)

    # Add demand field to aggregated_prices if not exists
    print("\nCollection: aggregated_prices")
    safe_attr("aggregated_prices", "string", "demand", size=50)

    print("\n" + "=" * 60)
    print("  Migration 003 Complete")
    print("=" * 60)
    print("\nStorage buckets:")
    print("  - product_images")
    print("  - profile_images")
    print("  - banner_images")
    print("  - review_images")
    print("  - document_uploads")
    print("\nFields added:")
    print("  - products.status")
    print("  - orders.totalAmount")
    print("  - users.updatedAt")
    print("  - users.lastLoginAt")
    print("  - aggregated_prices.demand")

if __name__ == "__main__":
    run()

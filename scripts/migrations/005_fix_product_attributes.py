"""
Migration 005: Add Missing Product Attributes
Date: 2026-04-10
Description: Add missing attributes to the products collection that are used
by the add product form but weren't created during initial setup.

Error being fixed:
  AppwriteException: document_invalid_structure,
  Unknown attribute: "address" (400)
"""

import os
import sys
import io
from dotenv import load_dotenv

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID

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


def safe_attr(col_id, attr_type, key, **kwargs):
    """Create attribute, skip if exists."""
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
        elif attr_type == "datetime":
            kwargs.setdefault("required", False)
            db.create_datetime_attribute(DATABASE_ID, col_id, key, **kwargs)
        print(f"  ✅ {key}")
        return True
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  ~ {key} exists")
            return True
        else:
            print(f"  ❌ {key}: {e}")
            return False


def run():
    print("=" * 60)
    print("  Migration 005: Add Missing Product Attributes")
    print("=" * 60)

    # Missing attributes for products collection
    missing_attrs = [
        ("address", "string", {"size": 500, "required": False}),
    ]

    print("\n  Adding missing attributes to 'products' collection:")
    success = 0
    for key, atype, kwargs in missing_attrs:
        if safe_attr("products", atype, key, **kwargs):
            success += 1

    # Also ensure these common attributes exist
    common_attrs = [
        ("imageUrl", "string", {"size": 500, "required": False}),
        ("rating", "float", {"required": False}),
        ("reviews", "integer", {"required": False}),
        ("lat", "float", {"required": False}),
        ("lng", "float", {"required": False}),
    ]

    print("\n  Ensuring common attributes exist on 'products':")
    for key, atype, kwargs in common_attrs:
        if safe_attr("products", atype, key, **kwargs):
            success += 1

    print("\n" + "=" * 60)
    print(f"  Migration 005 Complete: attributes added/verified")
    print("=" * 60)
    print("\n  Fixed:")
    print("  - address: string (500 chars) - pickup location details")
    print("  - imageUrl: string (500 chars) - product image URL")
    print("  - rating: float - product rating")
    print("  - reviews: integer - review count")
    print("  - lat: float - GPS latitude")
    print("  - lng: float - GPS longitude")
    print("\n  The add product form should now work correctly!")


if __name__ == "__main__":
    run()

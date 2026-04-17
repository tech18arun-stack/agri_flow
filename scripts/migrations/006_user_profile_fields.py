"""
Migration 006: Add User Profile Fields
Date: 2026-04-11
Description: Add new profile fields to users collection for enhanced user profiles
including phone, address, and timestamp tracking.

Fields Added:
- phone: User's phone number
- address: User's street address
- createdAt: Account creation timestamp
- updatedAt: Last profile update timestamp
"""

import os
import sys
import io
from dotenv import load_dotenv


if __name__ == "__main__":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    run()

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
        elif attr_type == "email":
            kwargs.setdefault("required", False)
            db.create_email_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "url":
            kwargs.setdefault("required", False)
            db.create_url_attribute(DATABASE_ID, col_id, key, **kwargs)
        print(f"  ✅ {key}")
        return True
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  ~ {key} exists")
            return True
        else:
            print(f"  ❌ {key}: {e}")
            return False


def safe_index(col_id, key, idx_type, attrs):
    """Create index, skip if exists."""
    try:
        db.create_index(DATABASE_ID, col_id, key, idx_type, attrs)
        print(f"  📊 {key} ✅")
        return True
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  📊 {key} ~ exists")
            return True
        else:
            print(f"  📊 {key} ❌: {e}")
            return False


def run():
    print("=" * 60)
    print("  Migration 006: Add User Profile Fields")
    print("=" * 60)

    # New fields for users collection
    profile_fields = [
        ("phone", "string", {"size": 50, "required": False}),
        ("address", "string", {"size": 500, "required": False}),
        ("createdAt", "datetime", {"required": False}),
        ("updatedAt", "datetime", {"required": False}),
    ]

    print("\n  📝 Adding profile fields to 'users' collection:")
    success = 0
    for key, atype, kwargs in profile_fields:
        if safe_attr("users", atype, key, **kwargs):
            success += 1

    # Add indexes for better query performance
    print("\n  📊 Adding indexes to 'users' collection:")
    indexes = [
        ("idx_phone", "key", ["phone"]),
    ]

    for key, idx_type, attrs in indexes:
        if safe_index("users", key, idx_type, attrs):
            success += 1

    print("\n" + "=" * 60)
    print(f"  Migration 006 Complete: {success} changes applied")
    print("=" * 60)
    print("\n  Fields Added:")
    print("  - phone: string (50 chars) - User phone number")
    print("  - address: string (500 chars) - Street address")
    print("  - createdAt: datetime - Account creation time")
    print("  - updatedAt: datetime - Last profile update time")
    print("\n  Indexes Added:")
    print("  - idx_phone: Index on phone number for quick lookup")
    print("\n  These fields enable:")
    print("  ✅ Enhanced user profiles")
    print("  ✅ Profile editing with phone/address")
    print("  ✅ Account tracking with timestamps")
    print("  ✅ Phone-based search and filtering")


if __name__ == "__main__":
    run()

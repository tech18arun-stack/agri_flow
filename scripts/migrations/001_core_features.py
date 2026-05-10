"""
Migration 001: Core Feature Collections
Date: 2026-04-10
Description: Add collections for transactions, inventory, reviews, addresses, wishlist, recently_viewed
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

print(f"Endpoint: {ENDPOINT}")
print(f"Database: {DATABASE_ID}")

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
        elif attr_type == "email":
            kwargs.setdefault("required", False)
            db.create_email_attribute(DATABASE_ID, col_id, key, **kwargs)
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

def create_collection(col_id, name, permissions=None):
    if permissions is None:
        permissions = [Permission.read(Role.any())]
    try:
        db.create_collection(
            database_id=DATABASE_ID,
            collection_id=col_id,
            name=name,
            permissions=permissions,
        )
        print(f"  Created: {name}")
        return True
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  Exists: {name}")
            return True
        else:
            print(f"  ERROR: {name}: {e}")
            return False

def create_document(col_id, data):
    try:
        db.create_document(
            database_id=DATABASE_ID,
            collection_id=col_id,
            document_id=ID.unique(),
            data=data,
        )
        return True
    except Exception as e:
        print(f"    ERROR: {e}")
        return False

def run():
    print("=" * 60)
    print("  Migration 001: Core Feature Collections")
    print("=" * 60)

    # 1. TRANSACTIONS - Merchant buy/sell tracking
    print("\nCollection: transactions")
    if create_collection("transactions", "Transactions"):
        attrs = [
            ("userId", "string", {"size": 255, "required": True}),
            ("userName", "string", {"size": 255, "required": True}),
            ("type", "string", {"size": 50, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "default": "kg"}),
            ("pricePerUnit", "float", {"required": True}),
            ("totalAmount", "float", {"required": True}),
            ("counterpartyId", "string", {"size": 255}),
            ("counterpartyName", "string", {"size": 255}),
            ("orderId", "string", {"size": 255}),
            ("status", "string", {"size": 50, "required": True}),
            ("paymentMethod", "string", {"size": 50}),
            ("notes", "string", {"size": 1000}),
            ("createdAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("transactions", atype, key, **kwargs)

        indices = [
            ("idx_userId", "key", ["userId"]),
            ("idx_type", "key", ["type"]),
            ("idx_status", "key", ["status"]),
            ("idx_orderId", "key", ["orderId"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ]
        for key, itype, attrs in indices:
            safe_index("transactions", key, itype, attrs)

    # 2. INVENTORY - Merchant stock tracking
    print("\nCollection: inventory")
    if create_collection("inventory", "Inventory"):
        attrs = [
            ("merchantId", "string", {"size": 255, "required": True}),
            ("merchantName", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("category", "string", {"size": 100, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "default": "kg"}),
            ("purchasePrice", "float", {"required": True}),
            ("sellingPrice", "float", {}),
            ("farmerId", "string", {"size": 255}),
            ("farmerName", "string", {"size": 255}),
            ("purchasedAt", "datetime", {"required": True}),
            ("location", "string", {"size": 100}),
            ("status", "string", {"size": 50, "required": True, "default": "in_stock"}),
            ("expiryDate", "datetime", {}),
            ("imageUrl", "string", {"size": 500}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("inventory", atype, key, **kwargs)

        indices = [
            ("idx_merchantId", "key", ["merchantId"]),
            ("idx_productId", "key", ["productId"]),
            ("idx_category", "key", ["category"]),
            ("idx_status", "key", ["status"]),
        ]
        for key, itype, attrs in indices:
            safe_index("inventory", key, itype, attrs)

    # 3. REVIEWS - Product reviews and ratings
    print("\nCollection: reviews")
    if create_collection("reviews", "Reviews"):
        attrs = [
            ("customerId", "string", {"size": 255, "required": True}),
            ("customerName", "string", {"size": 255, "required": True}),
            ("customerImage", "string", {"size": 500}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("orderId", "string", {"size": 255, "required": True}),
            ("rating", "integer", {"required": True}),
            ("title", "string", {"size": 255}),
            ("comment", "string", {"size": 2000}),
            ("images", "string", {"size": 2000}),
            ("verified", "boolean", {"default": True}),
            ("status", "string", {"size": 50, "required": True, "default": "approved"}),
            ("createdAt", "datetime", {"required": True}),
            ("helpfulCount", "integer", {"default": 0}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("reviews", atype, key, **kwargs)

        indices = [
            ("idx_productId", "key", ["productId"]),
            ("idx_customerId", "key", ["customerId"]),
            ("idx_orderId", "key", ["orderId"]),
            ("idx_status", "key", ["status"]),
        ]
        for key, itype, attrs in indices:
            safe_index("reviews", key, itype, attrs)

    # 4. ADDRESSES - User delivery addresses
    print("\nCollection: addresses")
    if create_collection("addresses", "Addresses"):
        attrs = [
            ("userId", "string", {"size": 255, "required": True}),
            ("userName", "string", {"size": 255, "required": True}),
            ("label", "string", {"size": 100, "required": True}),
            ("addressLine1", "string", {"size": 500, "required": True}),
            ("addressLine2", "string", {"size": 500}),
            ("city", "string", {"size": 100, "required": True}),
            ("district", "string", {"size": 100, "required": True}),
            ("taluk", "string", {"size": 100}),
            ("state", "string", {"size": 100, "required": True, "default": "Tamil Nadu"}),
            ("pincode", "string", {"size": 10, "required": True}),
            ("phone", "string", {"size": 15, "required": True}),
            ("isDefault", "boolean", {"default": False}),
            ("lat", "float", {}),
            ("lng", "float", {}),
            ("createdAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("addresses", atype, key, **kwargs)

        indices = [
            ("idx_userId", "key", ["userId"]),
            ("idx_district", "key", ["district"]),
        ]
        for key, itype, attrs in indices:
            safe_index("addresses", key, itype, attrs)

    # 5. WISHLIST - Customer wishlist items
    print("\nCollection: wishlist")
    if create_collection("wishlist", "Wishlist"):
        attrs = [
            ("customerId", "string", {"size": 255, "required": True}),
            ("customerName", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("productPrice", "float", {"required": True}),
            ("productImage", "string", {"size": 500}),
            ("addedAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("wishlist", atype, key, **kwargs)

        indices = [
            ("idx_customerId", "key", ["customerId"]),
            ("idx_productId", "key", ["productId"]),
            ("idx_customer_product", "key", ["customerId", "productId"]),
        ]
        for key, itype, attrs in indices:
            safe_index("wishlist", key, itype, attrs)

    # 6. RECENTLY_VIEWED - Track product views
    print("\nCollection: recently_viewed")
    if create_collection("recently_viewed", "Recently Viewed"):
        attrs = [
            ("customerId", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("productPrice", "float", {"required": True}),
            ("productImage", "string", {"size": 500}),
            ("viewedAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("recently_viewed", atype, key, **kwargs)

        indices = [
            ("idx_customerId", "key", ["customerId"]),
            ("idx_customer_viewed", "key", ["customerId", "viewedAt"]),
        ]
        for key, itype, attrs in indices:
            safe_index("recently_viewed", key, itype, attrs)

    print("\n" + "=" * 60)
    print("  Migration 001 Complete")
    print("=" * 60)

if __name__ == "__main__":
    run()

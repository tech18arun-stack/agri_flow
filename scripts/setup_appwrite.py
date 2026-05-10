"""
Agri Flow - Appwrite Database Setup Script
Compatible with appwrite Python SDK v15.x (Databases API)
"""

import os
import sys
import warnings
import io
from dotenv import load_dotenv

# Fix Windows console encoding for emojis
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

warnings.filterwarnings("ignore", category=DeprecationWarning)
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.storage import Storage
from appwrite.id import ID
from appwrite.permission import Permission
from appwrite.role import Role

APPWRITE_ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://cloud.appwrite.io/v1")
APPWRITE_API_KEY = os.getenv("APPWRITE_API_KEY", "")
APPWRITE_PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

if not APPWRITE_API_KEY or not APPWRITE_PROJECT_ID:
    print("❌ Error: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
    sys.exit(1)

print(f"📡 Endpoint: {APPWRITE_ENDPOINT}")
print(f"📁 Project:  {APPWRITE_PROJECT_ID}")
print(f"🗄️  Database: {DATABASE_ID}")

def safe_attr(db, db_id, col_id, attr_type, key, **kwargs):
    """Create attribute, skip if exists."""
    try:
        if attr_type == "string":
            kwargs.setdefault("required", False)
            db.create_string_attribute(db_id, col_id, key, **kwargs)
        elif attr_type == "integer":
            kwargs.setdefault("required", False)
            db.create_integer_attribute(db_id, col_id, key, **kwargs)
        elif attr_type == "float":
            kwargs.setdefault("required", False)
            db.create_float_attribute(db_id, col_id, key, **kwargs)
        elif attr_type == "boolean":
            kwargs.setdefault("required", False)
            db.create_boolean_attribute(db_id, col_id, key, **kwargs)
        elif attr_type == "enum":
            kwargs.setdefault("required", False)
            db.create_enum_attribute(db_id, col_id, key, **kwargs)
        elif attr_type == "datetime":
            kwargs.setdefault("required", False)
            db.create_datetime_attribute(db_id, col_id, key, **kwargs)
        print(f"    ✅ {key}")
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"    ⚠️  {key} exists")
        else:
            print(f"    ❌ {key}: {e}")

def safe_index(db, db_id, col_id, key, idx_type, attrs):
    """Create index, skip if exists."""
    try:
        db.create_index(db_id, col_id, key, idx_type, attrs)
        print(f"    📊 {key} ✅")
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"    📊 {key} ⚠️ exists")
        else:
            print(f"    📊 {key} ⚠️ skipped")

TABLES = [
    {
        "id": "users", "name": "Users",
        "attrs": [
            ("userId", "string", {"size": 255, "required": True}),
            ("name", "string", {"size": 255, "required": True}),
            ("email", "string", {"size": 255, "required": True}),
            ("phone", "string", {"size": 50, "required": False}),
            ("role", "string", {"size": 50, "required": True}),
            ("district", "string", {"size": 100, "required": True}),
            ("taluk", "string", {"size": 100, "required": False}),
            ("municipality", "string", {"size": 100, "required": False}),
            ("profileImage", "string", {"size": 500, "required": False}),
            ("status", "string", {"size": 50, "required": True}),
        ],
        "idx": [
            ("idx_role", "key", ["role"]),
            ("idx_district", "key", ["district"]),
            ("idx_status", "key", ["status"]),
        ],
    },
    {
        "id": "talukas", "name": "Talukas",
        "attrs": [
            ("name", "string", {"size": 100, "required": True}),
            ("nameTa", "string", {"size": 100, "required": False}),
            ("district", "string", {"size": 100, "required": True}),
            ("active", "boolean", {"required": False, "default": True}),
        ],
        "idx": [
            ("idx_district", "key", ["district"]),
        ],
    },
    {
        "id": "municipalities", "name": "Municipalities",
        "attrs": [
            ("name", "string", {"size": 100, "required": True}),
            ("nameTa", "string", {"size": 100, "required": False}),
            ("district", "string", {"size": 100, "required": True}),
            ("taluk", "string", {"size": 100, "required": False}),
            ("type", "string", {"size": 50, "required": True}),
            ("active", "boolean", {"required": False, "default": True}),
        ],
        "idx": [
            ("idx_district", "key", ["district"]),
            ("idx_taluk", "key", ["taluk"]),
        ],
    },
    {
        "id": "products", "name": "Products",
        "attrs": [
            ("name", "string", {"size": 255, "required": True}),
            ("nameTa", "string", {"size": 255, "required": False}),
            ("category", "string", {"size": 100, "required": True}),
            ("price", "float", {}),
            ("quantity", "float", {}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("organic", "boolean", {"required": False, "default": False}),
            ("location", "string", {"size": 100, "required": True}),
            ("address", "string", {"size": 500, "required": False}),
            ("farmerId", "string", {"size": 255, "required": True}),
            ("farmerName", "string", {"size": 255, "required": True}),
            ("farmerPhone", "string", {"size": 50, "required": False}),
            ("harvestedDate", "datetime", {}),
            ("imageUrl", "string", {"size": 500, "required": False}),
            ("rating", "float", {}),
            ("reviews", "integer", {}),
            ("status", "string", {"size": 50, "required": False, "default": "active"}),
            ("createdAt", "datetime", {}),
            ("lat", "float", {}),
            ("lng", "float", {}),
        ],
        "idx": [
            ("idx_category", "key", ["category"]),
            ("idx_farmerId", "key", ["farmerId"]),
            ("idx_location", "key", ["location"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ],
    },
    {
        "id": "orders", "name": "Orders",
        "attrs": [
            ("customerId", "string", {"size": 255, "required": True}),
            ("customerName", "string", {"size": 255, "required": True}),
            ("farmerId", "string", {"size": 255, "required": True}),
            ("farmerName", "string", {"size": 255, "required": True}),
            ("items", "string", {"size": 8000, "required": False}),
            ("total", "float", {}),
            ("status", "string", {"size": 50, "required": True}),
            ("shippingAddress", "string", {"size": 500, "required": False}),
            ("createdAt", "datetime", {}),
        ],
        "idx": [
            ("idx_customerId", "key", ["customerId"]),
            ("idx_farmerId", "key", ["farmerId"]),
            ("idx_status", "key", ["status"]),
        ],
    },
    {
        "id": "cart", "name": "Cart",
        "attrs": [
            ("customerId", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("quantity", "integer", {}),
            ("createdAt", "datetime", {}),
        ],
        "idx": [
            ("idx_customerId", "key", ["customerId"]),
        ],
    },
    {
        "id": "price_logs", "name": "Price Logs",
        "attrs": [
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("farmerId", "string", {"size": 255, "required": True}),
            ("farmerName", "string", {"size": 255, "required": True}),
            ("price", "float", {}),
            ("quantity", "float", {}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("district", "string", {"size": 100, "required": True}),
            ("createdAt", "datetime", {}),
        ],
        "idx": [
            ("idx_productId", "key", ["productId"]),
            ("idx_district", "key", ["district"]),
            ("idx_createdAt", "key", ["createdAt"]),
            ("idx_product_district", "key", ["productId", "district"]),
        ],
    },
    {
        "id": "aggregated_prices", "name": "Aggregated Prices",
        "attrs": [
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("district", "string", {"size": 100, "required": True}),
            ("avgPrice", "float", {}),
            ("minPrice", "float", {}),
            ("maxPrice", "float", {}),
            ("totalQuantity", "float", {}),
            ("sellerCount", "integer", {}),
            ("demand", "string", {"size": 50, "required": False}),
            ("lastUpdated", "datetime", {}),
        ],
        "idx": [
            ("idx_product_district", "unique", ["productId", "district"]),
            ("idx_district", "key", ["district"]),
        ],
    },
    {
        "id": "price_trends", "name": "Price Trends",
        "attrs": [
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("district", "string", {"size": 100, "required": True}),
            ("date", "string", {"size": 20, "required": True}),
            ("avgPrice", "float", {}),
        ],
        "idx": [
            ("idx_product_district_date", "unique", ["productId", "district", "date"]),
            ("idx_date", "key", ["date"]),
        ],
    },
    {
        "id": "categories", "name": "Categories",
        "attrs": [
            ("name", "string", {"size": 100, "required": True}),
            ("nameTa", "string", {"size": 100, "required": True}),
            ("icon", "string", {"size": 50, "required": False}),
            ("active", "boolean", {"required": False, "default": True}),
            ("description", "string", {"size": 500, "required": False}),
        ],
        "idx": [],
    },
    {
        "id": "districts", "name": "Districts",
        "attrs": [
            ("name", "string", {"size": 100, "required": True}),
            ("nameTa", "string", {"size": 100, "required": True}),
            ("region", "string", {"size": 50, "required": False}),
            ("active", "boolean", {"required": False, "default": True}),
        ],
        "idx": [],
    },
    {
        "id": "app_settings", "name": "App Settings",
        "attrs": [
            ("key", "string", {"size": 100, "required": True}),
            ("value", "string", {"size": 1000, "required": True}),
            ("description", "string", {"size": 500, "required": False}),
        ],
        "idx": [],
    },
    {
        "id": "loi_requests", "name": "LOI Requests",
        "attrs": [
            ("merchantId", "string", {"size": 255, "required": True}),
            ("merchantName", "string", {"size": 255, "required": True}),
            ("farmerId", "string", {"size": 255, "required": True}),
            ("farmerName", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("priceOffer", "float", {"required": True}),
            ("status", "string", {"size": 50, "required": True}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_merchantId", "key", ["merchantId"]),
            ("idx_farmerId", "key", ["farmerId"]),
            ("idx_productId", "key", ["productId"]),
            ("idx_status", "key", ["status"]),
        ],
    },
    {
        "id": "harvest_previews", "name": "Harvest Previews",
        "attrs": [
            ("farmerId", "string", {"size": 255, "required": True}),
            ("cropName", "string", {"size": 255, "required": True}),
            ("cropNameTa", "string", {"size": 255, "required": False}),
            ("expectedDate", "datetime", {"required": True}),
            ("expectedYield", "float", {"required": True}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("interestCount", "integer", {"required": False, "default": 0}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_farmerId", "key", ["farmerId"]),
            ("idx_expectedDate", "key", ["expectedDate"]),
        ],
    },
]


def main():
    print("=" * 60)
    print("  Agri Flow - Appwrite Setup (Databases API)")
    print("=" * 60)

    client = Client()
    client.set_endpoint(APPWRITE_ENDPOINT)
    client.set_project(APPWRITE_PROJECT_ID)
    client.set_key(APPWRITE_API_KEY)

    db = Databases(client)
    storage = Storage(client)

    # Create database
    print(f"\n📦 Creating database: {DATABASE_ID}")
    try:
        db.create(database_id=DATABASE_ID, name="Agri Flow Database")
        print("  ✅ Database created")
    except Exception as e:
        if "already exists" in str(e).lower():
            print("  ⚠️  Database already exists")
        else:
            print(f"  ❌ {e}")
            sys.exit(1)

    # Create tables
    for tbl in TABLES:
        print(f"\n  📋 Table: {tbl['id']}")
        # Users collection needs write permission for anyone to register
        if tbl["id"] == "users":
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.any()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        # Products: farmers create, anyone read, owner update/delete
        elif tbl["id"] == "products":
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        # Orders: customers create, anyone read, owner update
        elif tbl["id"] == "orders":
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        # Price logs: users create, anyone read
        elif tbl["id"] == "price_logs":
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        # Cart: users create own, owner manage
        elif tbl["id"] == "cart":
            perms = [
                Permission.read(Role.users()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        # LOI requests: users create, anyone read, owner update
        elif tbl["id"] == "loi_requests":
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        # Harvests: farmers create, anyone read
        elif tbl["id"] == "harvest_previews":
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        else:
            perms = [
                Permission.read(Role.any()),
                Permission.create(Role.users()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ]
        try:
            db.create_collection(
                database_id=DATABASE_ID,
                collection_id=tbl["id"],
                name=tbl["name"],
                permissions=perms,
            )
            print("    ✅ Table created")
        except Exception as e:
            if "already exists" in str(e).lower():
                print("    ⚠️  Table already exists")
            else:
                print(f"    ❌ {e}")
                continue

        for key, atype, kwargs in tbl["attrs"]:
            safe_attr(db, DATABASE_ID, tbl["id"], atype, key, **kwargs)

        for key, itype, attrs in tbl["idx"]:
            safe_index(db, DATABASE_ID, tbl["id"], key, itype, attrs)

    # Storage buckets
    print("\n📁 Storage buckets")
    for bid, bname in [("product_images", "Product Images"), ("profile_images", "Profile Images")]:
        try:
            storage.create_bucket(
                bucket_id=bid, name=bname,
                permissions=[Permission.read(Role.any())],
                maximum_file_size=5_000_000,
            )
            print(f"  ✅ {bid}")
        except Exception as e:
            if "already exists" in str(e).lower():
                print(f"  ⚠️  {bid} exists")
            else:
                print(f"  ⚠️  {bid} skipped: {e}")

    print("\n" + "=" * 60)
    print("  ✅ Setup complete!")
    print("=" * 60)
    print("\n  Next: Run seed_appwrite.py")

    # Update existing users collection permissions (fix for existing databases)
    print("\n🔐 Fixing users collection permissions...")
    try:
        db.update_collection(
            database_id=DATABASE_ID,
            collection_id="users",
            name="Users",
            permissions=[
                Permission.read(Role.any()),
                Permission.create(Role.any()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ],
        )
        print("  ✅ Users collection permissions updated")
    except Exception as e:
        print(f"  ⚠️  {e}")


if __name__ == "__main__":
    main()

"""
Agri Flow - Complete Database Setup for ALL Features
Adds collections for: Wishlist, Addresses, Reviews, Transactions, Inventory,
Notifications, Banners, Coupons, Order Items, Analytics, Content Management
"""

import os
import sys
import io
import json
import time
from datetime import datetime, timedelta
from dotenv import load_dotenv

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

warnings_filter = True
try:
    import warnings
    warnings.filterwarnings("ignore", category=DeprecationWarning)
except:
    pass

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID
from appwrite.permission import Permission
from appwrite.role import Role

APPWRITE_ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://api.websitescorp.com/v1")
APPWRITE_API_KEY = os.getenv("APPWRITE_API_KEY", "")
APPWRITE_PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "69d5d6770036e6c9bfc")

if not APPWRITE_API_KEY or not APPWRITE_PROJECT_ID:
    print("ERROR: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
    sys.exit(1)

print(f"Endpoint: {APPWRITE_ENDPOINT}")
print(f"Project:  {APPWRITE_PROJECT_ID}")
print(f"Database: {DATABASE_ID}")

client = Client()
client.set_endpoint(APPWRITE_ENDPOINT)
client.set_project(APPWRITE_PROJECT_ID)
client.set_key(APPWRITE_API_KEY)

db = Databases(client)

def safe_attr(col_id, attr_type, key, **kwargs):
    """Create attribute, skip if exists."""
    try:
        if attr_type == "string":
            db.create_string_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "integer":
            db.create_integer_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "float":
            db.create_float_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "boolean":
            db.create_boolean_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "enum":
            db.create_enum_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "datetime":
            db.create_datetime_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "ip":
            db.create_ip_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "url":
            db.create_url_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "email":
            db.create_email_attribute(DATABASE_ID, col_id, key, **kwargs)
        print(f"    + {key}")
    except Exception as e:
        if "already exists" in str(e).lower() or "invalid" in str(e).lower():
            print(f"    ~ {key} exists")
        else:
            print(f"    ! {key}: {e}")

def safe_index(col_id, key, idx_type, attrs):
    """Create index, skip if exists."""
    try:
        db.create_index(DATABASE_ID, col_id, key, idx_type, attrs)
        print(f"    [idx] {key}")
    except Exception as e:
        print(f"    [idx] {key} skip")

def create_collection(col_id, name, permissions=None):
    """Create collection if not exists."""
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
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  Exists: {name}")
        else:
            print(f"  ERROR: {name}: {e}")
            return False
    return True

def create_document(col_id, data):
    """Create a document."""
    try:
        db.create_document(
            database_id=DATABASE_ID,
            collection_id=col_id,
            document_id=ID.unique(),
            data=data,
        )
        return True
    except Exception as e:
        print(f"    ERROR creating doc: {e}")
        return False

# ============================================================
# NEW COLLECTIONS FOR MISSING FEATURES
# ============================================================

NEW_COLLECTIONS = [
    # 1. WISHLIST - Customer wishlist items
    {
        "id": "wishlist",
        "name": "Wishlist",
        "attrs": [
            ("customerId", "string", {"size": 255, "required": True}),
            ("customerName", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("productPrice", "float", {"required": True}),
            ("productImage", "string", {"size": 500, "required": False}),
            ("addedAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_customerId", "key", ["customerId"]),
            ("idx_productId", "key", ["productId"]),
            ("idx_customer_product", "key", ["customerId", "productId"]),
        ],
    },

    # 2. ADDRESSES - User delivery addresses
    {
        "id": "addresses",
        "name": "Addresses",
        "attrs": [
            ("userId", "string", {"size": 255, "required": True}),
            ("userName", "string", {"size": 255, "required": True}),
            ("label", "string", {"size": 100, "required": True}),
            ("addressLine1", "string", {"size": 500, "required": True}),
            ("addressLine2", "string", {"size": 500, "required": False}),
            ("city", "string", {"size": 100, "required": True}),
            ("district", "string", {"size": 100, "required": True}),
            ("taluk", "string", {"size": 100, "required": False}),
            ("state", "string", {"size": 100, "required": True, "default": "Tamil Nadu"}),
            ("pincode", "string", {"size": 10, "required": True}),
            ("phone", "string", {"size": 15, "required": True}),
            ("isDefault", "boolean", {"required": False, "default": False}),
            ("lat", "float", {"required": False}),
            ("lng", "float", {"required": False}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_userId", "key", ["userId"]),
            ("idx_district", "key", ["district"]),
        ],
    },

    # 3. REVIEWS - Product reviews and ratings
    {
        "id": "reviews",
        "name": "Reviews",
        "attrs": [
            ("customerId", "string", {"size": 255, "required": True}),
            ("customerName", "string", {"size": 255, "required": True}),
            ("customerImage", "string", {"size": 500, "required": False}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("orderId", "string", {"size": 255, "required": True}),
            ("rating", "integer", {"required": True}),
            ("title", "string", {"size": 255, "required": False}),
            ("comment", "string", {"size": 2000, "required": False}),
            ("images", "string", {"size": 2000, "required": False}),
            ("verified", "boolean", {"required": False, "default": True}),
            ("status", "string", {"size": 50, "required": True, "default": "approved"}),
            ("createdAt", "datetime", {"required": True}),
            ("helpfulCount", "integer", {"required": False, "default": 0}),
        ],
        "idx": [
            ("idx_productId", "key", ["productId"]),
            ("idx_customerId", "key", ["customerId"]),
            ("idx_orderId", "key", ["orderId"]),
            ("idx_rating", "key", ["rating"]),
            ("idx_status", "key", ["status"]),
        ],
    },

    # 4. TRANSACTIONS - Merchant buy/sell transactions
    {
        "id": "transactions",
        "name": "Transactions",
        "attrs": [
            ("userId", "string", {"size": 255, "required": True}),
            ("userName", "string", {"size": 255, "required": True}),
            ("type", "string", {"size": 50, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("pricePerUnit", "float", {"required": True}),
            ("totalAmount", "float", {"required": True}),
            ("counterpartyId", "string", {"size": 255, "required": False}),
            ("counterpartyName", "string", {"size": 255, "required": False}),
            ("orderId", "string", {"size": 255, "required": False}),
            ("status", "string", {"size": 50, "required": True}),
            ("paymentMethod", "string", {"size": 50, "required": False}),
            ("notes", "string", {"size": 1000, "required": False}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_userId", "key", ["userId"]),
            ("idx_type", "key", ["type"]),
            ("idx_status", "key", ["status"]),
            ("idx_orderId", "key", ["orderId"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ],
    },

    # 5. INVENTORY - Merchant inventory tracking
    {
        "id": "inventory",
        "name": "Inventory",
        "attrs": [
            ("merchantId", "string", {"size": 255, "required": True}),
            ("merchantName", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("category", "string", {"size": 100, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("purchasePrice", "float", {"required": True}),
            ("sellingPrice", "float", {"required": False}),
            ("farmerId", "string", {"size": 255, "required": False}),
            ("farmerName", "string", {"size": 255, "required": False}),
            ("purchasedAt", "datetime", {"required": True}),
            ("location", "string", {"size": 100, "required": False}),
            ("status", "string", {"size": 50, "required": True, "default": "in_stock"}),
            ("expiryDate", "datetime", {"required": False}),
            ("imageUrl", "string", {"size": 500, "required": False}),
        ],
        "idx": [
            ("idx_merchantId", "key", ["merchantId"]),
            ("idx_productId", "key", ["productId"]),
            ("idx_category", "key", ["category"]),
            ("idx_status", "key", ["status"]),
        ],
    },

    # 6. NOTIFICATIONS - Platform notifications
    {
        "id": "notifications",
        "name": "Notifications",
        "attrs": [
            ("userId", "string", {"size": 255, "required": False}),
            ("role", "string", {"size": 50, "required": False}),
            ("title", "string", {"size": 255, "required": True}),
            ("message", "string", {"size": 1000, "required": True}),
            ("type", "string", {"size": 50, "required": True}),
            ("data", "string", {"size": 2000, "required": False}),
            ("imageUrl", "string", {"size": 500, "required": False}),
            ("isRead", "boolean", {"required": False, "default": False}),
            ("scheduledAt", "datetime", {"required": False}),
            ("sentAt", "datetime", {"required": False}),
            ("createdAt", "datetime", {"required": True}),
            ("createdBy", "string", {"size": 255, "required": False}),
        ],
        "idx": [
            ("idx_userId", "key", ["userId"]),
            ("idx_role", "key", ["role"]),
            ("idx_type", "key", ["type"]),
            ("idx_isRead", "key", ["isRead"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ],
    },

    # 7. BANNERS - Homepage banners and promotional content
    {
        "id": "banners",
        "name": "Banners",
        "attrs": [
            ("title", "string", {"size": 255, "required": True}),
            ("titleTa", "string", {"size": 255, "required": False}),
            ("subtitle", "string", {"size": 500, "required": False}),
            ("imageUrl", "string", {"size": 500, "required": True}),
            ("actionType", "string", {"size": 50, "required": False}),
            ("actionData", "string", {"size": 500, "required": False}),
            ("startDate", "datetime", {"required": True}),
            ("endDate", "datetime", {"required": False}),
            ("order", "integer", {"required": True, "default": 0}),
            ("active", "boolean", {"required": False, "default": True}),
            ("targetRole", "string", {"size": 50, "required": False}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_active_order", "key", ["active", "order"]),
            ("idx_startDate", "key", ["startDate"]),
        ],
    },

    # 8. COUPONS - Discount coupons and offers
    {
        "id": "coupons",
        "name": "Coupons",
        "attrs": [
            ("code", "string", {"size": 50, "required": True}),
            ("description", "string", {"size": 500, "required": True}),
            ("discountType", "string", {"size": 50, "required": True}),
            ("discountValue", "float", {"required": True}),
            ("minOrderAmount", "float", {"required": False, "default": 0}),
            ("maxDiscountAmount", "float", {"required": False}),
            ("usageLimit", "integer", {"required": False}),
            ("usageCount", "integer", {"required": False, "default": 0}),
            ("startDate", "datetime", {"required": True}),
            ("endDate", "datetime", {"required": True}),
            ("targetRole", "string", {"size": 50, "required": False}),
            ("targetCategory", "string", {"size": 100, "required": False}),
            ("active", "boolean", {"required": False, "default": True}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_code", "key", ["code"]),
            ("idx_active", "key", ["active"]),
            ("idx_endDate", "key", ["endDate"]),
        ],
    },

    # 9. ORDER_ITEMS - Individual order line items
    {
        "id": "order_items",
        "name": "Order Items",
        "attrs": [
            ("orderId", "string", {"size": 255, "required": True}),
            ("customerId", "string", {"size": 255, "required": True}),
            ("farmerId", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
            ("pricePerUnit", "float", {"required": True}),
            ("totalPrice", "float", {"required": True}),
            ("status", "string", {"size": 50, "required": True}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_orderId", "key", ["orderId"]),
            ("idx_customerId", "key", ["customerId"]),
            ("idx_farmerId", "key", ["farmerId"]),
        ],
    },

    # 10. ANALYTICS - Platform analytics tracking
    {
        "id": "analytics",
        "name": "Analytics",
        "attrs": [
            ("userId", "string", {"size": 255, "required": False}),
            ("eventType", "string", {"size": 100, "required": True}),
            ("screen", "string", {"size": 100, "required": False}),
            ("action", "string", {"size": 100, "required": False}),
            ("data", "string", {"size": 2000, "required": False}),
            ("deviceInfo", "string", {"size": 500, "required": False}),
            ("createdAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_userId", "key", ["userId"]),
            ("idx_eventType", "key", ["eventType"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ],
    },

    # 11. RECENTLY_VIEWED - Track product views
    {
        "id": "recently_viewed",
        "name": "Recently Viewed",
        "attrs": [
            ("customerId", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("productPrice", "float", {"required": True}),
            ("productImage", "string", {"size": 500, "required": False}),
            ("viewedAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_customerId", "key", ["customerId"]),
            ("idx_customer_viewed", "key", ["customerId", "viewedAt"]),
        ],
    },

    # 12. ADMIN_SETTINGS - Platform configuration
    {
        "id": "admin_settings",
        "name": "Admin Settings",
        "attrs": [
            ("key", "string", {"size": 100, "required": True}),
            ("value", "string", {"size": 5000, "required": True}),
            ("description", "string", {"size": 500, "required": False}),
            ("updatedBy", "string", {"size": 255, "required": False}),
            ("updatedAt", "datetime", {"required": True}),
        ],
        "idx": [
            ("idx_key", "unique", ["key"]),
        ],
    },
]

# ============================================================
# SEED DATA
# ============================================================

def seed_categories():
    """Seed product categories."""
    print("\nSeeding categories...")
    categories = [
        {"name": "Vegetables", "nameTa": "காய்கறிகள்", "icon": "grass", "active": True, "description": "Fresh vegetables"},
        {"name": "Fruits", "nameTa": "பழங்கள்", "icon": "apple", "active": True, "description": "Seasonal fruits"},
        {"name": "Grains", "nameTa": "தானியங்கள்", "icon": "grain", "active": True, "description": "Rice, wheat and other grains"},
        {"name": "Spices", "nameTa": "மசாலா", "icon": "water_drop", "active": True, "description": "Indian spices"},
        {"name": "Flowers", "nameTa": "மலர்கள்", "icon": "local_florist", "active": True, "description": "Fresh flowers"},
        {"name": "Organic", "nameTa": "இயற்கை", "icon": "eco", "active": True, "description": "Organic products"},
    ]
    for cat in categories:
        cat["createdAt"] = datetime.now().isoformat()
        create_document("categories", cat)
    print("  Done: 6 categories")

def seed_districts():
    """Seed Tamil Nadu districts."""
    print("\nSeeding districts...")
    districts = [
        {"name": "Chennai", "nameTa": "சென்னை", "region": "Northern", "active": True},
        {"name": "Coimbatore", "nameTa": "கோயம்புத்தூர்", "region": "Western", "active": True},
        {"name": "Madurai", "nameTa": "மதுரை", "region": "Southern", "active": True},
        {"name": "Salem", "nameTa": "சேலம்", "region": "Western", "active": True},
        {"name": "Tiruchirappalli", "nameTa": "திருச்சிராப்பள்ளி", "region": "Central", "active": True},
        {"name": "Tirunelveli", "nameTa": "திருநெல்வேலி", "region": "Southern", "active": True},
        {"name": "Vellore", "nameTa": "வேலூர்", "region": "Northern", "active": True},
        {"name": "Erode", "nameTa": "ஈரோடு", "region": "Western", "active": True},
    ]
    for d in districts:
        create_document("districts", d)
    print("  Done: 8 districts")

def seed_talukas():
    """Seed talukas."""
    print("\nSeeding talukas...")
    talukas = [
        {"name": "Anna Nagar", "nameTa": "அண்ணா நகர்", "district": "Chennai", "active": True},
        {"name": "T. Nagar", "nameTa": "டி. நகர்", "district": "Chennai", "active": True},
        {"name": "Gandhipuram", "nameTa": "காந்திபுரம்", "district": "Coimbatore", "active": True},
        {"name": "Salem West", "nameTa": "சேலம் மேற்கு", "district": "Salem", "active": True},
    ]
    for t in talukas:
        create_document("talukas", t)
    print("  Done: 4 talukas")

def seed_municipalities():
    """Seed municipalities."""
    print("\nSeeding municipalities...")
    municipalities = [
        {"name": "Chennai Corporation", "nameTa": "சென்னை மாநகராட்சி", "district": "Chennai", "taluk": "Anna Nagar", "type": "Corporation", "active": True},
        {"name": "Coimbatore Corporation", "nameTa": "கோயம்புத்தூர் மாநகராட்சி", "district": "Coimbatore", "taluk": "Gandhipuram", "type": "Corporation", "active": True},
        {"name": "Salem Municipality", "nameTa": "சேலம் நகராட்சி", "district": "Salem", "taluk": "Salem West", "type": "Municipality", "active": True},
    ]
    for m in municipalities:
        create_document("municipalities", m)
    print("  Done: 3 municipalities")

def seed_app_settings():
    """Seed app settings."""
    print("\nSeeding app settings...")
    settings = [
        {"key": "commission_rate", "value": "5.0", "description": "Platform commission percentage"},
        {"key": "platform_fee", "value": "12", "description": "Fixed platform fee per order"},
        {"key": "shipping_fee", "value": "45", "description": "Default shipping fee"},
        {"key": "min_order_amount", "value": "100", "description": "Minimum order amount"},
        {"key": "maintenance_mode", "value": "false", "description": "Enable maintenance mode"},
        {"key": "support_email", "value": "support@agriflow.in", "description": "Support email address"},
        {"key": "support_phone", "value": "+919876543210", "description": "Support phone number"},
    ]
    for s in settings:
        s["createdAt"] = datetime.now().isoformat()
        create_document("app_settings", s)
    print("  Done: 7 settings")

def seed_banners():
    """Seed homepage banners."""
    print("\nSeeding banners...")
    now = datetime.now()
    banners = [
        {
            "title": "Fresh Harvest Season",
            "titleTa": "புதிய அறுவடை பருவம்",
            "subtitle": "Get fresh vegetables directly from farmers",
            "imageUrl": "",
            "actionType": "category",
            "actionData": "vegetables",
            "startDate": (now - timedelta(days=1)).isoformat(),
            "endDate": (now + timedelta(days=30)).isoformat(),
            "order": 1,
            "active": True,
            "targetRole": "customer",
            "createdAt": now.isoformat(),
        },
        {
            "title": "Merchant Wholesale Deals",
            "titleTa": "வணிகர் மொத்த ஒப்பந்தங்கள்",
            "subtitle": "Best wholesale prices for merchants",
            "imageUrl": "",
            "actionType": "screen",
            "actionData": "wholesale",
            "startDate": (now - timedelta(days=1)).isoformat(),
            "endDate": (now + timedelta(days=15)).isoformat(),
            "order": 2,
            "active": True,
            "targetRole": "merchant",
            "createdAt": now.isoformat(),
        },
    ]
    for b in banners:
        create_document("banners", b)
    print("  Done: 2 banners")

def seed_admin_settings():
    """Seed admin settings."""
    print("\nSeeding admin settings...")
    now = datetime.now()
    settings = [
        {"key": "commission_rate", "value": "5.0", "description": "Platform commission rate (%)", "updatedBy": "system", "updatedAt": now.isoformat()},
        {"key": "payment_methods", "value": json.dumps(["cod", "upi"]), "description": "Enabled payment methods", "updatedBy": "system", "updatedAt": now.isoformat()},
        {"key": "maintenance_mode", "value": "false", "description": "Platform maintenance mode", "updatedBy": "system", "updatedAt": now.isoformat()},
        {"key": "max_product_images", "value": "5", "description": "Max images per product", "updatedBy": "system", "updatedAt": now.isoformat()},
    ]
    for s in settings:
        create_document("admin_settings", s)
    print("  Done: 4 admin settings")

# ============================================================
# MAIN
# ============================================================

def main():
    print("=" * 60)
    print("  Agri Flow - Complete Database Setup")
    print("=" * 60)

    # Create collections
    for coll in NEW_COLLECTIONS:
        print(f"\nCollection: {coll['name']} ({coll['id']})")
        if create_collection(coll["id"], coll["name"]):
            for key, atype, kwargs in coll["attrs"]:
                safe_attr(coll["id"], atype, key, **kwargs)
            for key, itype, attrs in coll["idx"]:
                safe_index(coll["id"], key, itype, attrs)

    # Seed data
    print("\n" + "=" * 60)
    print("  Seeding Data")
    print("=" * 60)

    seed_categories()
    seed_districts()
    seed_talukas()
    seed_municipalities()
    seed_app_settings()
    seed_banners()
    seed_admin_settings()

    print("\n" + "=" * 60)
    print("  COMPLETE - All collections created and seeded!")
    print("=" * 60)
    print("\nCollections created:")
    for coll in NEW_COLLECTIONS:
        print(f"  - {coll['id']}")

if __name__ == "__main__":
    main()

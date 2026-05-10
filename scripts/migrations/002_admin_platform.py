"""
Migration 002: Admin & Platform Features
Date: 2026-04-10
Description: Add collections for admin management, content, notifications, analytics
"""

import os
import sys
import json
from datetime import datetime, timedelta
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
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"    ~ {key} exists")
        else:
            print(f"    ! {key}: {e}")

def safe_index(col_id, key, idx_type, attrs):
    try:
        db.create_index(DATABASE_ID, col_id, key, idx_type, attrs)
        print(f"    [idx] {key}")
    except Exception as e:
        print(f"    [idx] {key} skip")

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
    print("  Migration 002: Admin & Platform Features")
    print("=" * 60)

    # 1. NOTIFICATIONS - Platform notifications
    print("\nCollection: notifications")
    if create_collection("notifications", "Notifications"):
        attrs = [
            ("userId", "string", {"size": 255}),
            ("role", "string", {"size": 50}),
            ("title", "string", {"size": 255, "required": True}),
            ("message", "string", {"size": 1000, "required": True}),
            ("type", "string", {"size": 50, "required": True}),
            ("data", "string", {"size": 2000}),
            ("imageUrl", "string", {"size": 500}),
            ("isRead", "boolean", {"default": False}),
            ("scheduledAt", "datetime", {}),
            ("sentAt", "datetime", {}),
            ("createdAt", "datetime", {"required": True}),
            ("createdBy", "string", {"size": 255}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("notifications", atype, key, **kwargs)

        indices = [
            ("idx_userId", "key", ["userId"]),
            ("idx_role", "key", ["role"]),
            ("idx_type", "key", ["type"]),
            ("idx_isRead", "key", ["isRead"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ]
        for key, itype, attrs in indices:
            safe_index("notifications", key, itype, attrs)

    # 2. BANNERS - Homepage promotional banners
    print("\nCollection: banners")
    if create_collection("banners", "Banners"):
        attrs = [
            ("title", "string", {"size": 255, "required": True}),
            ("titleTa", "string", {"size": 255}),
            ("subtitle", "string", {"size": 500}),
            ("imageUrl", "string", {"size": 500, "required": True}),
            ("actionType", "string", {"size": 50}),
            ("actionData", "string", {"size": 500}),
            ("startDate", "datetime", {"required": True}),
            ("endDate", "datetime", {}),
            ("order", "integer", {"required": True, "default": 0}),
            ("active", "boolean", {"default": True}),
            ("targetRole", "string", {"size": 50}),
            ("createdAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("banners", atype, key, **kwargs)

        indices = [
            ("idx_active_order", "key", ["active", "order"]),
            ("idx_startDate", "key", ["startDate"]),
        ]
        for key, itype, attrs in indices:
            safe_index("banners", key, itype, attrs)

        # Seed default banners
        print("  Seeding default banners...")
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
        print("  Done: 2 banners seeded")

    # 3. COUPONS - Discount coupons and offers
    print("\nCollection: coupons")
    if create_collection("coupons", "Coupons"):
        attrs = [
            ("code", "string", {"size": 50, "required": True}),
            ("description", "string", {"size": 500, "required": True}),
            ("discountType", "string", {"size": 50, "required": True}),
            ("discountValue", "float", {"required": True}),
            ("minOrderAmount", "float", {"default": 0}),
            ("maxDiscountAmount", "float", {}),
            ("usageLimit", "integer", {}),
            ("usageCount", "integer", {"default": 0}),
            ("startDate", "datetime", {"required": True}),
            ("endDate", "datetime", {"required": True}),
            ("targetRole", "string", {"size": 50}),
            ("targetCategory", "string", {"size": 100}),
            ("active", "boolean", {"default": True}),
            ("createdAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("coupons", atype, key, **kwargs)

        indices = [
            ("idx_code", "key", ["code"]),
            ("idx_active", "key", ["active"]),
            ("idx_endDate", "key", ["endDate"]),
        ]
        for key, itype, attrs in indices:
            safe_index("coupons", key, itype, attrs)

    # 4. ANALYTICS - Platform event tracking
    print("\nCollection: analytics")
    if create_collection("analytics", "Analytics"):
        attrs = [
            ("userId", "string", {"size": 255}),
            ("eventType", "string", {"size": 100, "required": True}),
            ("screen", "string", {"size": 100}),
            ("action", "string", {"size": 100}),
            ("data", "string", {"size": 2000}),
            ("deviceInfo", "string", {"size": 500}),
            ("createdAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("analytics", atype, key, **kwargs)

        indices = [
            ("idx_userId", "key", ["userId"]),
            ("idx_eventType", "key", ["eventType"]),
            ("idx_createdAt", "key", ["createdAt"]),
        ]
        for key, itype, attrs in indices:
            safe_index("analytics", key, itype, attrs)

    # 5. ADMIN_SETTINGS - Platform configuration
    print("\nCollection: admin_settings")
    if create_collection("admin_settings", "Admin Settings"):
        attrs = [
            ("key", "string", {"size": 100, "required": True}),
            ("value", "string", {"size": 5000, "required": True}),
            ("description", "string", {"size": 500}),
            ("updatedBy", "string", {"size": 255}),
            ("updatedAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("admin_settings", atype, key, **kwargs)

        indices = [
            ("idx_key", "unique", ["key"]),
        ]
        for key, itype, attrs in indices:
            safe_index("admin_settings", key, itype, attrs)

        # Seed default admin settings
        print("  Seeding default admin settings...")
        now = datetime.now()
        settings = [
            {"key": "commission_rate", "value": "5.0", "description": "Platform commission rate (%)", "updatedBy": "system", "updatedAt": now.isoformat()},
            {"key": "payment_methods", "value": json.dumps(["cod", "upi"]), "description": "Enabled payment methods", "updatedBy": "system", "updatedAt": now.isoformat()},
            {"key": "maintenance_mode", "value": "false", "description": "Platform maintenance mode", "updatedBy": "system", "updatedAt": now.isoformat()},
            {"key": "max_product_images", "value": "5", "description": "Max images per product", "updatedBy": "system", "updatedAt": now.isoformat()},
        ]
        for s in settings:
            create_document("admin_settings", s)
        print("  Done: 4 admin settings seeded")

    # 6. ORDER_ITEMS - Individual order line items
    print("\nCollection: order_items")
    if create_collection("order_items", "Order Items"):
        attrs = [
            ("orderId", "string", {"size": 255, "required": True}),
            ("customerId", "string", {"size": 255, "required": True}),
            ("farmerId", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "default": "kg"}),
            ("pricePerUnit", "float", {"required": True}),
            ("totalPrice", "float", {"required": True}),
            ("status", "string", {"size": 50, "required": True}),
            ("createdAt", "datetime", {"required": True}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("order_items", atype, key, **kwargs)

        indices = [
            ("idx_orderId", "key", ["orderId"]),
            ("idx_customerId", "key", ["customerId"]),
            ("idx_farmerId", "key", ["farmerId"]),
        ]
        for key, itype, attrs in indices:
            safe_index("order_items", key, itype, attrs)

    # 7. BIDS - Negotiation between buyers and sellers
    print("\nCollection: bids")
    if create_collection("bids", "Bids"):
        attrs = [
            ("buyerId", "string", {"size": 255, "required": True}),
            ("buyerName", "string", {"size": 255, "required": True}),
            ("sellerId", "string", {"size": 255, "required": True}),
            ("sellerName", "string", {"size": 255, "required": True}),
            ("productId", "string", {"size": 255, "required": True}),
            ("productName", "string", {"size": 255, "required": True}),
            ("offerPrice", "float", {"required": True}),
            ("quantity", "float", {"required": True}),
            ("unit", "string", {"size": 20, "default": "kg"}),
            ("status", "string", {"size": 50, "required": True}),
            ("message", "string", {"size": 1000}),
            ("createdAt", "datetime", {"required": True}),
            ("respondedAt", "datetime", {}),
            ("responseMessage", "string", {"size": 1000}),
        ]
        for key, atype, kwargs in attrs:
            safe_attr("bids", atype, key, **kwargs)

        indices = [
            ("idx_buyerId", "key", ["buyerId"]),
            ("idx_sellerId", "key", ["sellerId"]),
            ("idx_productId", "key", ["productId"]),
            ("idx_status", "key", ["status"]),
        ]
        for key, itype, attrs in indices:
            safe_index("bids", key, itype, attrs)

    print("\n" + "=" * 60)
    print("  Migration 002 Complete")
    print("=" * 60)
    print("\nCollections added:")
    print("  - notifications")
    print("  - banners (seeded)")
    print("  - coupons")
    print("  - analytics")
    print("  - admin_settings (seeded)")
    print("  - order_items")
    print("  - bids")

if __name__ == "__main__":
    run()

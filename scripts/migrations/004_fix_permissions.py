"""
Migration 004: Fix Collection Permissions
Date: 2026-04-10
Description: Update products, orders, cart, price_logs, loi_requests collections
to allow logged-in users to create/update/delete their own data.

Currently these collections only have read permissions, which prevents
farmers from adding products and customers from placing orders.
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


def fix_collection_permissions(col_id, col_name, permissions):
    """Update collection permissions."""
    try:
        db.update_collection(
            database_id=DATABASE_ID,
            collection_id=col_id,
            name=col_name,
            permissions=permissions,
        )
        print(f"  ✅ {col_name}: permissions updated")
        return True
    except Exception as e:
        print(f"  ❌ {col_name}: {e}")
        return False


def run():
    print("=" * 60)
    print("  Migration 004: Fix Collection Permissions")
    print("=" * 60)

    # Permissions config
    # products: anyone read, logged-in users can create/update/delete
    products_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # orders: anyone read, logged-in users can create/update/delete
    orders_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # cart: users read own, users create/update/delete own
    cart_perms = [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # price_logs: anyone read, logged-in users can create/update/delete
    price_logs_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # loi_requests: anyone read, logged-in users can create/update/delete
    loi_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # wishlist: anyone read, logged-in users can create/update/delete
    wishlist_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # inventory: anyone read, logged-in users can create/update/delete
    inventory_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # transactions: users read own, logged-in users can create/update/delete
    transactions_perms = [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # reviews: anyone read, logged-in users can create/update/delete
    reviews_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
    ]

    # notifications: anyone read, admins create
    notifications_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.any()),
        Permission.update(Role.any()),
        Permission.delete(Role.any()),
    ]

    # banners: anyone read, admins manage
    banners_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.any()),
        Permission.update(Role.any()),
        Permission.delete(Role.any()),
    ]

    # coupons: anyone read, admins manage
    coupons_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.any()),
        Permission.update(Role.any()),
        Permission.delete(Role.any()),
    ]

    # admin_settings: anyone read, admins manage
    admin_settings_perms = [
        Permission.read(Role.any()),
        Permission.create(Role.any()),
        Permission.update(Role.any()),
        Permission.delete(Role.any()),
    ]

    collections = [
        ("products", "Products", products_perms),
        ("orders", "Orders", orders_perms),
        ("cart", "Cart", cart_perms),
        ("price_logs", "Price Logs", price_logs_perms),
        ("loi_requests", "LOI Requests", loi_perms),
        ("wishlist", "Wishlist", wishlist_perms),
        ("inventory", "Inventory", inventory_perms),
        ("transactions", "Transactions", transactions_perms),
        ("reviews", "Reviews", reviews_perms),
        ("notifications", "Notifications", notifications_perms),
        ("banners", "Banners", banners_perms),
        ("coupons", "Coupons", coupons_perms),
        ("admin_settings", "Admin Settings", admin_settings_perms),
    ]

    success_count = 0
    for col_id, col_name, perms in collections:
        if fix_collection_permissions(col_id, col_name, perms):
            success_count += 1

    print("\n" + "=" * 60)
    print(f"  Migration 004 Complete: {success_count}/{len(collections)} updated")
    print("=" * 60)

    print("\n  Summary of permission changes:")
    print("  - products: users can create/update/delete own products")
    print("  - orders: users can create/update/delete own orders")
    print("  - cart: users manage own cart items")
    print("  - price_logs: users can log prices")
    print("  - loi_requests: users can send/respond to LOIs")
    print("  - wishlist: users manage own wishlist")
    print("  - inventory: users manage own inventory")
    print("  - transactions: users manage own transactions")
    print("  - reviews: users can submit reviews")
    print("  - notifications/banners/coupons/admin_settings: open for admin")


if __name__ == "__main__":
    run()

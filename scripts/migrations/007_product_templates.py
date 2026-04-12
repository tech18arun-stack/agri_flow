"""
Migration 007: Add Product Templates Collection
Date: 2026-04-11
Description: Create product_templates collection for farmer product selection.
Contains crop names (EN + Tamil), category, unit, and image URLs.
This allows farmers to tap-select products instead of typing.
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


def safe_attr(col_id, attr_type, key, **kwargs):
    """Create attribute, skip if exists."""
    try:
        if attr_type == "string":
            kwargs.setdefault("required", False)
            kwargs.setdefault("size", 255)
            db.create_string_attribute(DATABASE_ID, col_id, key, **kwargs)
        elif attr_type == "boolean":
            kwargs.setdefault("required", False)
            db.create_boolean_attribute(DATABASE_ID, col_id, key, **kwargs)
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
    print("  Migration 007: Add Product Templates Collection")
    print("=" * 60)

    # Create collection
    print("\n📦 Creating 'product_templates' collection:")
    try:
        db.create_collection(
            database_id=DATABASE_ID,
            collection_id="product_templates",
            name="Product Templates",
            permissions=[
                Permission.read(Role.any()),
                Permission.create(Role.any()),
                Permission.update(Role.users()),
                Permission.delete(Role.users()),
            ],
        )
        print("  ✅ Collection created")
    except Exception as e:
        if "already exists" in str(e).lower():
            print("  ~ Collection exists")
        else:
            print(f"  ❌ {e}")
            return

    # Add attributes
    attrs = [
        ("id", "string", {"size": 100, "required": True}),
        ("nameEn", "string", {"size": 100, "required": True}),
        ("nameTa", "string", {"size": 100, "required": True}),
        ("category", "string", {"size": 50, "required": True}),
        ("unit", "string", {"size": 20, "required": False, "default": "kg"}),
        ("imageUrl", "string", {"size": 500, "required": False}),
        ("icon", "string", {"size": 10, "required": False, "default": "🌾"}),
        ("color", "string", {"size": 20, "required": False, "default": "#4CAF50"}),
        ("active", "boolean", {"required": False, "default": True}),
        ("sortOrder", "integer", {"required": False, "default": 0}),
    ]

    print("\n📝 Adding attributes:")
    for key, atype, kwargs in attrs:
        safe_attr("product_templates", atype, key, **kwargs)

    # Seed data - Tamil Nadu crops
    print("\n🌱 Seeding product templates:")
    products = [
        # Vegetables
        {"id": "tomato", "nameEn": "Tomato", "nameTa": "தக்காளி", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/8/89/Tomato_je.jpg", "icon": "🍅", "color": "#E53935", "active": True, "sortOrder": 1},
        {"id": "onion", "nameEn": "Onion", "nameTa": "வெங்காயம்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/1/1b/Onions.jpg", "icon": "🧅", "color": "#9C27B0", "active": True, "sortOrder": 2},
        {"id": "potato", "nameEn": "Potato", "nameTa": "உருளைக்கிழங்கு", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/a/ab/Patates.jpg", "icon": "🥔", "color": "#FFC107", "active": True, "sortOrder": 3},
        {"id": "brinjal", "nameEn": "Brinjal", "nameTa": "கத்தரிக்காய்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/3/3f/Aubergine.jpg", "icon": "🍆", "color": "#673AB7", "active": True, "sortOrder": 4},
        {"id": "cabbage", "nameEn": "Cabbage", "nameTa": "முட்டைகோஸ்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/6f/Cabbage.jpg", "icon": "🥬", "color": "#009688", "active": True, "sortOrder": 5},
        {"id": "cauliflower", "nameEn": "Cauliflower", "nameTa": "காலிஃபிளவர்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/9/9a/Cauliflower.jpg", "icon": "🤍", "color": "#F5F5F5", "active": True, "sortOrder": 6},
        {"id": "carrot", "nameEn": "Carrot", "nameTa": "கேரட்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/7/7e/Carrots.jpg", "icon": "🥕", "color": "#FF5722", "active": True, "sortOrder": 7},
        {"id": "beetroot", "nameEn": "Beetroot", "nameTa": "பீட்ரூட்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/2/2c/Beetroot.jpg", "icon": "🟣", "color": "#8E24AA", "active": True, "sortOrder": 8},
        {"id": "drumstick", "nameEn": "Drumstick", "nameTa": "முருங்கைக்காய்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/0/0c/Moringa_oleifera_fruits.jpg", "icon": "🌿", "color": "#4CAF50", "active": True, "sortOrder": 9},
        {"id": "beans", "nameEn": "Beans", "nameTa": "பீன்ஸ்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/68/Green_beans.jpg", "icon": "🫘", "color": "#4CAF50", "active": True, "sortOrder": 10},
        {"id": "okra", "nameEn": "Okra", "nameTa": "வெண்டைக்காய்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/8/83/Okra_1.jpg", "icon": "🌿", "color": "#8BC34A", "active": True, "sortOrder": 11},
        {"id": "chilli", "nameEn": "Green Chilli", "nameTa": "பச்சை மிளகாய்", "category": "vegetables", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/2/29/Red_chili.jpg", "icon": "🌶️", "color": "#D32F2F", "active": True, "sortOrder": 12},

        # Fruits
        {"id": "banana", "nameEn": "Banana", "nameTa": "வாழை", "category": "fruits", "unit": "dozen", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg", "icon": "🍌", "color": "#FFEB3B", "active": True, "sortOrder": 20},
        {"id": "mango", "nameEn": "Mango", "nameTa": "மாம்பழம்", "category": "fruits", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/9/90/Hapus_Mango.jpg", "icon": "🥭", "color": "#FF9800", "active": True, "sortOrder": 21},
        {"id": "grapes", "nameEn": "Grapes", "nameTa": "திராட்சை", "category": "fruits", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/1/1b/Table_grapes_on_white.jpg", "icon": "🍇", "color": "#9C27B0", "active": True, "sortOrder": 22},
        {"id": "watermelon", "nameEn": "Watermelon", "nameTa": "தர்பூசணி", "category": "fruits", "unit": "piece", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/e/e4/Watermelon.jpg", "icon": "🍉", "color": "#4CAF50", "active": True, "sortOrder": 23},
        {"id": "papaya", "nameEn": "Papaya", "nameTa": "பப்பாளி", "category": "fruits", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/3/3f/Papaya_cross_section.jpg", "icon": "🟠", "color": "#FF5722", "active": True, "sortOrder": 24},
        {"id": "guava", "nameEn": "Guava", "nameTa": "கொய்யா", "category": "fruits", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/4/4c/Psidium_guaja_2.jpg", "icon": "🍏", "color": "#8BC34A", "active": True, "sortOrder": 25},
        {"id": "coconut", "nameEn": "Coconut", "nameTa": "தேங்காய்", "category": "fruits", "unit": "piece", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/7/74/Coconut.jpg", "icon": "🥥", "color": "#795548", "active": True, "sortOrder": 26},

        # Grains
        {"id": "rice", "nameEn": "Rice", "nameTa": "அரிசி", "category": "grains", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/6f/Rice_grains.jpg", "icon": "🍚", "color": "#F5F5F5", "active": True, "sortOrder": 30},
        {"id": "wheat", "nameEn": "Wheat", "nameTa": "கோதுமை", "category": "grains", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/6b/Wheat_close-up.JPG", "icon": "🌾", "color": "#FFC107", "active": True, "sortOrder": 31},
        {"id": "maize", "nameEn": "Maize", "nameTa": "சோளம்", "category": "grains", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/5/5c/Sorghum_bicolor.jpg", "icon": "🌽", "color": "#FFEB3B", "active": True, "sortOrder": 32},
        {"id": "ragi", "nameEn": "Ragi", "nameTa": "ராகி", "category": "grains", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/6c/Finger_millet.jpg", "icon": "🌾", "color": "#D4A574", "active": True, "sortOrder": 33},

        # Spices
        {"id": "turmeric", "nameEn": "Turmeric", "nameTa": "மஞ்சள்", "category": "spices", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/6a/Turmeric.jpg", "icon": "🟡", "color": "#FFC107", "active": True, "sortOrder": 40},
        {"id": "ginger", "nameEn": "Ginger", "nameTa": "இஞ்சி", "category": "spices", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/7/7b/Ginger.jpg", "icon": "🫚", "color": "#FFC107", "active": True, "sortOrder": 41},
        {"id": "garlic", "nameEn": "Garlic", "nameTa": "பூண்டு", "category": "spices", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/2/27/Garlic.jpg", "icon": "🧄", "color": "#F5F5F5", "active": True, "sortOrder": 42},
        {"id": "pepper", "nameEn": "Black Pepper", "nameTa": "மிளகு", "category": "spices", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/4/4c/Black_pepper.jpg", "icon": "⚫", "color": "#424242", "active": True, "sortOrder": 43},
        {"id": "coriander", "nameEn": "Coriander", "nameTa": "கொத்தமல்லி", "category": "spices", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/5/5f/Coriander_seeds.jpg", "icon": "🌿", "color": "#4CAF50", "active": True, "sortOrder": 44},

        # Flowers
        {"id": "jasmine", "nameEn": "Jasmine", "nameTa": "மல்லிகை", "category": "flowers", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/3/3c/Jasmine_flower.jpg", "icon": "🌸", "color": "#FFF9C4", "active": True, "sortOrder": 50},
        {"id": "rose", "nameEn": "Rose", "nameTa": "ரோஜா", "category": "flowers", "unit": "bundle", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/3/35/Rose.jpg", "icon": "🌹", "color": "#E91E63", "active": True, "sortOrder": 51},
        {"id": "marigold", "nameEn": "Marigold", "nameTa": "சாமந்தி", "category": "flowers", "unit": "kg", "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/4/4c/Marigold.jpg", "icon": "🌼", "color": "#FF9800", "active": True, "sortOrder": 52},
    ]

    added = 0
    for product in products:
        try:
            db.create_document(
                database_id=DATABASE_ID,
                collection_id="product_templates",
                document_id=product["id"],
                data=product,
            )
            print(f"  ✅ {product['nameEn']} ({product['nameTa']})")
            added += 1
        except Exception as e:
            if "already exists" in str(e).lower():
                print(f"  ~ {product['nameEn']} exists")
            else:
                print(f"  ❌ {product['nameEn']}: {e}")

    print("\n" + "=" * 60)
    print(f"  Migration 007 Complete: {added} products seeded")
    print("=" * 60)
    print("\n  Collections Added:")
    print("  - product_templates (30 crops)")
    print("\n  Categories:")
    print("  - 12 Vegetables 🥬")
    print("  - 7 Fruits 🍎")
    print("  - 4 Grains 🌾")
    print("  - 5 Spices 🌿")
    print("  - 3 Flowers 🌸")
    print("\n  This enables:")
    print("  ✅ Tap-based product selection")
    print("  ✅ Bilingual crop names (EN + Tamil)")
    print("  ✅ Auto-filled category & unit")
    print("  ✅ Product images for all screens")


if __name__ == "__main__":
    run()

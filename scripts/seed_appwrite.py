"""
Agri Flow - Appwrite Seed Script
Seeds ONLY: admin user, categories, districts, app settings.
No mock/sample/demo users or products.
Compatible with appwrite Python SDK v15.x (Databases API)
"""

import os
import sys
import io
import warnings
from dotenv import load_dotenv

# Fix Windows console encoding for emojis
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

warnings.filterwarnings("ignore", category=DeprecationWarning)
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.users import Users
from appwrite.id import ID

APPWRITE_ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://cloud.appwrite.io/v1")
APPWRITE_API_KEY = os.getenv("APPWRITE_API_KEY", "")
APPWRITE_PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

# Admin Credentials
ADMIN_EMAIL = os.getenv("ADMIN_EMAIL", "admin@farm.com")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "Farm@123")

if not APPWRITE_API_KEY or not APPWRITE_PROJECT_ID:
    print("❌ Error: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
    sys.exit(1)


def safe_insert(db, col_id, doc_id, data):
    """Insert document, skip if exists."""
    try:
        db.create_document(DATABASE_ID, col_id, doc_id, data)
    except Exception as e:
        if "already exists" not in str(e).lower():
            raise


def seed_admin_user(users_svc, db):
    print("\n👤 Seeding Admin User...")
    try:
        users_svc.create(
            user_id="admin_01",
            email=ADMIN_EMAIL,
            password=ADMIN_PASSWORD,
            name="System Administrator",
        )
        print(f"  ✅ Auth Created: {ADMIN_EMAIL}")
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"  ℹ️  Auth Exists: {ADMIN_EMAIL}")
        else:
            print(f"  ❌ Auth Error: {e}")

    try:
        safe_insert(db, "users", "admin_01", {
            "userId": "admin_01",
            "name": "System Administrator",
            "email": ADMIN_EMAIL,
            "phone": "",
            "role": "admin",
            "district": "",
            "status": "active",
        })
        print("  ✅ Admin Profile Created")
    except Exception as e:
        print(f"  ❌ Profile Error: {e}")


def seed_categories(db):
    print("\n📂 Seeding categories...")
    cats = [
        ("cat_vegetables", "Vegetables", "காய்கறிகள்", "eco", "Fresh vegetables from Tamil Nadu farms"),
        ("cat_fruits", "Fruits", "பழங்கள்", "apple", "Seasonal fruits from local orchards"),
        ("cat_flowers", "Flowers", "மலர்கள்", "local_florist", "Fresh flowers for temples and events"),
        ("cat_grains", "Grains", "தானியங்கள்", "grass", "Rice, wheat, and millet varieties"),
        ("cat_spices", "Spices", "மசாலா", "spice", "Turmeric, chili, and traditional spices"),
        ("cat_others", "Others", "மற்றவை", "inventory_2", "Other agricultural products"),
    ]
    for cid, name, nameTa, icon, desc in cats:
        try:
            safe_insert(db, "categories", cid, {
                "name": name, "nameTa": nameTa, "icon": icon,
                "active": True, "description": desc,
            })
            print(f"  ✅ {name} / {nameTa}")
        except Exception as e:
            print(f"  ❌ {name}: {e}")


def seed_districts(db):
    print("\n📍 Seeding districts...")
    districts = [
        ("dist_coimbatore", "Coimbatore", "கோயம்புத்தூர்", "Kongu"),
        ("dist_salem", "Salem", "சேலம்", "Kongu"),
        ("dist_madurai", "Madurai", "மதுரை", "Southern"),
        ("dist_erode", "Erode", "ஈரோடு", "Kongu"),
        ("dist_thanjavur", "Thanjavur", "தஞ்சாவூர்", "Delta"),
        ("dist_nilgiris", "Nilgiris", "நீலகிரி", "Western"),
        ("dist_trichy", "Trichy", "திருச்சி", "Central"),
        ("dist_dindigul", "Dindigul", "திண்டுக்கல்", "Southern"),
        ("dist_theni", "Theni", "தேனி", "Southern"),
        ("dist_chennai", "Chennai", "சென்னை", "Northern"),
    ]
    for did, name, nameTa, region in districts:
        try:
            safe_insert(db, "districts", did, {
                "name": name, "nameTa": nameTa, "region": region, "active": True,
            })
            print(f"  ✅ {name} / {nameTa}")
        except Exception as e:
            print(f"  ❌ {name}: {e}")


def seed_settings(db):
    print("\n⚙️  Seeding app settings...")
    settings = [
        ("platform_fee", "12", "Platform fee per order (₹)"),
        ("shipping_default", "45", "Default shipping charge (₹)"),
        ("free_shipping_threshold", "500", "Free shipping above this amount (₹)"),
        ("gst_rate", "0.12", "GST rate (12%)"),
        ("app_version", "1.0.0", "Current app version"),
        ("maintenance_mode", "false", "Maintenance mode toggle"),
        ("max_product_images", "5", "Max images per product"),
        ("min_order_quantity", "1", "Minimum order quantity (kg)"),
    ]
    for key, value, desc in settings:
        try:
            safe_insert(db, "app_settings", key, {
                "key": key, "value": value, "description": desc,
            })
            print(f"  ✅ {key}: {value}")
        except Exception as e:
            print(f"  ❌ {key}: {e}")


def seed_talukas(db):
    print("\n📍 Seeding talukas...")
    talukas = [
        # Coimbatore
        ("tkl_coimbatore_north", "Coimbatore North", "கோயம்புத்தூர் வடக்கு", "Coimbatore"),
        ("tkl_coimbatore_south", "Coimbatore South", "கோயம்புத்தூர் தெற்கு", "Coimbatore"),
        ("tkl_pollachi", "Pollachi", "பொள்ளாச்சி", "Coimbatore"),
        ("tkl_valparai", "Valparai", "வால்பாறை", "Coimbatore"),
        ("tkl_sulur", "Sulur", "சூலூர்", "Coimbatore"),
        # Salem
        ("tkl_salem_north", "Salem North", "சேலம் வடக்கு", "Salem"),
        ("tkl_salem_south", "Salem South", "சேலம் தெற்கு", "Salem"),
        ("tkl_attur", "Attur", "ஆத்தூர்", "Salem"),
        ("tkl_mettur", "Mettur", "மேட்டூர்", "Salem"),
        ("tkl_sankagiri", "Sankagiri", "சங்ககிரி", "Salem"),
        # Madurai
        ("tkl_madurai_north", "Madurai North", "மதுரை வடக்கு", "Madurai"),
        ("tkl_madurai_south", "Madurai South", "மதுரை தெற்கு", "Madurai"),
        ("tkl_melur", "Melur", "மேலூர்", "Madurai"),
        ("tkl_thirumangalam", "Thirumangalam", "திருமங்கலம்", "Madurai"),
        ("tkl_usilampatti", "Usilampatti", "உசிலம்பட்டி", "Madurai"),
        # Erode
        ("tkl_erode_north", "Erode North", "ஈரோடு வடக்கு", "Erode"),
        ("tkl_erode_south", "Erode South", "ஈரோடு தெற்கு", "Erode"),
        ("tkl_gobichettipalayam", "Gobichettipalayam", "கொபிச்செட்டிபாளையம்", "Erode"),
        ("tkl_perundurai", "Perundurai", "பெருந்துறை", "Erode"),
        ("tkl_bhavani", "Bhavani", "பவானி", "Erode"),
        # Thanjavur
        ("tkl_thanjavur", "Thanjavur", "தஞ்சாவூர்", "Thanjavur"),
        ("tkl_kumbakonam", "Kumbakonam", "கும்பகோணம்", "Thanjavur"),
        ("tkl_pattukkottai", "Pattukkottai", "பட்டுக்கோட்டை", "Thanjavur"),
        ("tkl_thiruvaiyaru", "Thiruvaiyaru", "திருவையாறு", "Thanjavur"),
        # Nilgiris
        ("tkl_udhagamandalam", "Udhagamandalam", "உதகமண்டலம்", "Nilgiris"),
        ("tkl_coonoor", "Coonoor", "கன்னூர்", "Nilgiris"),
        ("tkl_gudalur", "Gudalur", "குடலூர்", "Nilgiris"),
        ("tkl_kundah", "Kundah", "குந்தா", "Nilgiris"),
        # Trichy
        ("tkl_trichy_north", "Trichy North", "திருச்சி வடக்கு", "Trichy"),
        ("tkl_trichy_south", "Trichy South", "திருச்சி தெற்கு", "Trichy"),
        ("tkl_lalgudi", "Lalgudi", "லால்குடி", "Trichy"),
        ("tkl_thuraiyur", "Thuraiyur", "துறையூர்", "Trichy"),
        ("tkl_manachanallur", "Manachanallur", "மானச்சனல்லூர்", "Trichy"),
        # Dindigul
        ("tkl_dindigul", "Dindigul", "திண்டுக்கல்", "Dindigul"),
        ("tkl_natham", "Natham", "நாதம்", "Dindigul"),
        ("tkl_nilakottai", "Nilakottai", "நிலக்கோட்டை", "Dindigul"),
        ("tkl_vedasandur", "Vedasandur", "வேடசந்தூர்", "Dindigul"),
        ("tkl_palani", "Palani", "பழனி", "Dindigul"),
        # Theni
        ("tkl_theni", "Theni", "தேனி", "Theni"),
        ("tkl_bodinayakkanur", "Bodinayakkanur", "போடிநாயக்கனூர்", "Theni"),
        ("tkl_periyakulam", "Periyakulam", "பெரியகுளம்", "Theni"),
        ("tkl_uttamapalayam", "Uttamapalayam", "உத்தமபாளையம்", "Theni"),
        # Chennai
        ("tkl_chennai_north", "Chennai North", "சென்னை வடக்கு", "Chennai"),
        ("tkl_chennai_central", "Chennai Central", "சென்னை மையம்", "Chennai"),
        ("tkl_chennai_south", "Chennai South", "சென்னை தெற்கு", "Chennai"),
        ("tkl_ambattur", "Ambattur", "ஆம்பத்தூர்", "Chennai"),
        ("tkl_tambaram", "Tambaram", "தமபரம்", "Chennai"),
    ]
    for tid, name, nameTa, district in talukas:
        try:
            safe_insert(db, "talukas", tid, {
                "name": name, "nameTa": nameTa, "district": district, "active": True,
            })
            print(f"  ✅ {name} ({district})")
        except Exception as e:
            print(f"  ❌ {name}: {e}")


def seed_municipalities(db):
    print("\n🏘️  Seeding municipalities and panchayats...")
    municipalities = [
        # Coimbatore - North Taluk
        ("mun_coimbatore_corp", "Coimbatore Corporation", "கோயம்புத்தூர் மாநகராட்சி", "Coimbatore", "Coimbatore North", "Corporation"),
        ("pan_vediapatti", "Vediapatti", "வேதியாப்பட்டி", "Coimbatore", "Coimbatore North", "Panchayat"),
        ("pan_saravanampatti", "Saravanampatti", "சரவணம்பட்டி", "Coimbatore", "Coimbatore North", "Panchayat"),
        # Coimbatore - South Taluk
        ("mun_coimbatore_south", "Coimbatore South", "கோயம்புத்தூர் தெற்கு", "Coimbatore", "Coimbatore South", "Municipality"),
        ("pan_sulur", "Sulur", "சூலூர்", "Coimbatore", "Coimbatore South", "Panchayat"),
        # Pollachi Taluk
        ("mun_pollachi", "Pollachi", "பொள்ளாச்சி", "Coimbatore", "Pollachi", "Municipality"),
        ("pan_kinathukadavu", "Kinathukadavu", "கிணத்துக்கடவு", "Coimbatore", "Pollachi", "Panchayat"),
        # Salem - North Taluk
        ("mun_salem_corp", "Salem Corporation", "சேலம் மாநகராட்சி", "Salem", "Salem North", "Corporation"),
        ("pan_kondalampatti", "Kondalampatti", "கொண்டலாம்பட்டி", "Salem", "Salem North", "Panchayat"),
        # Salem - South Taluk
        ("mun_salem_south", "Salem South", "சேலம் தெற்கு", "Salem", "Salem South", "Municipality"),
        ("pan_ammaipet", "Ammaipet", "அம்மையாபேட்டை", "Salem", "Salem South", "Panchayat"),
        # Attur Taluk
        ("mun_attur", "Attur", "ஆத்தூர்", "Salem", "Attur", "Municipality"),
        ("pan_kalladaikurichi", "Kalladaikurichi", "கல்லடைகுறிச்சி", "Salem", "Attur", "Panchayat"),
        # Mettur Taluk
        ("mun_mettur", "Mettur", "மேட்டூர்", "Salem", "Mettur", "Municipality"),
        # Madurai - North Taluk
        ("mun_madurai_corp", "Madurai Corporation", "மதுரை மாநகராட்சி", "Madurai", "Madurai North", "Corporation"),
        ("pan_melur_north", "Melur North", "மேலூர் வடக்கு", "Madurai", "Madurai North", "Panchayat"),
        # Madurai - South Taluk
        ("mun_madurai_south", "Madurai South", "மதுரை தெற்கு", "Madurai", "Madurai South", "Municipality"),
        ("pan_thirunagar", "Thirunagar", "திருநகர்", "Madurai", "Madurai South", "Panchayat"),
        # Melur Taluk
        ("mun_melur", "Melur", "மேலூர்", "Madurai", "Melur", "Municipality"),
        # Erode - North Taluk
        ("mun_erode_corp", "Erode Corporation", "ஈரோடு மாநகராட்சி", "Erode", "Erode North", "Corporation"),
        ("pan_perundurai_north", "Perundurai North", "பெருந்துறை வடக்கு", "Erode", "Erode North", "Panchayat"),
        # Erode - South Taluk
        ("mun_erode_south", "Erode South", "ஈரோடு தெற்கு", "Erode", "Erode South", "Municipality"),
        ("mun_gobichettipalayam", "Gobichettipalayam", "கொபிச்செட்டிபாளையம்", "Erode", "Erode South", "Municipality"),
        # Thanjavur
        ("mun_thanjavur_corp", "Thanjavur Corporation", "தஞ்சாவூர் மாநகராட்சி", "Thanjavur", "Thanjavur", "Corporation"),
        ("mun_kumbakonam", "Kumbakonam", "கும்பகோணம்", "Thanjavur", "Kumbakonam", "Municipality"),
        ("pan_thiruvaiyaru", "Thiruvaiyaru", "திருவையாறு", "Thanjavur", "Thiruvaiyaru", "Panchayat"),
        # Nilgiris
        ("mun_udhagamandalam", "Udhagamandalam", "உதகமண்டலம்", "Nilgiris", "Udhagamandalam", "Municipality"),
        ("mun_coonoor", "Coonoor", "கன்னூர்", "Nilgiris", "Coonoor", "Municipality"),
        ("pan_gudalur", "Gudalur", "குடலூர்", "Nilgiris", "Gudalur", "Panchayat"),
        # Trichy
        ("mun_trichy_corp", "Trichy Corporation", "திருச்சி மாநகராட்சி", "Trichy", "Trichy North", "Corporation"),
        ("mun_lalgudi", "Lalgudi", "லால்குடி", "Trichy", "Lalgudi", "Municipality"),
        ("pan_thuraiyur", "Thuraiyur", "துறையூர்", "Trichy", "Thuraiyur", "Panchayat"),
        # Dindigul
        ("mun_dindigul", "Dindigul", "திண்டுக்கல்", "Dindigul", "Dindigul", "Municipality"),
        ("mun_palani", "Palani", "பழனி", "Dindigul", "Palani", "Municipality"),
        ("pan_natham", "Natham", "நாதம்", "Dindigul", "Natham", "Panchayat"),
        # Theni
        ("mun_theni", "Theni", "தேனி", "Theni", "Theni", "Municipality"),
        ("mun_bodinayakkanur", "Bodinayakkanur", "போடிநாயக்கனூர்", "Theni", "Bodinayakkanur", "Municipality"),
        ("pan_periyakulam", "Periyakulam", "பெரியகுளம்", "Theni", "Periyakulam", "Panchayat"),
        # Chennai
        ("mun_chennai_corp", "Chennai Corporation", "சென்னை மாநகராட்சி", "Chennai", "Chennai Central", "Corporation"),
        ("mun_ambattur", "Ambattur", "ஆம்பத்தூர்", "Chennai", "Ambattur", "Municipality"),
        ("mun_tambaram", "Tambaram", "தமபரம்", "Chennai", "Tambaram", "Municipality"),
        ("pan_chennai_north_panch", "Chennai North Panchayat", "சென்னை வடக்கு ஊராட்சி", "Chennai", "Chennai North", "Panchayat"),
        ("pan_chennai_south_panch", "Chennai South Panchayat", "சென்னை தெற்கு ஊராட்சி", "Chennai", "Chennai South", "Panchayat"),
    ]
    for mid, name, nameTa, district, taluk, mtype in municipalities:
        try:
            safe_insert(db, "municipalities", mid, {
                "name": name, "nameTa": nameTa, "district": district,
                "taluk": taluk, "type": mtype, "active": True,
            })
            print(f"  ✅ {name} ({mtype}, {district})")
        except Exception as e:
            print(f"  ❌ {name}: {e}")


def main():
    print("=" * 60)
    print("  Agri Flow - Appwrite Seed (Admin Only)")
    print("=" * 60)

    client = Client()
    client.set_endpoint(APPWRITE_ENDPOINT)
    client.set_project(APPWRITE_PROJECT_ID)
    client.set_key(APPWRITE_API_KEY)

    db = Databases(client)
    users_svc = Users(client)

    try:
        seed_admin_user(users_svc, db)
        seed_categories(db)
        seed_districts(db)
        seed_talukas(db)
        seed_municipalities(db)
        seed_settings(db)

        print("\n" + "=" * 60)
        print("  ✅ Seeding complete!")
        print("=" * 60)
        print(f"\n  🔑 ADMIN: {ADMIN_EMAIL} / {ADMIN_PASSWORD}")
        print("\n  No demo users or products seeded.")
        print("  All other data (farmers, merchants, customers, products)")
        print("  must be created through the app.")
    except Exception as e:
        print(f"\n❌ Failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

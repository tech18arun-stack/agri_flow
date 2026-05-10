# AgriFlow - Scripts Documentation

## 📁 Overview

This folder contains all setup, migration, and utility scripts for the AgriFlow platform.

## 🔐 Environment Setup

### 1. Create `.env` file
```bash
# Copy the example file
cp .env.example .env

# Edit .env with your credentials
```

### 2. Required Variables
```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_API_KEY=your-api-key-here
APPWRITE_PROJECT_ID=your-project-id-here
APPWRITE_DATABASE_ID=agriflow_db
```

## 🚀 Quick Start

### Complete Setup (Recommended)
```bash
# Run the complete setup verifier
python verify_setup.py

# This will:
# ✅ Check environment variables
# ✅ Install dependencies
# ✅ Create database structure
# ✅ Run all migrations
# ✅ Verify collections
```

### Manual Setup
```bash
# Step 1: Install Python dependencies
pip install -r requirements.txt

# Step 2: Create database and collections
python setup_appwrite.py

# Step 3: Run migrations
cd migrations
python run_migrations.py

# Step 4: Seed sample data (optional)
python seed_appwrite.py
```

## 📜 Scripts List

### Main Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `setup_appwrite.py` | Creates database, collections, storage buckets | First-time setup |
| `seed_appwrite.py` | Populates database with sample data | Development/testing |
| `verify_setup.py` | Complete setup verification | After any setup step |
| `fix_permissions.py` | Fix users collection permissions | If registration fails |
| `cleanup_appwrite.py` | Clean up test/duplicate data | Maintenance |

### Migration Scripts

| Migration | Description | Fields/Collections Added |
|-----------|-------------|-------------------------|
| `001_core_features.py` | Core feature collections | transactions, inventory, reviews, addresses, wishlist, recently_viewed |
| `002_admin_platform.py` | Admin & platform features | notifications, banners, coupons, analytics, admin_settings, order_items, bids |
| `003_storage_fields.py` | Storage buckets & fields | 5 storage buckets + fields on products, orders, users |
| `004_fix_permissions.py` | Collection permissions | Permission fixes for all collections |
| `005_fix_product_attributes.py` | Product attributes | products.address, imageUrl, rating, reviews, lat, lng |
| `006_user_profile_fields.py` | User profile enhancements | users.phone, address, createdAt, updatedAt |

## 🔄 Migration System

### Run All Migrations
```bash
cd migrations
python run_migrations.py
```

### Run Specific Migration
```bash
# Run only migration 006
python run_migrations.py 6
```

### Migration Safety
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Skip existing** - Collections/fields that exist are skipped
- ✅ **Ordered execution** - Runs in sequence (001 → 002 → ...)
- ✅ **Error handling** - Stops on first failure

## 🗄️ Database Structure

### Core Collections (setup_appwrite.py)
- `users` - User accounts and profiles
- `talukas` - Taluka/sub-district locations
- `municipalities` - Municipality/city locations
- `products` - Farmer product listings
- `orders` - Customer orders
- `cart` - Shopping cart items
- `price_logs` - Historical price data
- `aggregated_prices` - Price statistics
- `price_trends` - Price trend data
- `categories` - Product categories
- `districts` - District locations
- `app_settings` - Platform settings
- `loi_requests` - Letter of Intent requests

### Feature Collections (migrations)
- `transactions` - P&L tracking
- `inventory` - Stock management
- `reviews` - Product reviews
- `addresses` - Delivery addresses
- `wishlist` - Saved products
- `recently_viewed` - View history
- `notifications` - Push notifications
- `banners` - Marketing banners
- `coupons` - Discount codes
- `analytics` - Event tracking
- `admin_settings` - Admin configuration
- `order_items` - Order line items
- `bids` - Price negotiations

### Storage Buckets
- `product_images` - Product photos
- `profile_images` - User profile photos
- `banner_images` - Banner images
- `review_images` - Review photos
- `document_uploads` - General documents

## 🛠️ Common Issues & Fixes

### Issue: Registration fails
```bash
# Fix users collection permissions
python fix_permissions.py
```

### Issue: Missing product attributes
```bash
# Run migration 005
cd migrations
python run_migrations.py 5
```

### Issue: User profile fields missing
```bash
# Run migration 006
cd migrations
python run_migrations.py 6
```

### Issue: Database not created
```bash
# Run complete setup
python setup_appwrite.py
```

## 📊 Collection Permissions

| Collection | Read | Create | Update | Delete |
|-----------|------|--------|--------|--------|
| users | Any | Any | Users | Users |
| products | Any | Users | Users | Users |
| orders | Any | Users | Users | Users |
| cart | Users | Users | Users | Users |
| price_logs | Any | Users | Users | Users |
| loi_requests | Any | Users | Users | Users |
| transactions | Users | Users | Users | Users |
| inventory | Users | Users | Users | Users |
| reviews | Any | Users | Users | Users |
| addresses | Users | Users | Users | Users |
| wishlist | Users | Users | Users | Users |

## 🔧 Development Workflow

### 1. Fresh Development Setup
```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Setup database
python setup_appwrite.py

# 3. Run migrations
cd migrations && python run_migrations.py

# 4. Seed sample data
cd .. && python seed_appwrite.py

# 5. Verify everything
python verify_setup.py
```

### 2. Adding New Features
```bash
# 1. Create new migration file
# migrations/007_your_feature.py

# 2. Add to MIGRATIONS list in run_migrations.py

# 3. Run the migration
python run_migrations.py 7

# 4. Update this README.md
```

### 3. Production Deployment
```bash
# 1. Backup database first (via Appwrite console)

# 2. Run migrations only
cd migrations && python run_migrations.py

# 3. Verify collections
cd .. && python verify_setup.py
```

## 📝 Migration Template

```python
"""
Migration XXX: Your Description
Date: YYYY-MM-DD
Description: Brief description of what this migration does
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

# Configuration
ENDPOINT = os.getenv("APPWRITE_ENDPOINT")
API_KEY = os.getenv("APPWRITE_API_KEY")
PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

def run():
    print("Migration XXX: Your Description")
    print("=" * 60)
    
    # Your migration logic here
    # Use safe_attr() and safe_index() helpers
    
    print("Migration XXX complete!")

if __name__ == "__main__":
    run()
```

## 🆘 Troubleshooting

### "Collection already exists"
- ✅ Normal - Migration will skip and continue
- This is expected behavior for idempotent migrations

### "Attribute already exists"
- ✅ Normal - Migration will skip and continue
- Means the field was already added

### "Permission denied"
- ❌ Check your API key in .env
- ❌ Ensure API key has proper permissions

### "Module not found"
```bash
# Reinstall dependencies
pip install -r requirements.txt --upgrade
```

## 📞 Support

- Check `migrations/README.md` for migration-specific help
- Review Appwrite console for collection/attribute status
- Check Flutter debug logs for app-side errors

---

**Last Updated**: 2026-04-11
**Version**: 1.0.0

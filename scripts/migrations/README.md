# AgriFlow Database Migrations

## Overview
This folder contains migration scripts to add new collections, fields, and storage buckets to the Appwrite database.

**Important**: These migrations DO NOT modify existing setup files. They only add new collections and fields.

## Migration List

| # | File | Description | Collections Added |
|---|------|-------------|-------------------|
| 001 | `001_core_features.py` | Core feature collections for merchant/customer features | transactions, inventory, reviews, addresses, wishlist, recently_viewed |
| 002 | `002_admin_platform.py` | Admin management and platform features | notifications, banners, coupons, analytics, admin_settings, order_items, bids |
| 003 | `003_storage_fields.py` | Storage buckets and missing fields on existing collections | Storage buckets + fields on products, orders, users, aggregated_prices |
| 004 | `004_fix_permissions.py` | Fix collection permissions for all tables | Permission updates for all collections |
| 005 | `005_fix_product_attributes.py` | Add missing product attributes | products.address, products.imageUrl, products.rating, products.reviews, products.lat, products.lng |
| 006 | `006_user_profile_fields.py` | Add user profile enhancement fields | users.phone, users.address, users.createdAt, users.updatedAt |

## How to Run

### Prerequisites
1. Ensure `.env` file exists in `scripts/` directory with:
   ```
   APPWRITE_ENDPOINT=https://api.websitescorp.com/v1
   APPWRITE_API_KEY=your-api-key
   APPWRITE_PROJECT_ID=your-project-id
   APPWRITE_DATABASE_ID=agriflow_db
   ```

2. Install dependencies:
   ```bash
   pip install appwrite python-dotenv
   ```

### Run All Migrations
```bash
cd scripts/migrations
python run_migrations.py
```

### Run Specific Migration
```bash
# Run only migration 001
python run_migrations.py 1

# Run only migration 002
python run_migrations.py 2

# Run only migration 003
python run_migrations.py 3
```

## What Each Migration Does

### Migration 001: Core Feature Collections
Adds 6 collections needed for:
- **transactions**: Merchant buy/sell transaction tracking (P&L screen)
- **inventory**: Merchant stock management (inventory screen)
- **reviews**: Product reviews and ratings
- **addresses**: User delivery addresses for checkout
- **wishlist**: Customer wishlist items (persisted to DB)
- **recently_viewed**: Product view tracking

### Migration 002: Admin & Platform Features
Adds 7 collections needed for:
- **notifications**: Platform-wide announcements and alerts
- **banners**: Homepage promotional banners (with 2 default banners seeded)
- **coupons**: Discount codes and promotional offers
- **analytics**: Event tracking and user behavior
- **admin_settings**: Platform configuration (commission rate, payment methods, etc.)
- **order_items**: Individual order line items
- **bids**: Price negotiation between buyers and sellers

### Migration 003: Storage Buckets & Missing Fields
Adds:
- **5 Storage Buckets**:
  - `product_images` - Product photo uploads
  - `profile_images` - User profile photo uploads
  - `banner_images` - Homepage banner images
  - `review_images` - Review photo uploads
  - `document_uploads` - General document uploads
- **Missing Fields** on existing collections:
  - `products.status` - Product moderation status
  - `orders.totalAmount` - Alias for admin stats compatibility
  - `users.updatedAt` - Last profile update time
  - `users.lastLoginAt` - Last login timestamp
  - `aggregated_prices.demand` - Demand level indicator

## Safety Features
- All migrations are **idempotent** - safe to run multiple times
- Collections that already exist are **skipped**
- Attributes that already exist are **skipped**
- Indices that already exist are **skipped**
- Seed data is only added for new collections

## Migration Status Tracking
The migrations are designed to be run in order. Each migration adds independent collections, so they can be run individually if needed.

## Adding New Migrations
To create a new migration:
1. Create a new file: `004_your_migration_name.py`
2. Copy the structure from an existing migration
3. Update the `MIGRATIONS` list in `run_migrations.py`
4. Add your collection definitions and seed data

## Collections Already in setup_appwrite.py (NOT touched by migrations)
- users
- talukas
- municipalities
- products
- orders
- cart
- price_logs
- aggregated_prices
- price_trends
- categories
- districts
- app_settings
- loi_requests

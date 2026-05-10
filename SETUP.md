# Agri Flow - Setup Guide

## 🔧 Prerequisites

- **Flutter SDK** 3.1+ installed
- **Python 3.8+** installed
- **Appwrite account** (free at [cloud.appwrite.io](https://cloud.appwrite.io))

---

## 📦 Step 1: Appwrite Project Setup

1. Go to [cloud.appwrite.io](https://cloud.appwrite.io) and create a new project called "Agri Flow"
2. Note your **Project ID** from Settings → General
3. Create an **API Key** from Settings → API Keys (give it all permissions)

---

## 🐍 Step 2: Run Python Setup Scripts

```bash
cd scripts

# Install Python dependencies
pip install -r requirements.txt

# Set environment variables (Windows)
set APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
set APPWRITE_PROJECT_ID=your-project-id
set APPWRITE_API_KEY=your-api-key

# Or use a .env file (copy from .env.example)
copy .env.example .env
# Edit .env with your actual values

# Step 1: Create database, collections, indexes, storage buckets
python setup_appwrite.py

# Step 2: Seed mock data
python seed_appwrite.py
```

### What `setup_appwrite.py` Creates:

| Resource | ID | Purpose |
|----------|-----|---------|
| Database | `agriflow_db` | Main database |
| Collection | `users` | User profiles with role/district |
| Collection | `products` | Product listings |
| Collection | `price_logs` | **Every price entry** from farmers |
| Collection | `aggregated_prices` | **Precomputed** avg/min/max/demand |
| Collection | `price_trends` | Daily historical snapshots |
| Collection | `orders` | Customer orders |
| Collection | `cart` | Shopping carts |
| Collection | `bids` | Merchant bidding |
| Collection | `reviews` | Product reviews |
| Collection | `notifications` | Push notifications |
| Bucket | `product_images` | Product image storage |
| Bucket | `profile_images` | Profile image storage |

### Indexes Created:
- `productId + district` → fast price lookups
- `category` → filtered product browsing
- `farmerId` → farmer's own products
- `createdAt` → chronological sorting
- Fulltext on `name` → search functionality

---

## 📱 Step 3: Flutter App Setup

```bash
cd ..  # back to agri-flow-flutter root

# Install Flutter dependencies
flutter pub get

# Run with your Appwrite config
flutter run --dart-define=APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
            --dart-define=APPWRITE_PROJECT_ID=your-project-id

# Or on Chrome (web admin view on wide screens)
flutter run -d chrome
```

---

## ⚙️ Step 4: Deploy Appwrite Functions

### Function 1: Update Aggregated Prices

1. Go to Appwrite Console → Functions → Create Function
2. Name: `update_aggregated_prices`
3. Runtime: Node.js 18.0
4. Deploy the code from `appwrite_functions/update_aggregated_prices.js`
5. Set environment variables:
   ```
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   APPWRITE_PROJECT_ID=your-project-id
   APPWRITE_API_KEY=your-api-key
   AGRIFLOW_DB_ID=agriflow_db
   PRICE_LOGS_COLLECTION_ID=price_logs
   AGGREGATED_PRICES_COLLECTION_ID=aggregated_prices
   PRICE_TRENDS_COLLECTION_ID=price_trends
   ```
6. Set trigger: Database Event → `price_logs` collection → create document

### Function 2: Daily Trend Update (Cron)

1. Create another function: `daily_trend_update`
2. Same runtime and environment variables
3. Set schedule: `0 0 * * *` (midnight daily)

---

## 🔄 Data Flow (Complete)

```
Farmer adds product in Flutter app
    ↓
ProductService.addProduct() → Appwrite products collection
    ↓
PriceEngineService.logPrice() → Appwrite price_logs collection
    ↓
Appwrite Function triggers automatically
    ↓
Calculates avg/min/max/demand for product+district
    ↓
Updates aggregated_prices collection
    ↓
Updates price_trends collection (daily snapshot)
    ↓
Flutter app receives Realtime event
    ↓
UI updates: price comparison, trends, suggestions
```

---

## 📊 Price Engine Collections Explained

### `price_logs` (Raw Data)
Every time a farmer adds or updates a product price, it's logged here. This is your **historical mandi data**.

```json
{
  "productId": "tomato",
  "productName": "Tomato",
  "farmerId": "farmer_01",
  "farmerName": "Muthu K.",
  "price": 28.0,
  "quantity": 100,
  "unit": "kg",
  "district": "Salem",
  "createdAt": "2026-04-07T10:30:00Z"
}
```

### `aggregated_prices` (Precomputed - Fast Reads)
Updated automatically by Appwrite Function. Used by UI for instant price display.

```json
{
  "productId": "tomato",
  "productName": "Tomato",
  "district": "Salem",
  "avgPrice": 32.0,
  "minPrice": 28.0,
  "maxPrice": 35.0,
  "totalQuantity": 450.0,
  "sellerCount": 2,
  "demand": "high",
  "lastUpdated": "2026-04-07T10:30:00Z"
}
```

### `price_trends` (Historical Chart Data)
Daily snapshots used for sparkline charts. Updated by cron function.

```json
{
  "productId": "tomato",
  "productName": "Tomato",
  "district": "Salem",
  "date": "2026-04-07",
  "avgPrice": 32.0
}
```

---

## 🔐 Security Rules (Appwrite Console → Collections → Permissions)

### Recommended Permissions:

| Collection | Read | Create | Update | Delete |
|-----------|------|--------|--------|--------|
| `users` | `users:read` | `users:write` (own) | `users:write` (own) | `admin:write` |
| `products` | Any | `farmers:write` | `farmers:write` (own) | `farmers:write` (own) |
| `price_logs` | Any | `farmers:write` | `farmers:write` (own) | `farmers:write` (own) |
| `aggregated_prices` | Any | `system:write` | `system:write` | `system:write` |
| `price_trends` | Any | `system:write` | `system:write` | `system:write` |
| `orders` | `users:read` (own) | `customers:write` | `farmers:write` (own orders) | `admin:write` |

---

## 🚀 Quick Commands

```bash
# Setup everything
pip install -r scripts/requirements.txt
python scripts/setup_appwrite.py
python scripts/seed_appwrite.py

# Run Flutter app
flutter pub get
flutter run -d chrome   # Web (admin view on wide screens)
flutter run             # Mobile emulator

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

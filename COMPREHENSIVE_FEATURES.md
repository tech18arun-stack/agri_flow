# Farm Flow - Comprehensive Feature List

This document provides a consolidated overview of all features currently available in the Farm Flow platform, as analyzed from the project's documentation and codebase.

---

## 🏗️ Core Platform Features

### 1. Bilingual Support (EN/TA)
- Full support for **English** and **Tamil**.
- 200+ localized strings across all screens.
- Dynamic language toggle available in onboarding and profile.

### 2. Role-Based Architecture
- **Customer**: Focus on browsing and buying fresh produce.
- **Farmer**: Tools for listing harvests and analyzing market prices.
- **Merchant**: Wholesale buying, inventory, and resale management.
- **Admin**: Platform moderation and catalog oversight.
- **Price Updater**: Specialized role for maintaining flower market prices.

### 3. Modern Design System
- **Material 3**: Fully implemented MD3 color tokens and themes.
- **Rich Aesthetics**: Glassmorphism, smooth gradients, and micro-animations.
- **Responsive Layouts**: Content adapts seamlessly from mobile screens to wide-screen web admin panels.

### 4. Interactive Pre-Login Experience
- **Onboarding**: Multi-slide introduction with bilingual support.
- **Role Selection & Preview**: Allows users to explore role-specific dashboards (Farmer, Merchant, Customer) before creating an account.

---

## 🛒 Customer Portal

### Home & Browsing
- **Smart Search**: Voice-enabled search with real-time suggestions.
- **Promotional Banners**: Auto-scrolling carousel with call-to-action buttons.
- **Category Browsing**: 6 major categories with custom iconography and color coding.
- **Quick Filters**: Trending, Top Rated, Organic, Free Delivery, and Nearby.
- **Recently Viewed**: Localized history of viewed products.

### Product Experience
- **Advanced Filtering**: Filter by price range, location, and organic status.
- **Sorting**: Sort by popularity, price (L-H / H-L), newest, and rating.
- **Wishlist**: Persistent local storage for saved items with a dedicated management screen.
- **Product Details**:
    - Live price comparison with similar products.
    - Verified farmer information.
    - Farm location visualization via AgriMap.
    - Integrated quantity selector and cart actions.

### Cart & Checkout
- **Smart Cart**: Subtotal calculation with automated shipping and platform fees.
- **Checkout Flow**: Integrated order summary and confirmation screens.

---

## 👨‍🌾 Farmer Portal

### Harvest Management
- **Smart Add Product**:
    - Bilingual name inputs (EN/TA).
    - Intelligent unit selection (12+ units with Tamil support).
    - **GPS Location Capture**: One-tap farm location tagging.
    - **Map Picker**: Interactive map for precise farm address selection.
- **My Products**: Real-time stock status tracking (In Stock / Low / Out).

### Market Intelligence (Smart Mandi Engine)
- **Live Market Prices**: Compare district-specific prices with min/max/avg stats.
- **Price Comparison**: Visual bar charts comparing farmer's price vs. market average.
- **Trending Analysis**: Identifies high-demand products in the farmer's area.
- **Best Sellers**: Revenue and sales performance analytics with achievement badges.

### Sales & LOIs
- **Order Tracking**: Manage incoming orders from customers.
- **LOI Requests**: Receive and manage Letter of Intent requests from merchants for bulk purchases.

---

## 🏪 Merchant Portal

### Sourcing & Inventory
- **Bulk Listings**: Search and filter wholesale harvests across all districts.
- **LOI System**: Send formal purchase offers (Letters of Intent) to farmers.
- **Wholesale Hub**: Find the best deals with "You Save" percentage calculations.
- **Inventory Tracking**: 
    - Real-time stock monitoring.
    - Freshness tracking (Aging indicator based on purchase date).
    - Easy "List for Sale" workflow.

### Financial Tools
- **Profit & Loss Tracking**: 
    - Comprehensive dashboard for revenue, costs, and net profit.
    - Transaction history with color-coded Buy/Sell indicators.
    - Time-range filtering (Week/Month/Year).
- **Margin Calculator**: Pre-trade tool to calculate net profit, per-unit profit, and break-even price including transport and overheads.

---

## 🛡️ Admin Portal (Web-Only)

- **Dashboard**: Real-time stats for user growth, sales volume, and moderation.
- **User Moderation**: Bulk activate/suspend/delete users across all roles.
- **Product Moderation**: Approve or reject new listings before they go live.
- **Catalog Management**: Centralized control over categories, districts, and platform-wide product templates.

---

## 🧠 Intelligent Systems

### 1. Smart Mandi Price Engine
- **Aggregated Prices**: Real-time calculation of market stats per product/district.
- **Demand Indicators**: High/Moderate/Low demand alerts based on supply data.
- **Price Forecasting**: AI-driven price suggestions based on 7-day trends.

### 2. Image URL System
- **Universal Support**: Support for Google Drive, Dropbox, OneDrive, and direct URLs.
- **Auto-Normalization**: Automatically converts cloud sharing links to direct download links.
- **Caching**: Local image caching for faster performance and offline viewing.

### 3. Location & Mapping
- **AgriMap**: Custom map implementation for farm location display.
- **Nearby Engine**: Haversine-based distance calculation to find closest producers.

---

## ⚙️ Backend & Automation

### Automated Setup Scripts
- **setup_appwrite.py**: Full database and collection initialization.
- **setup_all_features.py**: Advanced script for complex features like LOIs, Inventory, and P&L.
- **seed_appwrite.py**: Populates the platform with realistic sample data.

### Migration System
- **Idempotent Migrations**: Versioned scripts (001-007) that can be safely re-run.
- **Permission Fixer**: Automated correction of collection permissions for secure access.

---

*Last Updated: May 9, 2026*

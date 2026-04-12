# Agri Flow - Flutter App

Tamil Nadu Agricultural Marketplace — **Responsive Flutter app** with full **English + தமிழ்** bilingual support + **Smart Mandi Price Engine** 🧠

## 📱 Architecture

```
lib/
├── main.dart                          # Entry + responsive LayoutBuilder
├── core/
│   ├── constants/
│   │   ├── colors.dart                # Full MD3 color tokens
│   │   └── strings.dart               # 200+ bilingual EN/TA strings
│   └── theme/
│       └── app_theme.dart             # Material 3 ThemeData
├── data/
│   ├── models.dart                    # UserModel, ProductModel, CartItem
│   └── price_engine.dart              # PriceLog, AggregatedPrice, PriceTrend, DistrictPrice
├── providers/
│   ├── providers.dart                 # AuthProvider, CartProvider, ProductProvider
│   └── price_engine_provider.dart     # 🧠 Smart Mandi Engine
├── widgets/
│   ├── shared_widgets.dart            # BiLabel, PrimaryButton, StatCard, StatusBadge
│   └── price_widgets.dart             # LivePriceComparison, MiniTrendChart, DistrictPriceMap, PriceSuggestion
└── ui/
    ├── mobile_layout.dart             # Mobile app shell (role-based routing)
    ├── web_admin.dart                 # Web admin (sidebar + DataTable)
    └── screens/
        ├── landing/landing_screen.dart
        ├── auth/login_screen.dart
        ├── farmer/farmer_screen.dart        # + Price Suggestion on Add Product
        ├── merchant/merchant_screen.dart    # + Market Prices tab (4 tabs)
        ├── customer/customer_screen.dart    # + Live Price Comparison on tap
        └── admin/                           # Web-only dashboard, users, moderation
```

## 🧠 Smart Mandi Price Engine

| Feature | Where | What |
|---------|-------|------|
| **Live Price Comparison** | Customer: tap any product | Shows all sellers sorted cheapest first |
| **Price Trends** | Customer + Merchant tabs | 7-day sparkline with % change |
| **District Price Map** | All screens | Compare prices across all districts |
| **AI Price Suggestions** | Farmer: Add Product form | Recommends price based on market data |
| **Demand Indicators** | All screens | "High demand" alerts based on supply/demand |
| **Smart Insights** | Farmer form | "Price increased 12% this week" |

### Data Flow
```
Farmer adds product → PriceLogs → Appwrite Function → AggregatedPrices + PriceTrends → UI updates
```

### Appwrite Collections
| Collection | Purpose |
|-----------|---------|
| `price_logs` | Every price entry from farmers |
| `aggregated_prices` | Precomputed avg/min/max/demand per product+district |
| `price_trends` | Daily historical snapshots for charts |

## 🚀 How to Run

```bash
cd "c:\Users\tech1\OneDrive\Desktop\framer website\agri-flow-flutter"
flutter create . --project-name agri_flow
flutter pub get
flutter run -d chrome   # Wide → Admin panel
flutter run             # Narrow → Mobile app
```

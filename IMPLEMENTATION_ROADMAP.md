# AgriFlow App - Implementation Roadmap

## 📊 Current Status
**Last Updated**: April 2026  
**Project**: AgriFlow - Agricultural E-Commerce Platform  
**Framework**: Flutter + Appwrite Backend

---

## 🎯 Priority 1: Critical Missing Features

### 1. Customer Experience
- [ ] **Wishlist Functionality**
  - Create `WishlistProvider` with Appwrite persistence
  - Build `WishlistScreen` with add/remove/toggle
  - Add wishlist icon to product cards with heart toggle
  - Navigate from customer home screen

- [ ] **Search Screen**
  - Create `SearchScreen` with recent searches
  - Implement search suggestions/autocomplete
  - Add voice search functionality
  - Register `/search` route in `main.dart`

- [ ] **Recently Viewed Products**
  - Create `RecentlyViewedProvider` (SharedPreferences or Appwrite)
  - Track product views in product detail screen
  - Build `RecentlyViewedScreen` with horizontal scroll
  - Register `/recently-viewed` route

- [ ] **Product Reviews & Ratings**
  - Create `ReviewProvider` with Appwrite CRUD
  - Build review submission form in product detail
  - Display reviews with star ratings
  - Implement review moderation for admin

### 2. Cart & Checkout
- [ ] **Cart Persistence**
  - Update `CartProvider` to save to Appwrite database
  - Load cart on app startup
  - Sync cart across devices

- [ ] **Checkout Flow**
  - Create `CheckoutScreen` with order summary
  - Build address selection/creation form
  - Implement payment method selection (COD/UPI)
  - Create order confirmation screen
  - Register `/checkout` and `/order_confirmation` routes

- [ ] **Address Management**
  - Create `AddressProvider` with CRUD operations
  - Build `AddressBookScreen` with add/edit/delete
  - Integrate with checkout flow
  - Add location picker for addresses

- [ ] **Order History & Tracking**
  - Create `CustomerOrdersScreen` showing all orders
  - Build order detail screen with status tracking
  - Add order cancellation functionality
  - Register `/orders` and `/order_detail` routes

### 3. User Profile & Account
- [ ] **Profile Management**
  - Create `ProfileScreen` with edit form
  - Update name, email, district, taluk, municipality
  - Add profile photo upload to Appwrite Storage
  - Implement password change functionality

- [ ] **Authentication Improvements**
  - Add "Forgot Password" flow with email reset
  - Implement email verification on signup
  - Add session timeout handling
  - Add biometric login (fingerprint/face ID)

### 4. Farmer Features
- [ ] **Product Management**
  - Add product editing capability
  - Add product deletion capability
  - Add image upload for products (Appwrite Storage)
  - Implement bulk product actions

- [ ] **Order Fulfillment**
  - Build order detail screen for farmers
  - Add status update buttons (pending → confirmed → shipped → delivered)
  - Add delivery notes/tracking info
  - Implement order cancellation with reason

- [ ] **Revenue Analytics**
  - Create charts for revenue over time
  - Show top-selling products
  - Display monthly/yearly comparisons
  - Add export functionality (CSV/PDF)

### 5. Merchant Features
- [ ] **Inventory Management (Backend Integration)**
  - Replace mock data in `InventoryManagementScreen` with real Appwrite data
  - Create `InventoryProvider` with CRUD operations
  - Track purchased stock from farmers
  - Add stock quantity updates

- [ ] **Selling Screen (Backend Integration)**
  - Replace mock data in `SellingScreen` with real inventory
  - Connect listing creation to products collection
  - Add merchant-specific product listings
  - Track merchant sales

- [ ] **Profit/Loss Tracking (Backend Integration)**
  - Replace mock transactions in `ProfitLossTrackingScreen`
  - Create `TransactionProvider` with Appwrite integration
  - Track all buy/sell transactions
  - Generate real profit/loss reports

### 6. Admin Panel - Comprehensive Features

#### User Management
- [ ] Add user search functionality (currently UI only)
- [ ] Implement role filter (currently UI only)
- [ ] Implement status filter (currently UI only)
- [ ] Add bulk user actions (activate/suspend/delete)
- [ ] Add user detail view with full activity history
- [ ] Export users to CSV

#### Order Management
- [ ] Create `AdminOrderManagementScreen`
- [ ] View all platform orders
- [ ] Filter by status, user, date range
- [ ] Manually update order status
- [ ] Resolve order disputes
- [ ] Export orders report

#### Product Moderation
- [ ] Add product search in moderation queue
- [ ] Add filter by category, farmer, date
- [ ] View product details before approve/reject
- [ ] Add rejection reason/notes
- [ ] Bulk approve/reject products
- [ ] Flagged products review

#### Financial Reports
- [ ] Create `AdminFinancialReportsScreen`
- [ ] Platform revenue dashboard
- [ ] Transaction history
- [ ] Commission/fee tracking
- [ ] Monthly/yearly revenue charts
- [ ] Payout management for farmers/merchants
- [ ] Tax reporting

#### Platform Settings
- [ ] Create `AdminSettingsScreen`
- [ ] Platform commission rate configuration
- [ ] Payment gateway settings
- [ ] Email/SMS notification templates
- [ ] Platform fee structure
- [ ] Maintenance mode toggle
- [ ] API rate limiting configuration

#### Content Management
- [ ] Create `AdminContentManagementScreen`
- [ ] Manage homepage banners (add/edit/delete/reorder)
- [ ] Manage categories (add/edit/delete, icons, colors)
- [ ] Manage promotional offers
- [ ] Announcement broadcast to users
- [ ] Push notification management

#### Notifications & Announcements
- [ ] Create `AdminNotificationsScreen`
- [ ] Send platform-wide announcements
- [ ] Target specific user roles
- [ ] Schedule notifications
- [ ] Notification history
- [ ] Push notification integration

#### Analytics Dashboard
- [ ] Add charts/graphs to `AdminDashboardScreen`
- [ ] User growth over time
- [ ] Sales volume trends
- [ ] Product category distribution
- [ ] Geographic heat map
- [ ] Peak activity times

---

## 🧹 Priority 2: Code Cleanup & Optimization

### 1. Remove Unused Files
- [ ] **Delete** `lib/widgets/price_widgets.dart` (not imported anywhere)
- [ ] **Delete** `lib/services/product_service.dart` (bypassed by ProductProvider)
- [ ] **Delete** `lib/services/price_engine_service.dart` (bypassed by PriceEngineProvider)
- [ ] **Delete** `lib/providers/map_provider.dart` (registered but never consumed)
- [ ] **Delete** `lib/ui/screens/customer/customer_screen_backup.dart` (if exists)

### 2. Fix Navigation Routes
Add missing routes to `main.dart`:
```dart
'/search': (context) => const SearchScreen(),
'/categories': (context) => const CategoriesBrowsingScreen(),
'/trending': (context) => const TrendingAndBestSellersScreen(),
'/deals': (context) => const DealsAndOffersScreen(),
'/products': (context) => const AllProductsScreen(),
'/recently-viewed': (context) => const RecentlyViewedScreen(),
'/category_products': (context) => const CategoryProductsScreen(),
'/wishlist': (context) => const WishlistScreen(),
'/checkout': (context) => const CheckoutScreen(),
'/order_confirmation': (context) => const OrderConfirmationScreen(),
'/orders': (context) => const CustomerOrdersScreen(),
'/order_detail': (context) => const OrderDetailScreen(),
'/profile': (context) => const ProfileScreen(),
'/addresses': (context) => const AddressBookScreen(),
'/reviews': (context) => const ReviewsScreen(),
```

### 3. Fix Deprecated Code
- [ ] Replace all `withOpacity` with `withValues(alpha:)` (16 instances)
- [ ] Replace `value` with `initialValue` in DropdownButtonFormField (2 instances)
- [ ] Replace `tileSize` with `tileDimension` in AgriMap
- [ ] Replace `activeColor` with `activeThumbColor` in switches

### 4. Remove Unused Imports
- [ ] `customer/features/all_products_screen.dart` - Remove unused imports
- [ ] `customer/features/customer_home_screen.dart` - Remove unused `cart` variable
- [ ] `merchant/features/wholesale_buying_screen.dart` - Remove unused `auth` variable
- [ ] Multiple files - Remove unused `L` (strings) imports

### 5. Fix Warnings
- [ ] Add curly braces to if statements (best_sellers_screen.dart)
- [ ] Make `_PreviewRow` lowerCamelCase (selling_screen.dart)
- [ ] Remove unused `_isEditing` field (selling_screen.dart)
- [ ] Fix `const` evaluation in market_widgets.dart

---

## 🔐 Priority 3: Security & Production Readiness

### 1. Security Improvements
- [ ] **Remove exposed MapTiler API key** in `map_service.dart`
- [ ] Implement rate limiting on API calls
- [ ] Add input validation/sanitization on all forms
- [ ] Implement secure token storage
- [ ] Add session timeout with auto-logout
- [ ] Implement CSRF protection

### 2. Error Handling
- [ ] Add global error boundary
- [ ] Implement retry logic for failed API calls
- [ ] Add offline mode with local caching
- [ ] Show user-friendly error messages
- [ ] Add error logging/crash reporting (Sentry/Crashlytics)

### 3. Performance Optimization
- [ ] Implement image caching
- [ ] Add pagination for large lists
- [ ] Optimize product list rendering (use ListView.builder everywhere)
- [ ] Implement lazy loading for images
- [ ] Reduce unnecessary rebuilds
- [ ] Add loading skeletons/shimmers

### 4. Testing
- [ ] Write unit tests for all providers
- [ ] Write widget tests for critical screens
- [ ] Write integration tests for checkout flow
- [ ] Test on multiple screen sizes
- [ ] Test on both Android and iOS

---

## 🚀 Priority 4: Enhanced Features

### 1. Payment Integration
- [ ] Integrate Razorpay/Stripe for payments
- [ ] Add UPI payment support
- [ ] Add wallet functionality
- [ ] Implement refund processing
- [ ] Payment receipt generation

### 2. Real-time Features
- [ ] Implement real-time order status updates
- [ ] Live price updates for market prices
- [ ] Real-time notifications
- [ ] Chat/messaging between users
- [ ] Live order tracking

### 3. Advanced Features
- [ ] **Recommendation Engine**
  - ML-based product recommendations
  - "Customers also bought" section
  - Personalized homepage per user

- [ ] **Loyalty Program**
  - Points system for purchases
  - Tier-based benefits
  - Referral rewards

- [ ] **Multi-language Support**
  - Complete Tamil translation
  - Hindi language support
  - Dynamic language switching

- [ ] **Push Notifications**
  - Firebase Cloud Messaging integration
  - Order status notifications
  - Price drop alerts
  - New product alerts

- [ ] **Advanced Search**
  - Elasticsearch integration
  - Fuzzy matching
  - Voice search
  - Image search (upload photo to find products)

- [ ] **Delivery Integration**
  - Third-party delivery API integration
  - Real-time delivery tracking
  - Delivery person assignment
  - ETA calculation

---

## 📋 Priority 5: Documentation & Deployment

### 1. Documentation
- [ ] API documentation
- [ ] Setup guide for new developers
- [ ] Architecture decision records
- [ ] Component documentation
- [ ] Deployment guide

### 2. CI/CD
- [ ] Set up GitHub Actions/GitLab CI
- [ ] Automated testing on PR
- [ ] Automated builds
- [ ] Staging environment
- [ ] Production deployment pipeline

### 3. App Store Preparation
- [ ] App icons (all sizes)
- [ ] Screenshots for all screens
- [ ] App store descriptions
- [ ] Privacy policy
- [ ] Terms of service

---

## 📊 Feature Completion Status

| Module | Status | Completion |
|--------|--------|------------|
| **Customer Portal** | 🟡 In Progress | 70% |
| - Home Screen | ✅ Complete | 100% |
| - Product Listing | ✅ Complete | 100% |
| - Deals & Offers | 🟡 Mock Data | 60% |
| - Trending/Best Sellers | ✅ Complete | 100% |
| - Categories | ✅ Complete | 100% |
| - Wishlist | ❌ Not Started | 0% |
| - Search | ❌ Not Started | 0% |
| - Cart/Checkout | ❌ Not Started | 0% |
| - Order History | ❌ Not Started | 0% |
| - Profile | ❌ Not Started | 0% |
| **Farmer Portal** | 🟡 In Progress | 75% |
| - Dashboard | ✅ Complete | 100% |
| - Add Product | ✅ Complete | 100% |
| - My Products | ✅ Complete | 100% |
| - Market Prices | ✅ Complete | 100% |
| - Price Comparison | ✅ Complete | 100% |
| - Trending Products | ✅ Complete | 100% |
| - Best Sellers | ✅ Complete | 100% |
| - Orders | 🟡 Basic | 40% |
| - Product Edit/Delete | ❌ Not Started | 0% |
| - Image Upload | ❌ Not Started | 0% |
| **Merchant Portal** | 🟡 In Progress | 65% |
| - Wholesale Buying | ✅ Complete | 100% |
| - Inventory | ❌ Mock Data | 30% |
| - Selling | ❌ Mock Data | 30% |
| - P&L Tracking | ❌ Mock Data | 30% |
| - Margin Calculator | ✅ Complete | 100% |
| - Market Prices | ✅ Complete | 100% |
| **Admin Portal** | 🟡 In Progress | 50% |
| - Dashboard | ✅ Complete | 100% |
| - User Management | 🟡 Basic | 60% |
| - Order Management | ❌ Not Started | 0% |
| - Product Moderation | 🟡 Basic | 50% |
| - Financial Reports | ❌ Not Started | 0% |
| - Platform Settings | ❌ Not Started | 0% |
| - Content Management | ❌ Not Started | 0% |
| - Analytics | ❌ Not Started | 0% |

---

## 🎯 Quick Wins (Easy Implementations)

1. **Fix Navigation Routes** - 30 minutes
2. **Remove unused files** - 15 minutes
3. **Replace deprecated code** - 1 hour
4. **Add wishlist functionality** - 2 hours
5. **Create search screen** - 3 hours
6. **Add recently viewed** - 2 hours
7. **Profile screen** - 3 hours
8. **Order history screen** - 4 hours

---

## 📝 Notes

### Mock Data That Needs Backend Integration
- `InventoryManagementScreen` - 2 hardcoded items
- `SellingScreen` - 2 hardcoded items
- `ProfitLossTrackingScreen` - 4 hardcoded transactions
- `DealsAndOffersScreen` - Fake discount calculations
- Weather card in farmer dashboard - Static data

### Appwrite Collections Ready But Unused
- `cart` - Cart persistence not implemented
- `transactions` - No transaction tracking
- `reviews` - No review system
- `notifications` - No notification system
- `product_images` bucket - No image upload
- `profile_images` bucket - No profile photos

### Architecture Decisions
- Use Provider for state management (consider Riverpod for future)
- Appwrite as backend (BaaS)
- No local database currently (consider Hive/SQLite for offline)
- All providers extend ChangeNotifier

---

## 🔗 Useful Resources

- [Appwrite Documentation](https://appwrite.io/docs)
- [Flutter Provider Package](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://m3.material.io/)
- [Flutter Best Practices](https://docs.flutter.dev/guides)

---

**Last Reviewed**: April 2026  
**Next Review**: After Priority 1 completion

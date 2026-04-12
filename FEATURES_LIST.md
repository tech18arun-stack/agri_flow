# AgriFlow - Complete Feature Inventory

---

## Customer Portal

### Tab 1: Home (`CustomerHomeScreen`)

#### Search Bar
- Search input with placeholder "Search for fresh produce..."
- Voice search icon (microphone button)
- Taps navigate to `/search` route

#### Banner Carousel
- 3 auto-scrolling promotional banners:
  - "Farm Fresh Vegetables" - Direct from farmers, up to 40% off (green gradient, grass icon)
  - "Organic Fruits" - Healthy & fresh, best prices (orange gradient, apple icon)
  - "Free Delivery" - On orders above Rs.500 (blue gradient, shipping icon)
- Each banner has a "Shop Now" CTA button
- Page indicator dots (expands active dot to width 20)

#### Categories Horizontal Scroll
- 6 category items: Vegetables, Fruits, Grains, Spices, Flowers, Organic
- Each has icon + label in circular container
- "View All" button navigates to `/categories`

#### Quick Filter Chips
- 6 filter chips: Trending, Top Rated, Organic, Free Delivery, Best Deals, Nearby
- Trending navigates to `/trending`
- Best Deals navigates to `/deals`

#### Recommended Products Section
- "Recommended For You" heading with "See All" button (navigates to `/products`)
- Responsive product grid (2-6 columns based on screen width)
- Product cards show:
  - Category icon placeholder (vegetables=grass, fruits=apple, grains=grain, other=eco)
  - Organic badge (green eco icon) if product is organic
  - Wishlist/favorite button (heart icon)
  - Product name (truncated to 1 line)
  - Star rating (hardcoded 4.5)
  - Quantity and unit
  - Price in INR
  - In-cart indicator (green checkmark if already in cart)
- Taps navigate to `/product_detail`

#### Recently Viewed Section
- "Recently Viewed" heading with "View All" button (navigates to `/recently-viewed`)
- Horizontal scrollable list of recent product cards
- Compact card design (140px wide) showing name, price/unit

#### Responsive Layout
- Max content width: 1200px
- Grid cross-axis count adapts: 2 cols (<400px), 3 (<600px), 4 (<900px), 5 (<1200px), 6 (wide)

### Tab 2: All Products (`AllProductsScreen`)

#### Search Bar
- Text search input with search icon
- Real-time filtering on text input
- Dark green header (#002b02)

#### Active Filters Display
- Shows count of active filters ("X filters applied")
- "Clear All" button resets all filters

#### Expandable Filters Panel
- Toggled via filter_list icon button
- **Category Filter**: All, Vegetables, Fruits, Grains, Spices (chip selection)
- **Location Filter**: Dynamic based on unique locations in product data
- **Price Range Slider**: RangeSlider from Rs.0 to Rs.1000 with 100 divisions, labeled with rupee values
- **Organic Only Toggle**: Switch widget

#### Sort Options Bar
- Horizontal scrollable sort chips:
  - Popularity (default)
  - Price: Low to High
  - Price: High to Low
  - Newest (by harvestedDate)
  - Rating

#### Results Display
- Results count: "X products found"
- Responsive product grid (same as home)
- Empty state with icon and "Try adjusting your filters" message
- Product grid cards with: category icon, organic badge, name, rating, price/unit
- Taps navigate to `/product_detail`

### Tab 3: Deals & Offers (`DealsAndOffersScreen`)

#### Header
- Orange gradient header with deal icon
- Title: "Today's Deals"
- Subtitle: "Fresh produce at unbeatable prices"

#### Flash Sale Banner
- Dark green card with flash icon
- Countdown timer display ("Ends in 05:23:45" - mock)
- "Shop Now" button

#### Best Deals Section
- "Best Deals" heading with "View All" button
- Deal cards in list view showing:
  - Product image area with category icon
  - Discount badge (red, shows "% OFF")
  - Product name, location, quantity, unit
  - Discounted price (large, orange)
  - Original price (strikethrough, grey)
  - "Add to Cart" button with cart icon
  - Orange border highlight
- Taps navigate to `/product_detail`
- Deals calculated as mock discounts (10-50% based on price)
- Direct "Add to Cart" with snackbar confirmation

### Tab 4: Trending & Best Sellers (`TrendingAndBestSellersScreen`)

#### Header
- Pink/magenta gradient header with trending icon
- Title: "Trending Now"

#### Trending Products Grid
- "Trending This Week" heading
- Grid of trending product cards (up to 6):
  - Rank badge (#1-#6) with gold/silver/bronze colors for top 3
  - Product image area with category icon
  - Gold/silver/bronze border for top 3
  - Product name and price
- Taps navigate to `/product_detail`

#### Best Sellers List
- "Best Sellers" heading
- List view of best seller cards (up to 5):
  - Rank number badge (gold/silver/bronze/grey)
  - Product image with category icon
  - Product name, rating (4.5), price/unit
  - Arrow forward icon
- Taps navigate to `/product_detail`

### Tab 5: Categories Browsing (`CategoriesBrowsingScreen`)

#### Header
- Dark green header with back button
- Title: "All Categories"

#### Category Cards
- 5 categories: Vegetables (green), Fruits (orange), Grains (brown), Spices (pink), Flowers (purple)
- Each card shows:
  - Category icon in colored container
  - Category name
  - Product count ("X products available")
  - Arrow forward icon
- Taps navigate to `/category_products` with category data

#### Category Products Screen
- Colored header matching category color with back button, icon, and name
- Product grid for selected category
- Empty state with "No products in this category" message
- Same product card design (name, price, category icon)

#### Wishlist Screen (`WishlistScreen`)

#### Header
- "My Wishlist" title with subtitle "Saved items you love"
- Back button
- "Clear All" button (only shown when items exist)

#### Wishlist Stats
- Stats bar showing "X items saved" with heart icon

#### Wishlist Product Grid
- Responsive grid of saved products:
  - Product image area with category icon
  - Filled heart icon (tap to remove with snackbar)
  - Product name (2 lines max)
  - Price/unit
  - "Add" button (adds to cart, shows snackbar)
- Taps navigate to `/product_detail`

#### Empty State
- Heart outline icon (80px)
- "Your wishlist is empty" message
- "Save products you love" subtitle
- "Browse Products" button (navigates back)

#### Clear Confirmation Dialog
- AlertDialog with confirmation message
- Cancel/Clear All buttons

---

### Shared: Product Detail Screen (`ProductDetailScreen`)

#### Hero Image Section
- SliverAppBar with expanded height 250px
- Back button (dark translucent circle)
- Wishlist toggle button (filled/outline heart, red when active)
- Large eco icon placeholder

#### Product Title & Price
- Product name (large, bold)
- Tamil name (nameTa) if available
- Price badge (green pill showing "Rs.X/unit")

#### Tags/Badges
- Organic badge (if applicable)
- Location badge (with location icon)
- Category + quantity available badge

#### Farmer Info Card
- Farmer avatar (first letter of name)
- Farmer name
- "Verified Farmer" status with district
- Verified badge (green with check icon)

#### Description
- Auto-generated description text

#### Price Comparison Section
- Shows 3 similar products from same category
- Each shows: name, price (green if cheaper, red if more expensive)
- Down arrow icon for cheaper alternatives

#### Farm Location Map
- Shows only if lat/lng available
- Embedded `AgriMap` widget with:
  - Centered on product location
  - Zoom level 14
  - Non-interactive, no current location marker
  - Single marker with product name and location subtitle

#### Bottom Action Bar
- **Quantity Selector**: - button, quantity display, + button (min 1)
- **Add to Cart Button**: Full-width button, adds quantity * product to cart with snackbar

---

## Farmer Portal

### Tab 1: Dashboard (`_DashboardTab`)

#### Welcome Section
- "Overview" label
- "Welcome back, [userName]" greeting
- Dynamic message: "Your harvests are reaching X markets today"
- "Add Product" button (navigates to Add Product tab)

#### Stats Bento Grid
- **Revenue Card** (large, dark green):
  - Trending up icon
  - "LIVE" badge
  - Total calculated value (price * quantity for all products)
  - Formatted as K/L for large numbers
- **Active Listings Card** (small, orange):
  - Inventory icon
  - Product count
  - "Active" label
- **Total Quantity Card** (small, olive green):
  - Scale icon
  - Total quantity (formatted as K for large)
  - "Quantity" label

#### Weather Card
- Weather gradient card (warm tones)
- Sun icon
- "Clear Skies" display
- Temperature and harvesting condition text ("28C - Ideal for harvesting")

#### My Products Section
- "My Products" heading with "View All" button
- 2-column grid of product cards showing:
  - Product icon
  - Stock status badge (In Stock/Low/Out)
  - Product name
  - Quantity and unit
  - Price

#### Market Insights Section
- `_DynamicMarketInsights` widget (pulls from product data)

#### Responsive Layout
- Adapts for narrow screens (<360px)
- Uses FittedBox for text overflow protection

### Tab 2: Add Product (`_AddProductTab`)

#### Form Fields
- **Product Name**: Text input with hint "e.g. Organic Alphonso Mangoes"
- **Tamil Name (nameTa)**: Text input for bilingual support
- **Category Dropdown**: Dynamic from database or fallback (Vegetables, Fruits, Flowers, Grains, Spices)
- **Unit Dropdown**: 12 options - kg, g, quintal, ton, liter, ml, piece, dozen, bundle, bag, crate, box (with Tamil labels)
- **Price Input**: Number input in INR
- **Quantity Input**: Number input
- **Farm Address Section**:
  - Manual text input for address
  - GPS Location button (uses MapService)
  - Map Picker toggle button
  - Interactive map with tap-to-select (LocationPicker widget)
  - GPS Set indicator badge when location is captured
  - Lat/Lng coordinates displayed after selection

#### Organic Toggle
- Switch to mark product as organic
- Visual feedback (color change)

#### Submit Action
- Validation for name, district, address
- Calls `ProductProvider.addProduct()` with all fields
- Logs price to price_logs collection for price engine
- Clears form on success
- Reloads product list
- Success snackbar notification

### Tab 3: My Products (`MyProductsScreen`)

#### Header
- "My Products" title
- Product count subtitle ("X products listed")
- "Add New" button (navigates to Add Product tab)

#### Products List
- Filtered by current farmer's ID
- Pull-to-refresh support
- Each product card shows:
  - Category icon
  - Stock status badge (In Stock/Low Stock/Out of Stock)
  - Organic badge (if applicable)
  - Product name + Tamil name
  - Price (large)
  - Location
  - Quantity and unit
  - Harvest date (formatted as "Today", "Yesterday", "X days ago", or date)
- Empty state with icon and "Tap Add New" message

### Tab 4: Market Prices (`MarketPricesScreen`)

#### Header
- "Market Prices" title
- District-specific subtitle ("Live prices from [district] district")

#### Category Filter
- Horizontal scrollable chips: All, Vegetables, Fruits, Grains, Spices, Flowers

#### Market Price Cards
- Each card shows:
  - Product name
  - Farmer count ("X farmers selling")
  - Demand badge (HIGH/MODERATE/LOW/VERY LOW with color coding)
  - **Average Price** stat (grey background)
  - **Min Price** stat (green background)
  - **Max Price** stat (orange background)
  - Total available units
- Products grouped by name with calculated averages
- Sorted by total quantity (demand indicator)
- Empty state with "Add products to see market prices"

### Tab 5: Trending Products (`TrendingProductsScreen`)

#### Header
- "Trending Products" title
- Subtitle: "Most ordered products in your area"

#### Trending Analysis
- Analyzes orders to find trending products
- Calculates: order count, total quantity, trend score (orders * quantity)
- Sorted by trend score (descending)

#### Trending Cards
- Rank badge (#1, #2, etc. with gold/silver/bronze)
- Product name
- Order count and units sold
- Fire intensity icon (color based on trend score)
- **Current Price** stat
- **Trend Score** stat
- Top 3 recommendation banners:
  - #1: "Hottest product! Consider increasing supply"
  - #2: "High demand! Good time to sell"
  - #3: "Trending well! Keep listing"
- Empty state for no trending data

### Tab 6: Best Sellers (`BestSellersScreen`)

#### Header
- "Best Sellers" title
- Subtitle: "Your top-performing products by sales"

#### Sales Analysis
- Filters orders by current farmer
- Calculates per product: total sold, total revenue, order count, average price
- Sorted by revenue (descending)

#### Best Seller Cards
- Medal/rank badge (trophy icon for top 3, number for others)
- Product name
- Order count and units sold
- Performance badges for top 3: "#1 Seller", "Runner Up", "Third Place"
- **Total Revenue** stat
- **Units Sold** stat
- Performance indicator with contextual messages:
  - "Outstanding performer!" (>=Rs.10000)
  - "Strong seller!" (>=Rs.5000)
  - "Good progress!" (>=Rs.1000)
  - "Building momentum" (<Rs.1000)
- Empty state for no sales

### Tab 7: Price Comparison (`PriceComparisonScreen`)

#### Header
- "Price Comparison" title
- Subtitle: "Compare your prices with other farmers"

#### Product Filter
- Horizontal scrollable chips: "All Products" + each unique product name

#### Comparison Cards
- Product name
- Farmer count and total units
- **Price Comparison Bars**:
  - Market Average (blue bar)
  - Market Min (green bar)
  - Market Max (orange bar)
  - Your Price (highlighted green with star icon, if farmer has this product)
- **Price Position Indicator**:
  - Competitive check (within 10% of market avg)
  - Above market warning (with percentage)
  - Below market suggestion (with percentage)
  - Contextual advice text

### Tab 8: Orders (`_OrdersTab`)

- Referenced in navigation but code truncated
- Likely displays farmer's incoming orders

### Tab 9: LOI Requests (`_LOIRequestsTab`)

- Referenced in navigation but code truncated
- Likely displays Letter of Intent requests from merchants

#### Bottom Navigation Bar
- 9 tabs with scrollable horizontal nav:
  - Home, Add, Products, Prices, Trending, Best, Compare, Orders, LOI
- Active tab shows icon + label with green background
- Inactive tabs show icon only with grey color

---

## Merchant Portal

### Tab 1: Home / Bulk Listings (`_BulkListingsTab`)

#### Search Bar
- Search input with placeholder "Search bulk crops..."
- Filled, rounded design

#### District Filter Chips
- Dynamic district list loaded from database via `LocationService`
- "All" option plus all districts
- Loading state while fetching
- Tap to filter by district

#### Product Listings
- Pull-to-refresh support
- Each listing card shows:
  - Product image area with eco icon
  - Product name
  - Organic badge (if applicable)
  - Location and quantity
  - Price per unit
  - **"Send LOI" button** (opens LOI dialog)
- Empty state: "No bulk listings found"
- Grouped by product availability

#### LOI Dialog
- Opens when "Send LOI" is tapped
- Fields:
  - Price offer (pre-filled with product price)
  - Quantity (pre-filled with product quantity)
- Submits via `LOIProvider.sendLOI()` with:
  - Merchant ID and name
  - Farmer ID and name
  - Product ID and name
  - Price offer and quantity
  - Status: "pending"
  - Timestamp
- Success snackbar on submission

### Tab 2: Wholesale Buying (`WholesaleBuyingScreen`)

#### Header
- "Wholesale Buying" title
- Subtitle: "Find best wholesale prices from farmers"

#### Filters Row
- **Category Dropdown**: All Categories, Vegetables, Fruits, Grains, Spices
- **Sort Dropdown**: Price ascending, Price descending, Quantity

#### Wholesale Deal Cards
- Products grouped by name
- Each deal card shows:
  - Product name
  - Farmer count ("X farmers selling")
  - Total units available
  - **Best Price Badge** (dark green)
  - **Market Avg** stat
  - **You Save** percentage stat
  - **Top 3 Best Prices** list:
    - Rank badges (#1 gold, #2 silver, #3 bronze)
    - Farmer name
    - Available quantity and location
    - Price per unit
    - "Buy" button
- Buy dialog with:
  - Custom price input
  - Quantity input
  - Available quantity info
  - Confirm Purchase button
- Empty state for no products

### Tab 3: Inventory Management (`InventoryManagementScreen`)

#### Header
- "My Inventory" title
- Subtitle: "Track your purchased stock"

#### Stats Cards
- **Total Items**: Count with inventory icon
- **Total Value**: Sum of purchasePrice * quantity with money icon

#### Inventory Cards
- Pull-to-refresh support
- Each card shows:
  - Category icon
  - Product name
  - Location
  - Freshness badge (Very Fresh/Fresh/Aging based on days since purchase)
  - Stock/SOLD badge with quantity
  - **Purchase Price** stat
  - **Total Value** stat
  - **Sell** button (outlined, opens sell dialog)
  - **Details** button (filled, opens details dialog)

#### Sell Dialog
- Selling price input field
- Records sale via `TransactionProvider.recordSale()`
- Marks item as sold via `InventoryProvider.markAsSold()`
- Success snackbar

#### Details Dialog
- Shows: Category, Quantity, Purchase Price, Total Value, Status, Purchase Date, Farmer Name, Location

#### Empty State
- "No inventory yet" with "Purchase products to build inventory" subtitle

### Tab 4: Selling (`SellingScreen`)

#### Header
- "My Selling Listings" title
- Subtitle: "List your inventory to customers"

#### Quick Stats
- **Available to Sell**: Item count
- **Total Stock**: Total units

#### Sellable Item Cards
- Each card shows:
  - Category icon
  - Product name
  - Location
  - Stock quantity badge
  - **Your Cost** stat (purchase price)
  - **Suggested Price** stat (25% markup)
  - **Selling Price Input** with rupee icon
  - **"List for Sale" button**
  - **Profit/Loss Preview**:
    - Potential profit/loss amount
    - Margin percentage
    - Color-coded (green for profit, red for loss)

#### Listing Preview Dialog
- Shows: Quantity, Purchase Price, Selling Price
- Total Revenue, Total Cost
- Net Profit/Loss (large, color-coded)
- Confirm Listing button
- Success snackbar

#### Empty State
- "Nothing to sell" with "Buy inventory first" subtitle

### Tab 5: Market Prices (`_MarketPricesTab`)

- Shows price comparison by category
- Category-based sections
- Market average prices for merchant's region
- Loading and empty states

### Tab 6: Profit & Loss Tracking (`ProfitLossTrackingScreen`)

#### Header
- "Profit & Loss" title
- Subtitle: "Track your trading performance"

#### Time Range Selector
- Week/Month/Year toggle buttons

#### Main P&L Card
- **Net Profit/Loss**: Large amount with +/- indicator
- **Profit/Loss Percentage**: With trend icon
- Gradient background (green for profit, red for loss)
- **Total Revenue** stat
- **Total Cost** stat
- **Transaction Count** stat

#### Secondary Stats
- **Win Rate**: Percentage with trophy icon
- **Best Deal**: Amount with star icon

#### Transactions List
- "Recent Transactions" heading
- Pull-to-refresh support
- Each transaction card shows:
  - Buy/Sell icon (orange for buy, green for sell)
  - Product name
  - Counterparty name
  - Status badge (DONE/PENDING)
  - Quantity and unit
  - Total Amount
  - Date
  - Price per unit

#### Empty State
- "No transactions yet" message

### Tab 7: Price Margin Calculator (`PriceMarginCalculator`)

#### Header
- "Price Margin Calculator" title
- Subtitle: "Calculate your profit margins before trading"

#### Input Fields (5 fields, each with icon)
- **Purchase Price** (shopping_cart icon)
- **Selling Price** (sell icon)
- **Quantity** (inventory icon)
- **Transport Cost** (shipping icon)
- **Other Costs** (receipt icon)
- All fields trigger auto-calculation on change

#### Results Card (shown after calculation)
- **Net Profit/Loss**: Large amount with +/- (gradient: green for profit, red for loss)
- **Margin Percentage**: In pill badge
- **Break-Even Price** stat
- **Per Unit Profit** stat
- **Recommendation Card**:
  - Profit: "Good deal! This trade looks profitable"
  - Loss: "Not recommended. Consider negotiating..."

### Tab 8: Market Trends/Insights (`_InsightsTab`)

#### Header
- "Market Trends (Bulk)" with insights icon

#### Price Forecast Card
- Gradient card with market overview
- Product count and district info
- Best price display with product name
- Trending up icon

#### Dynamic Price Insights
- `_DynamicPriceInsights` widget showing:
  - **AI Price Insight** section
  - **Recommended Price**: Calculated by price engine
  - **Price Range**: Min-Max
  - **Trend**: Up/Down/Stable with icon and percentage change
  - Data sourced from `PriceEngineProvider.getRecommendedPrice()`

#### Bulk Transport Card
- Shipping icon
- "Contact farmers for bulk quantity discounts" text
- Arrow forward icon

### Tab 9: My LOIs (`_MyLOIsTab`)

#### Header
- "LOI Requests" title

#### LOI List
- Pulls from `LOIProvider.merchantRequests`
- Each LOI card shows:
  - Product name
  - Farmer name (recipient)
  - Price offer per unit
  - Status badge: ACCEPTED (green), REJECTED (red), PENDING (orange)
- Empty state: "No sent LOIs yet"

#### Bottom Navigation Bar
- 9 tabs with frosted glass effect backdrop:
  - Home, Wholesale, Stock, Selling, Prices, P&L, Margin, Trends, LOIs
- Rounded container with blur effect
- Active tab: green background, white icons/text
- Inactive tab: secondary color

---

## Shared Features & Backend

### Authentication (`AuthProvider`)
- Email/password login
- Email/password registration with role selection
- Role-based routing (Farmer, Merchant, Customer, Admin)
- Session management (create/delete sessions)
- User profile fetching from Appwrite
- Auto-login after registration
- Location data stored (district, taluk, municipality)
- Logout with session cleanup

### Product Management (`ProductProvider`)
- Load all products from database
- Load products by category
- Search products (Appwrite text search on name)
- Add product with full metadata (name, Tamil name, category, price, quantity, unit, organic, location, address, lat/lng, farmer info, harvest date)
- Automatic price logging to price engine on product creation
- Nearby products calculation (Haversine distance formula)
- Convert products to map markers with distance info
- Parse product documents with full field mapping

### Cart Management (`CartProvider`)
- Add to cart with quantity
- Remove from cart
- Update quantity
- Clear cart
- Calculate subtotal, shipping (Rs.45), platform fee (Rs.12), total

### Wishlist (`WishlistProvider`)
- Persistent storage (SharedPreferences)
- Toggle wishlist (add/remove)
- Check if product is in wishlist
- Clear all items
- Auto-save on every change

### Order Management (`OrderProvider`)
- Load orders by farmer ID
- Load orders by customer ID
- Create order from cart items
- Update order status
- Parse order documents with items, totals, addresses

### LOI (Letter of Intent) (`LOIProvider`)
- Fetch LOI requests for farmer
- Fetch LOI requests for merchant
- Send LOI request (creates new LOI)
- Update LOI status (accept/reject)
- LOI contains: merchant info, farmer info, product info, price offer, quantity, status, timestamp

### Price Engine (`PriceEngineProvider`)
- **Price Logs**: Get logs by product ID and district, add new logs
- **Aggregated Prices**: Calculate avg/min/max price, total quantity, seller count, demand level
- **Price Trends**: Get price history over N days, calculate week change percentage
- **District Comparison**: Compare prices across districts with Tamil names
- **Price Insights**: Auto-generated insights (price changes, demand alerts, price spread warnings)
- **Recommended Price**: AI-calculated based on trend + aggregation
- **Demand Calculation**: Very High/High/Moderate/Low based on quantity thresholds
- **Bilingual Support**: Tamil labels for demand levels

### Inventory Management (`InventoryProvider`)
- Load inventory by merchant ID
- Add to inventory (full metadata)
- Update quantity
- Update selling price
- Mark as sold
- Delete items
- Calculate total items, total stock value, in-stock count, low-stock count
- Filter by category
- Search by product name or category

### Transaction Management (`TransactionProvider`)
- Load transactions by user ID
- Record transactions (generic)
- Record purchases (buy type)
- Record sales (sell type)
- Update transaction status
- Delete transactions
- Calculate Profit/Loss report (total purchases, total sales, net profit, margins)
- Get report for specific time period
- Get top 10 products by revenue
- Filter buys, sells, completed transactions

### Admin Features (`AdminProvider`)
- Load stats: total farmers, merchants, customers, monthly sales, moderation queue
- Load all users (with role parsing)
- Load pending products for moderation
- Update product status (approve/reject)
- Update user status
- Parse user and product documents

### Location Services
- `LocationService`: Fetches districts, talukas, municipalities, categories from database
- `MapService`: GPS location, map rendering
- `AgriMap`: Custom map widget with markers
- `LocationPicker`: Interactive map picker for address selection

### Responsive Design
- `_ResponsiveBreakpoints` classes throughout
- Max content width: 1200px
- Adaptive grid layouts (2-6 columns)
- `LayoutBuilder` used in most screens
- `FittedBox` for text overflow protection
- Flexible/Flex layouts for side-by-side content
- `AdaptivePadding` utility function

### UI Components
- Product cards (multiple variants across screens)
- Filter chips and sort options
- Dropdown form fields
- Dialogs (LOI, sell, details, listing preview, confirmations)
- Snackbars for user feedback
- Empty states with icons and messages
- Loading indicators (CircularProgressIndicator)
- Pull-to-refresh (RefreshIndicator)
- Gradient cards for stats and highlights
- Badge system (organic, stock status, demand, rank, discount)

### Navigation
- PageView-based tab navigation in all 3 portals
- Named routes for detail screens (`/product_detail`, `/search`, `/categories`, `/trending`, `/deals`, `/products`, `/recently-viewed`, `/category_products`)
- Bottom navigation bars with custom styling
- Scrollable nav bars for screens with many tabs

---

## Data Models Used

| Model | Purpose |
|-------|---------|
| `ProductModel` | Core product entity: id, name, nameTa, category, price, quantity, unit, organic, location, address, farmerName, farmerId, lat, lng, imageUrl, rating, reviews, harvestedDate |
| `UserModel` | User profile: id, name, email, role, district, taluk, municipality, status |
| `CartItem` | Cart item: product reference, quantity, total calculation |
| `OrderModel` | Order: id, customerId, customerName, farmerId, farmerName, items, total, status, shippingAddress, createdAt |
| `OrderItem` | Order line item: productId, productName, price, quantity |
| `LOIRequestModel` | Letter of Intent: id, merchantId, merchantName, farmerId, farmerName, productId, productName, quantity, priceOffer, status, createdAt |
| `InventoryItem` | Inventory entry: id, merchantId, merchantName, productId, productName, category, quantity, unit, purchasePrice, sellingPrice, farmerId, farmerName, purchasedAt, location, status, expiryDate, imageUrl |
| `Transaction` | Transaction record: id, userId, userName, type, productId, productName, quantity, unit, pricePerUnit, totalAmount, counterpartyId, counterpartyName, orderId, status, paymentMethod, notes, createdAt |
| `ProfitLossReport` | Aggregated P&L: totalPurchases, totalSales, netProfit, transactionCount, buyCount, sellCount, profitMargin |
| `PriceLog` | Price entry: id, productId, productName, farmerId, farmerName, price, quantity, unit, district, createdAt |
| `AggregatedPrice` | Aggregated data: productId, productName, district, avgPrice, minPrice, maxPrice, totalQuantity, sellerCount, lastUpdated, demand |
| `PriceTrend` | Price trend: productId, productName, district, points[] |
| `PricePoint` | Trend data point: date, price |
| `DistrictPriceComparison` | Cross-district data: productId, productName, districts[] |
| `DistrictPrice` | District price data: name, nameTa, avgPrice, minPrice, maxPrice, sellers |
| `PriceInsight` | Auto-generated insight: type, message, messageTa, icon |
| `MapMarker` | Map marker: id, position, title, subtitle, category, price, farmerName, productId, metadata |
| `WishlistItem` | Wishlist entry: productId, addedAt |

---

## Appwrite Collections Referenced

| Collection | Purpose |
|------------|---------|
| `usersCollectionId` | User profiles with roles |
| `productsTableId` | Product listings |
| `ordersCollectionId` | Customer orders |
| `priceLogsTableId` | Historical price data |
| `aggregatedPricesTableId` | Aggregated price statistics |
| `priceTrendsTableId` | Price trend time series |
| `inventoryCollectionId` | Merchant inventory |
| `transactionsCollectionId` | Buy/sell transactions |
| `productsCollectionId` | Products for admin moderation |

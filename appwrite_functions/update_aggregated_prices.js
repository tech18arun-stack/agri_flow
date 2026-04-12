// ============================================================
// APPWRITE FUNCTION: Update Aggregated Prices
// ============================================================
// Deploy this in your Appwrite Functions dashboard
// Trigger: Database Event → price_logs collection (create/update)
// ============================================================

import { Client, Databases, Query } from 'node-appwrite';

export default async function ({ req, res, log, error }) {
  // Initialize Appwrite client
  const client = new Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const databases = new Databases(client);
  const DB_ID = process.env.AGRIFLOW_DB_ID;
  const PRICE_LOGS_ID = process.env.PRICE_LOGS_COLLECTION_ID;
  const AGGREGATED_ID = process.env.AGGREGATED_PRICES_COLLECTION_ID;
  const TRENDS_ID = process.env.PRICE_TRENDS_COLLECTION_ID;

  // Get all price logs for the triggering product+district
  const productId = req.body.productId;
  const district = req.body.district;

  if (!productId || !district) {
    return res.json({ success: false, error: 'Missing productId or district' });
  }

  log(`Aggregating prices for ${productId} in ${district}`);

  try {
    // Fetch all price logs for this product+district
    const logs = await databases.listDocuments(DB_ID, PRICE_LOGS_ID, [
      Query.equal('productId', productId),
      Query.equal('district', district),
    ]);

    if (logs.documents.length === 0) {
      return res.json({ success: true, message: 'No logs found' });
    }

    // Calculate aggregates
    const prices = logs.documents.map(d => d.price);
    const quantities = logs.documents.map(d => d.quantity);
    const uniqueFarmers = new Set(logs.documents.map(d => d.farmerId)).size;

    prices.sort((a, b) => a - b);

    const avgPrice = Math.round(prices.reduce((a, b) => a + b, 0) / prices.length);
    const minPrice = prices[0];
    const maxPrice = prices[prices.length - 1];
    const totalQuantity = quantities.reduce((a, b) => a + b, 0);

    // Determine demand level
    let demand = 'moderate';
    if (totalQuantity < 100) demand = 'very_high';
    else if (totalQuantity < 300) demand = 'high';
    else if (totalQuantity > 600) demand = 'low';

    // Upsert aggregated price document
    const existingAgg = await databases.listDocuments(DB_ID, AGGREGATED_ID, [
      Query.equal('productId', productId),
      Query.equal('district', district),
    ]);

    const productName = logs.documents[0].productName;

    if (existingAgg.documents.length > 0) {
      // Update existing
      await databases.updateDocument(DB_ID, AGGREGATED_ID, existingAgg.documents[0].$id, {
        avgPrice,
        minPrice,
        maxPrice,
        totalQuantity,
        sellerCount: uniqueFarmers,
        demand,
        lastUpdated: new Date().toISOString(),
      });
      log(`Updated aggregated price for ${productId} in ${district}`);
    } else {
      // Create new
      await databases.createDocument(DB_ID, AGGREGATED_ID, ID.unique(), {
        productId,
        productName,
        district,
        avgPrice,
        minPrice,
        maxPrice,
        totalQuantity,
        sellerCount: uniqueFarmers,
        demand,
        lastUpdated: new Date().toISOString(),
      });
      log(`Created aggregated price for ${productId} in ${district}`);
    }

    // --- Update Price Trends (daily) ---
    const today = new Date().toISOString().split('T')[0];

    const existingTrend = await databases.listDocuments(DB_ID, TRENDS_ID, [
      Query.equal('productId', productId),
      Query.equal('district', district),
      Query.equal('date', today),
    ]);

    if (existingTrend.documents.length > 0) {
      await databases.updateDocument(DB_ID, TRENDS_ID, existingTrend.documents[0].$id, {
        avgPrice,
      });
    } else {
      await databases.createDocument(DB_ID, TRENDS_ID, ID.unique(), {
        productId,
        productName,
        district,
        date: today,
        avgPrice,
      });
    }

    return res.json({
      success: true,
      data: { productId, district, avgPrice, minPrice, maxPrice, totalQuantity, demand },
    });
  } catch (err) {
    error(`Failed to aggregate prices: ${err.message}`);
    return res.json({ success: false, error: err.message });
  }
}

// ============================================================
// APPWRITE FUNCTION: Daily Trend Update (Cron Job)
// ============================================================
// Schedule: 0 0 * * * (midnight daily)
// ============================================================

export async function dailyTrendUpdate({ req, res, log, error }) {
  const client = new Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const databases = new Databases(client);
  const DB_ID = process.env.AGRIFLOW_DB_ID;
  const PRICE_LOGS_ID = process.env.PRICE_LOGS_COLLECTION_ID;
  const TRENDS_ID = process.env.PRICE_TRENDS_COLLECTION_ID;

  try {
    // Get all unique product+district combinations from yesterday
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    const logs = await databases.listDocuments(DB_ID, PRICE_LOGS_ID, [
      Query.greaterThanEqual('createdAt', `${yesterdayStr}T00:00:00`),
      Query.lessThan('createdAt', `${yesterdayStr}T23:59:59`),
    ]);

    // Group by product+district
    const groups = {};
    for (const doc of logs.documents) {
      const key = `${doc.productId}::${doc.district}`;
      if (!groups[key]) groups[key] = [];
      groups[key].push(doc.price);
    }

    let updated = 0;
    for (const [key, prices] of Object.entries(groups)) {
      const [productId, district] = key.split('::');
      const avgPrice = Math.round(prices.reduce((a, b) => a + b, 0) / prices.length);
      const productName = logs.documents.find(d => d.productId === productId)?.productName;

      await databases.createDocument(DB_ID, TRENDS_ID, ID.unique(), {
        productId,
        productName,
        district,
        date: yesterdayStr,
        avgPrice,
      });
      updated++;
    }

    log(`Daily trend update: ${updated} entries created for ${yesterdayStr}`);
    return res.json({ success: true, updated });
  } catch (err) {
    error(`Daily trend update failed: ${err.message}`);
    return res.json({ success: false, error: err.message });
  }
}

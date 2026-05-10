# Product Image URL System

This document explains the comprehensive image URL system implemented for AgriFlow to support network images from various sources.

---

## 🎯 Overview

AgriFlow now supports product images from any network URL, including:
- **Google Drive** links
- **Dropbox** links
- **OneDrive** links
- **Direct image URLs** (any public URL ending in .jpg, .png, .webp, etc.)
- **Other cloud storage** services

---

## 📁 Files Modified/Created

### Created:
- `lib/core/utils/image_url_utils.dart` - Core utility class for URL handling

### Modified:
1. **Farmer Screens:**
   - `lib/ui/screens/farmer/features/farmer_add_product_tab.dart`
     - Added custom image URL input with toggle
     - Live image preview
     - URL normalization before saving
   
   - `lib/ui/screens/farmer/features/my_products_screen.dart`
     - Added image URL editing in product edit dialog
     - Image preview in edit dialog
     - URL normalization on update

2. **Admin Screens:**
   - `lib/ui/screens/admin/admin_catalog_screen.dart`
     - Enhanced image URL input with preview
     - Better validation and error handling
     - URL normalization on save

3. **Product Display:**
   - `lib/ui/screens/product_detail_screen.dart`
     - Fixed: Now shows actual product image instead of placeholder icon
     - Proper error handling for broken images

---

## 🔧 How It Works

### Image URL Conversion

The `ImageUrlUtils` class automatically converts various URL formats:

#### Google Drive
```
Input:  https://drive.google.com/file/d/FILE_ID/view
Output: https://drive.google.com/uc?export=view&id=FILE_ID
```

#### Dropbox
```
Input:  https://www.dropbox.com/s/FILE_ID/image.jpg?dl=0
Output: https://dl.dropboxusercontent.com/s/FILE_ID/image.jpg?dl=1
```

#### Direct URLs
```
Input:  https://example.com/images/product.jpg
Output: https://example.com/images/product.jpg (unchanged)
```

### URL Validation

The system validates URLs by:
1. Checking if it's a valid absolute URL
2. Verifying image file extensions (.jpg, .png, .gif, .webp, etc.)
3. Allowing cloud storage URLs (Google Drive, Dropbox, OneDrive)

---

## 🎨 User Interface Features

### For Farmers (Add Product):
1. **Toggle Option**: "Use custom image URL" checkbox
2. **Text Input**: Paste any image URL
3. **Live Preview**: See the image as you type the URL
4. **Error Handling**: Clear error message if URL is invalid
5. **Help Text**: Guidance on supported URL formats
6. **Clear Button**: Easy way to remove the URL

### For Farmers (Edit Product):
1. **Current Image Display**: Shows existing product image
2. **URL Input**: Update or change the image URL
3. **Preview**: See the new image before saving
4. **Optional**: Can leave blank to use template image

### For Admins (Catalog Management):
1. **Enhanced Dialog**: Better image URL input experience
2. **Real-time Preview**: 150px preview of the image
3. **URL Display**: Shows user-friendly format (converted back from direct URL)
4. **Error Feedback**: Clear error states with helpful messages
5. **Auto-normalization**: URLs are automatically converted on save

---

## 📝 Supported URL Formats

### ✅ Google Drive
```
https://drive.google.com/file/d/1aBcDeFgHiJkLmNoPqRsTuVwXyZ/view
https://drive.google.com/open?id=1aBcDeFgHiJkLmNoPqRsTuVwXyZ
https://docs.google.com/uc?id=1aBcDeFgHiJkLmNoPqRsTuVwXyZ
```

### ✅ Dropbox
```
https://www.dropbox.com/s/abc123/image.jpg
https://www.dropbox.com/s/abc123/image.jpg?dl=0
https://dl.dropboxusercontent.com/s/abc123/image.jpg
```

### ✅ OneDrive
```
https://1drv.ms/i/s/abc123
https://onedrive.live.com/embed?cid=ABC123&resid=DEF456
```

### ✅ Direct URLs
```
https://example.com/images/product.jpg
https://cdn.example.com/photos/tomato.png
https://images.unsplash.com/photo-123456?w=800
```

---

## 💡 Best Practices

### For Users:
1. **Use High-Quality Images**: Minimum 800x800 pixels recommended
2. **Public Access**: Ensure the image URL is publicly accessible
3. **Direct Links**: For Google Drive, use "Share" → "Anyone with the link"
4. **Supported Formats**: JPG, PNG, GIF, WebP work best
5. **File Size**: Keep images under 5MB for faster loading

### For Google Drive Images:
1. Upload image to Google Drive
2. Right-click → Share
3. Change to "Anyone with the link"
4. Copy the link
5. Paste into AgriFlow (system will convert automatically)

### For Dropbox Images:
1. Upload image to Dropbox
2. Create a share link
3. Paste the link into AgriFlow
4. System will convert to direct download link

---

## 🔍 Technical Implementation

### Image URL Utils Methods:

```dart
// Convert any URL to direct, usable format
ImageUrlUtils.normalizeImageUrl(url)

// Get user-friendly display URL
ImageUrlUtils.getDisplayUrl(url)

// Validate URL format
ImageUrlUtils.isValidImageUrl(url)

// Get placeholder text
ImageUrlUtils.getPlaceholderText()

// Get help text
ImageUrlUtils.getHelpText()
```

### CachedNetworkImage Integration:

All product images use `CachedNetworkImage` for:
- **Automatic Caching**: Images are cached locally after first load
- **Placeholder Support**: Loading indicator while image loads
- **Error Handling**: Graceful fallback if image fails to load
- **Performance**: Optimized loading and memory management

---

## 🐛 Error Handling

The system handles various error scenarios:

1. **Invalid URL Format**: Shows "Invalid image URL" message
2. **Failed to Load**: Shows error icon with helpful text
3. **Network Issues**: Shows loading state while retrying
4. **Empty URL**: Falls back to template image or icon

---

## 📊 Database Schema

Product images are stored as strings in the database:

```dart
ProductModel {
  String? imageUrl;  // Can be null, stores normalized URL
}

ProductTemplateModel {
  String imageUrl;  // Always has a value, defaults to ''
}
```

---

## 🚀 Future Enhancements

Consider adding:
- [ ] Image upload from device gallery/camera
- [ ] Image compression before saving
- [ ] Multiple images per product
- [ ] Image cropping/editing tools
- [ ] Automatic image optimization
- [ ] CDN integration for faster loading
- [ ] Image lazy loading improvements
- [ ] Offline image caching strategy

---

## 🧪 Testing Checklist

- [ ] Google Drive URLs convert correctly
- [ ] Dropbox URLs convert correctly
- [ ] Direct URLs work without modification
- [ ] Invalid URLs show proper error messages
- [ ] Image preview works in all forms
- [ ] Product detail shows images correctly
- [ ] CachedNetworkImage loads and caches properly
- [ ] Error states display gracefully
- [ ] Empty/null URLs fall back appropriately
- [ ] Admin catalog management works smoothly
- [ ] Farmer add product works with custom images
- [ ] Farmer edit product updates images correctly

---

## 📞 Support

For issues with image URLs:
- Check that the URL is publicly accessible
- Verify the image format is supported
- Ensure the cloud storage sharing settings allow public access
- Contact support at: support@agriflow.com

---

*Implemented: April 15, 2026*
*Version: 1.0.0*

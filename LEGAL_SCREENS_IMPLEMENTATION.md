# Legal Screens Implementation

This document describes the Terms and Conditions and Privacy Policy implementation for AgriFlow.

---

## 📋 What Was Implemented

### 1. Terms and Conditions Screen
**File:** `lib/ui/screens/legal/terms_and_conditions_screen.dart`

A comprehensive Terms and Conditions screen covering:
- Acceptance of Terms
- User Accounts (registration, types, termination)
- Platform Usage (permitted and prohibited uses)
- Product Listings and Transactions
- User Content and Intellectual Property
- Privacy and Data Protection
- Disclaimers and Limitations
- Dispute Resolution
- Termination
- Contact Information

### 2. Privacy Policy Screen
**File:** `lib/ui/screens/legal/privacy_policy_screen.dart`

A detailed Privacy Policy screen covering:
- Information Collection (user-provided and automatic)
- Data Usage (how information is used)
- Location Data handling
- Data Sharing and Disclosure
- Data Security measures
- Data Retention policies
- User Rights (access, correction, deletion, etc.)
- Children's Privacy
- Third-Party Services
- Cookies and Tracking
- Policy Changes
- Contact Information

### 3. Registration Screen Integration
**File:** `lib/ui/screens/auth/register_screen.dart`

Updated to include:
- ✅ Terms acceptance checkbox
- ✅ Links to view Terms and Conditions
- ✅ Links to view Privacy Policy
- ✅ Validation requiring terms acceptance before registration
- ✅ Bilingual support (English/Tamil)

---

## 🎨 Design Features

Both legal screens feature:
- **Glassmorphism UI** matching the app's design language
- **Background blur** with decorative circles
- **Scrollable content** with proper padding
- **Responsive layout** adapting to different screen sizes
- **Bilingual support** (English/Tamil)
- **Back navigation** with clear header
- **Sectioned content** with clear headings

---

## 🔧 How It Works

### Registration Flow

1. User fills in registration details
2. User **must check** the "I agree to the Terms and Conditions and Privacy Policy" checkbox
3. The "Create Account" button remains disabled until:
   - All fields are filled correctly
   - Passwords match
   - District is selected
   - **Terms are accepted** ✅ (NEW)
4. User can tap on "Terms and Conditions" or "Privacy Policy" links to read them
5. Legal screens open in a new screen with full content
6. User can navigate back to continue registration

### Validation Logic

```dart
bool get _isFormValid =>
    _nameCtrl.text.trim().isNotEmpty &&
    _emailCtrl.text.trim().isNotEmpty &&
    _passCtrl.text.isNotEmpty &&
    _confirmPassCtrl.text.isNotEmpty &&
    _passCtrl.text == _confirmPassCtrl.text &&
    _selectedDistrict != null &&
    _acceptedTerms; // ✅ NEW: Requires terms acceptance
```

---

## 📱 User Experience

### Before Registration
- User can read Terms and Conditions anytime from registration screen
- User can read Privacy Policy anytime from registration screen
- No account needed to view legal documents

### During Registration
- Clear checkbox with visual feedback
- Links to legal documents are highlighted in green
- Button is disabled until all requirements are met
- No error messages - visual cues guide the user

### After Acceptance
- Terms are considered accepted at registration time
- User can view terms again from other parts of the app (if added later)

---

## 🌐 Bilingual Support

All legal content supports English and Tamil:
- Checkbox label: "I agree to..." / "நான் ஏற்கிறேன்..."
- Terms link: "Terms and Conditions" / "பயன்பாட்டு விதிமுறைகள்"
- Privacy link: "Privacy Policy" / "தனியுரிமக் கொள்கை"

---

## 📝 Customization

### Update Contact Information
Edit both legal screens to update:
- Email addresses (currently: support@agriflow.com, privacy@agriflow.com)
- Physical address (currently: AgriFlow, Tamil Nadu, India)
- Last updated date

### Modify Legal Content
- Edit the `content` strings in each section
- Add or remove sections as needed
- Keep the bilingual support pattern

### Change Design
- Modify `GlassContainer` parameters for different opacity/blur
- Update colors in `C.primary` references
- Adjust padding and spacing as needed

---

## 🔒 Legal Compliance

This implementation helps with:
- ✅ GDPR-style consent (explicit checkbox)
- ✅ Transparent data practices (clear privacy policy)
- ✅ User rights information
- ✅ Contact information for data requests
- ✅ Terms of service acceptance

**Note:** Consult with a legal professional to ensure compliance with:
- Indian data protection laws
- Tamil Nadu state regulations
- International regulations if expanding globally

---

## 🚀 Future Enhancements

Consider adding:
- [ ] Version tracking for terms updates
- [ ] Re-acceptance flow when terms change
- [ ] Terms access from settings/profile
- [ ] Analytics on terms views
- [ ] PDF download option
- [ ] Print functionality
- [ ] Share terms/privacy with others

---

## 📂 Files Modified/Created

### Created:
- `lib/ui/screens/legal/terms_and_conditions_screen.dart`
- `lib/ui/screens/legal/privacy_policy_screen.dart`

### Modified:
- `lib/ui/screens/auth/register_screen.dart`
  - Added imports for legal screens
  - Added `_acceptedTerms` state variable
  - Updated `_isFormValid` getter
  - Added terms acceptance checkbox UI
  - Added navigation to legal screens

---

## ✅ Testing Checklist

- [ ] Registration works with terms accepted
- [ ] Registration blocked without terms acceptance
- [ ] Terms screen opens and displays correctly
- [ ] Privacy policy screen opens and displays correctly
- [ ] Back navigation works from legal screens
- [ ] Bilingual toggle works on registration and legal screens
- [ ] Checkbox visual feedback (checked/unchecked)
- [ ] Form validation updates correctly
- [ ] All links are clickable and navigate properly

---

*Implementation completed: April 15, 2026*

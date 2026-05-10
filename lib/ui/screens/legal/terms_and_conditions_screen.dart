import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/colors.dart';
import '../../../widgets/glass_container.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _isTamil = false;

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.sizeOf(context).width >= 700;
    final horizontalPadding = isWideScreen ? MediaQuery.sizeOf(context).width * 0.15 : 20.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/agri_bg.png',
            fit: BoxFit.cover,
          ),
          // Decorative circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isTamil ? 'பயன்பாட்டு விதிமுறைகள்' : 'Terms and Conditions',
                          style: TextStyle(
                            fontSize: isWideScreen ? 24 : 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Language Toggle
                      _buildLanguageToggle(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Content
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWideScreen ? 700 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildContent(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(label: 'EN', active: !_isTamil, onTap: () => setState(() => _isTamil = false)),
          _buildToggleItem(label: 'தமிழ்', active: _isTamil, onTap: () => setState(() => _isTamil = true)),
        ],
      ),
    );
  }

  Widget _buildToggleItem({required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? C.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_isTamil) {
      return [
        _buildSection(
          title: '1. விதிமுறைகளை ஏற்றல்',
          content: 'அக்ரி ப்ளோ ("செயலி") அணுகுவதன் மூலம் அல்லது பயன்படுத்துவதன் மூலம், இந்த விதிமுறைகள் மற்றும் நிபந்தனைகளுக்கு கட்டுப்பட ஒப்புக்கொள்கிறீர்கள். இந்த விதிமுறைகளை நீங்கள் ஏற்கவில்லை என்றால், செயலியைப் பயன்படுத்த வேண்டாம்.\n\n'
              'அக்ரி ப்ளோ என்பது தமிழ்நாட்டில் உள்ள விவசாயிகள், வாடிக்கையாளர்கள் மற்றும் வணிகர்களை இணைக்க வடிவமைக்கப்பட்ட ஒரு டிஜிட்டல் விவசாய சந்தைத் தளமாகும்.\n\n'
              'இந்த விதிமுறைகளை எந்த நேரத்திலும் புதுப்பிக்கும் உரிமையை நாங்கள் பெற்றுள்ளோம். மாற்றங்களுக்குப் பிறகு செயலியைத் தொடர்ந்து பயன்படுத்துவது புதிய விதிமுறைகளை ஏற்பதாகக் கருதப்படும்.',
        ),
        _buildSection(
          title: '2. பயனர் கணக்குகள்',
          content: '2.1 பதிவுசெய்தல்\n'
              '• பதிவு செய்ய உங்களுக்கு குறைந்தபட்சம் 18 வயது இருக்க வேண்டும்\n'
              '• நீங்கள் துல்லியமான மற்றும் முழுமையான தகவல்களை வழங்க வேண்டும்\n'
              '• கணக்கின் பாதுகாப்பைப் பேணுவதற்கு நீங்களே பொறுப்பு\n'
              '• அங்கீகரிக்கப்படாத அணுகல் குறித்து உடனடியாக எங்களுக்குத் தெரிவிக்க வேண்டும்\n\n'
              '2.2 கணக்கு வகைகள்\n'
              '• விவசாயி (Farmer): பொருட்களை விற்கும் விவசாய உற்பத்தியாளர்கள்\n'
              '• வாடிக்கையாளர் (Customer): விவசாயப் பொருட்களை வாங்கும் பயனர்கள்\n'
              '• வணிகர் (Merchant): வர்த்தகர்கள் மற்றும் மொத்த விற்பனையாளர்கள்\n\n'
              '2.3 கணக்கு நீக்கம்\n'
              '• நீங்கள் எந்த நேரத்திலும் உங்கள் கணக்கை நீக்கக் கோரலாம். கோரிக்கை விடுக்கப்பட்ட 48 மணிநேரத்திற்குள் உங்கள் கணக்கு மற்றும் தரவு நிரந்தரமாக நீக்கப்படும்.\n'
              '• இந்த விதிமுறைகளை மீறும் அல்லது மோசடி நடவடிக்கைகளில் ஈடுபடும் கணக்குகளை நிறுத்திவைக்க அல்லது நீக்க எங்களுக்கு உரிமை உண்டு.',
        ),
        _buildSection(
          title: '3. தளத்தின் பயன்பாடு',
          content: '3.1 அனுமதிக்கப்பட்ட பயன்பாடுகள்\n'
              '• விவசாயப் பொருட்களைப் பட்டியலிடுதல் மற்றும் விற்பனை செய்தல்\n'
              '• பட்டியலிடப்பட்ட விற்பனையாளர்களிடமிருந்து பொருட்களை வாங்குதல்\n'
              '• பரிவர்த்தனைகளுக்காக மற்ற பயனர்களுடன் தொடர்புகொள்ளுதல்\n'
              '• சந்தை விலைகள் மற்றும் விவசாயத் தகவல்களை அணுகுதல்\n\n'
              '3.2 தடைசெய்யப்பட்ட நடவடிக்கைகள்\n'
              '• தவறான அல்லது தவறாக வழிநடத்தும் தயாரிப்புத் தகவலைப் பதிவிடுதல்\n'
              '• மோசடி பரிவர்த்தனைகளில் ஈடுபடுதல்\n'
              '• சட்டவிரோத நடவடிக்கைகளுக்கு தளத்தைப் பயன்படுத்துதல்\n'
              '• மற்ற பயனர்களைத் துன்புறுத்துதல் அல்லது துஷ்பிரயோகம் செய்தல்\n'
              '• வைரஸ்கள் அல்லது தீங்கிழைக்கும் குறியீடுகளைப் பதிவேற்றுதல்\n'
              '• அனுமதி இல்லாமல் தரவுகளைத் திரட்டுதல் (Scraping)',
        ),
        _buildSection(
          title: '4. தயாரிப்பு பட்டியல்கள் மற்றும் பரிவர்த்தனைகள்',
          content: '4.1 தயாரிப்பு பட்டியல்கள்\n'
              '• துல்லியமான தயாரிப்பு விளக்கங்களுக்கு விற்பனையாளர்களே பொறுப்பு\n'
              '• விலைகள் தெளிவாகக் குறிப்பிடப்பட வேண்டும் மற்றும் மதிக்கப்பட வேண்டும்\n'
              '• தயாரிப்பு இருப்பு பராமரிக்கப்பட வேண்டும்\n\n'
              '4.2 பரிவர்த்தனைகள்\n'
              '• அனைத்து பரிவர்த்தனைகளும் பயனர்களுக்கு இடையே மட்டுமே; அக்ரி ப்ளோ ஒரு தளம் மட்டுமே\n'
              '• பணம் செலுத்தும் விதிமுறைகள் வாங்குபவருக்கும் விற்பனையாளருக்கும் இடையே ஒப்புக்கொள்ளப்பட வேண்டும்\n'
              '• அக்ரி ப்ளோ பரிவர்த்தனை முடிவுக்கு உத்தரவாதம் அளிக்காது\n\n'
              '4.3 கட்டணங்கள்\n'
              '• தளத்தைப் பயன்படுத்துவதற்காக அக்ரி ப்ளோ கமிஷன் அல்லது கட்டணங்களை வசூலிக்கலாம்\n'
              '• கட்டண அமைப்பு பயனர்களுக்குத் தெளிவாகத் தெரிவிக்கப்படும்',
        ),
        _buildSection(
          title: '5. தொடர்பு தகவல்',
          content: 'இந்த விதிமுறைகள் மற்றும் நிபந்தனைகள் குறித்த கேள்விகளுக்கு:\n\n'
              'மின்னஞ்சல்: ceo@websitescorp.com\n'
              'இணையதளம்: https://websitescorp.com\n'
              'முகவரி: அக்ரி ப்ளோ, தமிழ்நாடு, இந்தியா\n\n'
              'கடைசியாக புதுப்பிக்கப்பட்டது: ஏப்ரல் 2026',
        ),
        const SizedBox(height: 40),
      ];
    } else {
      return [
        _buildSection(
          title: '1. Acceptance of Terms',
          content: 'By accessing or using Farm Flow ("the App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, do not use the App.\n\n'
              'Farm Flow is a digital agricultural marketplace platform designed to connect farmers, customers, and merchants in Tamil Nadu, India.\n\n'
              'We reserve the right to update these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms.',
        ),
        _buildSection(
          title: '2. User Accounts',
          content: '2.1 Registration\n'
              '• You must be at least 18 years old to register\n'
              '• You must provide accurate and complete information\n'
              '• You are responsible for maintaining account security\n'
              '• You must notify us immediately of unauthorized access\n\n'
              '2.2 Account Types\n'
              '• Farmer: Agricultural producers selling products\n'
              '• Customer: Buyers purchasing agricultural goods\n'
              '• Merchant: Traders and wholesalers\n\n'
              '2.3 Account Termination\n'
              '• You may request account deletion at any time. Your account and data will be permanently deleted within 48 hours of your request.\n'
              '• We reserve the right to suspend or terminate accounts that violate these terms or engage in fraudulent activities.',
        ),
        _buildSection(
          title: '3. Use of the Platform',
          content: '3.1 Permitted Uses\n'
              '• Listing and selling agricultural products\n'
              '• Purchasing products from listed sellers\n'
              '• Communicating with other users for transactions\n'
              '• Accessing market prices and agricultural information\n\n'
              '3.2 Prohibited Activities\n'
              '• Posting false or misleading product information\n'
              '• Engaging in fraudulent transactions\n'
              '• Using the platform for illegal activities\n'
              '• Harassing or abusing other users\n'
              '• Uploading malicious code or viruses\n'
              '• Scraping or data mining without permission',
        ),
        _buildSection(
          title: '4. Product Listings and Transactions',
          content: '4.1 Product Listings\n'
              '• Sellers are responsible for accurate product descriptions\n'
              '• Prices must be clearly stated and honored\n'
              '• Product availability must be maintained\n\n'
              '4.2 Transactions\n'
              '• All transactions are between users; Farm Flow is a platform provider\n'
              '• Payment terms are agreed between buyer and seller\n'
              '• Farm Flow does not guarantee transaction completion\n\n'
              '4.3 Commission and Fees\n'
              '• Farm Flow may charge commissions or fees for platform use\n'
              '• Fee structure will be clearly communicated to users',
        ),
        _buildSection(
          title: '5. Contact Information',
          content: 'For questions about these Terms and Conditions:\n\n'
              'Email: ceo@websitescorp.com\n'
              'Website: https://websitescorp.com\n'
              'Address: Farm Flow, Tamil Nadu, India\n\n'
              'Last Updated: April 2026',
        ),
        const SizedBox(height: 40),
      ];
    }
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GlassContainer(
        blur: 15,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

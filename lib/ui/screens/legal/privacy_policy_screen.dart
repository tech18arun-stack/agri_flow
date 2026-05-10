import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/colors.dart';
import '../../../widgets/glass_container.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
                          _isTamil ? 'தனியுரிமைக் கொள்கை' : 'Privacy Policy',
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
        _buildInfoCard(
          icon: Icons.calendar_today,
          title: 'கடைசியாக புதுப்பிக்கப்பட்டது',
          content: 'ஏப்ரல் 2026',
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: '1. அறிமுகம்',
          content: 'அக்ரி ப்ளோ ("நாங்கள்" அல்லது "எங்கள்") உங்கள் தனியுரிமையை மதிக்கிறது மற்றும் உங்கள் தனிப்பட்ட தரவைப் பாதுகாக்க உறுதிபூண்டுள்ளது. நீங்கள் எங்கள் மொபைல் செயலியைப் பயன்படுத்தும்போது உங்கள் தகவலை நாங்கள் எப்படி சேகரிக்கிறோம், பயன்படுத்துகிறோம் மற்றும் பாதுகாக்கிறோம் என்பதை இந்த தனியுரிமைக் கொள்கை விளக்குகிறது.\n\n'
              'இந்தக் கொள்கையை கவனமாகப் படிக்கவும். அக்ரி ப்ளோவை பயன்படுத்துவதன் மூலம், இதில் விவரிக்கப்பட்டுள்ள நடைமுறைகளுக்கு நீங்கள் ஒப்புக்கொள்கிறீர்கள்.\n\n'
              'இந்தக் கொள்கை தமிழ்நாட்டில் உள்ள அனைத்து பயனர்களுக்கும் பொருந்தும் மற்றும் இந்திய தரவு பாதுகாப்புச் சட்டங்களுக்கு இணங்குகிறது.',
        ),
        _buildSection(
          title: '2. நாங்கள் சேகரிக்கும் தகவல்கள்',
          content: '2.1 நீங்கள் வழங்கும் தகவல்கள்\n'
              '• கணக்கு பதிவு: பெயர், மின்னஞ்சல் முகவரி, தொலைபேசி எண்\n'
              '• சுயவிவரத் தகவல்: பயனர் வகை (விவசாயி/வாடிக்கையாளர்/வணிகர்)\n'
              '• இருப்பிடத் தரவு: மாவட்டம், தாலுகா, நகராட்சித் தேர்வுகள்\n'
              '• பரிவர்த்தனை தரவு: தயாரிப்பு பட்டியல்கள், ஆர்டர் வரலாறு\n\n'
              '2.2 தானாகவே சேகரிக்கப்படும் தகவல்கள்\n'
              '• சாதனத் தகவல்: சாதன வகை, இயக்க முறைமை\n'
              '• பயன்பாட்டுத் தரவு: செயலியில் அணுகப்பட்ட அம்சங்கள், செலவழித்த நேரம்\n'
              '• இருப்பிடச் சேவைகள்: உங்கள் அனுமதியுடன் GPS ஆயத்தொகுப்புகள்',
        ),
        _buildSection(
          title: '3. உங்கள் தகவலை நாங்கள் எவ்வாறு பயன்படுத்துகிறோம்',
          content: 'சேகரிக்கப்பட்ட தகவல்களை நாங்கள் இதற்காகப் பயன்படுத்துகிறோம்:\n\n'
              '• கணக்கு உருவாக்கம் மற்றும் மேலாண்மை\n'
              '• இருப்பிட அடிப்படையிலான சேவைகள்: அருகிலுள்ள சந்தைகள் மற்றும் விற்பனையாளர்களைக் காட்டுதல்\n'
              '• தள செயல்பாடுகள்: தயாரிப்பு பட்டியல்கள், பரிவர்த்தனைகள் மற்றும் தொடர்புகளை அனுமதித்தல்\n'
              '• வாடிக்கையாளர் ஆதரவு: விசாரணைகளுக்குப் பதிலளித்தல்\n'
              '• பகுப்பாய்வு மற்றும் மேம்பாடு: பயன்பாட்டு முறைகளைப் புரிந்துகொண்டு அம்சங்களை மேம்படுத்துதல்\n'
              '• பாதுகாப்பு: மோசடி மற்றும் துஷ்பிரயோகத்தைக் கண்டறிந்து தடுத்தல்',
        ),
        _buildSection(
          title: '4. இருப்பிடத் தரவு',
          content: 'அக்ரி ப்ளோவின் செயல்பாட்டிற்கு இருப்பிடச் சேவைகள் மிக முக்கியமானவை:\n\n'
              '• அருகிலுள்ள சந்தைகள் மற்றும் பயனர்களுடன் உங்களை இணைக்க உங்கள் இருப்பிடத்தைச் சேகரிக்கிறோம்\n'
              '• உங்கள் சாதன அமைப்புகளில் இருப்பிட அனுமதிகளை நீங்கள் கட்டுப்படுத்தலாம்\n'
              '• இருப்பிடத்தைச் சேகரிக்க அனுமதி இல்லை என்றால் சில அம்சங்கள் சரியாக வேலை செய்யாமல் போகலாம்',
        ),
        _buildSection(
          title: '5. தரவுப் பாதுகாப்பு',
          content: 'உங்கள் தரவைப் பாதுகாக்க பொருத்தமான தொழில்நுட்ப மற்றும் நிறுவன நடவடிக்கைகளை நாங்கள் செயல்படுத்துகிறோம்:\n\n'
              '• தரவு பரிமாற்றம் மற்றும் சேமிப்பகத்தின் குறியாக்கம் (Encryption)\n'
              '• அணுகல் கட்டுப்பாடுகள் மற்றும் அங்கீகாரம்\n'
              '• வழக்கமான பாதுகாப்பு மதிப்பீடுகள்\n\n'
              'இருப்பினும், இணையம் வழியாகப் பரிமாற்றம் செய்யப்படும் எந்த முறையும் 100% பாதுகாப்பானது அல்ல.',
        ),
        _buildSection(
          title: '6. உங்கள் உரிமைகள்',
          content: 'உங்கள் தனிப்பட்ட தரவு குறித்து உங்களுக்கு பின்வரும் உரிமைகள் உள்ளன:\n\n'
              '• அணுகல்: உங்கள் தரவின் நகலைக் கோருதல்\n'
              '• திருத்தம்: தவறான தகவலைப் புதுப்பித்தல்\n'
              '• நீக்கம்: உங்கள் கணக்கு மற்றும் தரவை நீக்கக் கோருதல். கோரிக்கை விடுக்கப்பட்ட 48 மணிநேரத்திற்குள் உங்கள் கணக்கு மற்றும் தரவு நிரந்தரமாக நீக்கப்படும்.\n'
              '• ஒப்புதல் திரும்பப் பெறல்: எந்த நேரத்திலும் உங்கள் ஒப்புதலைத் திரும்பப் பெறுதல்\n\n'
              'இந்த உரிமைகளைப் பயன்படுத்த, எங்களைத் தொடர்பு கொள்ளவும்: ceo@websitescorp.com',
        ),
        _buildSection(
          title: '7. எங்களைத் தொடர்பு கொள்ள',
          content: 'இந்த தனியுரிமைக் கொள்கை அல்லது எங்கள் தரவு நடைமுறைகள் குறித்து உங்களுக்கு கேள்விகள் இருந்தால்:\n\n'
              'மின்னஞ்சல்: ceo@websitescorp.com\n'
              'இணையதளம்: https://websitescorp.com\n'
              'முகவரி: அக்ரி ப்ளோ, தமிழ்நாடு, இந்தியா\n\n'
              'கடைசியாக புதுப்பிக்கப்பட்டது: ஏப்ரல் 2026',
        ),
        const SizedBox(height: 40),
      ];
    } else {
      return [
        _buildInfoCard(
          icon: Icons.calendar_today,
          title: 'Last Updated',
          content: 'April 2026',
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: '1. Introduction',
          content: 'Farm Flow ("we," "our," or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.\n\n'
              'Please read this policy carefully. By using Farm Flow, you consent to the practices described herein.\n\n'
              'This policy applies to all users in Tamil Nadu, India, and complies with applicable Indian data protection laws.',
        ),
        _buildSection(
          title: '2. Information We Collect',
          content: '2.1 Information You Provide\n'
              '• Account Registration: Name, email address, phone number\n'
              '• Profile Information: User role (farmer/customer/merchant)\n'
              '• Location Data: District, taluk, municipality selections\n'
              '• Transaction Data: Product listings, order history\n\n'
              '2.2 Information Automatically Collected\n'
              '• Device Information: Device type, operating system\n'
              '• Usage Data: Features accessed, time spent in app\n'
              '• Location Services: GPS coordinates (with your permission)',
        ),
        _buildSection(
          title: '3. How We Use Your Information',
          content: 'We use the collected information for:\n\n'
              '• Account Creation and Management\n'
              '• Location-Based Services: Showing nearby markets, buyers, and sellers\n'
              '• Platform Operations: Enabling product listings, transactions, and communications\n'
              '• Customer Support: Responding to inquiries and resolving issues\n'
              '• Analytics and Improvement: Understanding usage patterns\n'
              '• Security: Detecting and preventing fraud and abuse',
        ),
        _buildSection(
          title: '4. Location Data',
          content: 'Location services are core to Farm Flow\'s functionality:\n\n'
              '• We collect your location to connect you with nearby markets and users\n'
              '• You can control location permissions in your device settings\n'
              '• Disabling location services may affect app functionality',
        ),
        _buildSection(
          title: '5. Data Security',
          content: 'We implement appropriate technical and organizational measures to protect your data:\n\n'
              '• Encryption of data in transit and at rest\n'
              '• Access controls and authentication\n'
              '• Regular security assessments\n\n'
              'However, no method of transmission over the Internet is 100% secure.',
        ),
        _buildSection(
          title: '6. Your Rights',
          content: 'You have the following rights regarding your personal data:\n\n'
              '• Access: Request a copy of your personal data\n'
              '• Correction: Update or correct inaccurate information\n'
              '• Deletion: Request deletion of your account and data. Your account will be permanently deleted within 48 hours of the request.\n'
              '• Consent Withdrawal: Withdraw consent at any time\n\n'
              'To exercise these rights, contact us at: ceo@websitescorp.com',
        ),
        _buildSection(
          title: '7. Contact Us',
          content: 'If you have questions about this Privacy Policy or our data practices:\n\n'
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return GlassContainer(
      blur: 15,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

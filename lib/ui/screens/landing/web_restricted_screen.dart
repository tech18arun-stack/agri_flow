import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/shared_widgets.dart';

class WebRestrictedScreen extends StatelessWidget {
  const WebRestrictedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.surface,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phonelink_lock, size: 80, color: C.primary),
              const SizedBox(height: 24),
              const BiLabel(
                en: 'Mobile Only Access',
                ta: 'மொபைல் அணுகல் மட்டும்',
                enSize: 24,
                enWeight: FontWeight.w800,
              ),
              const SizedBox(height: 16),
              const Text(
                'The Farm Flow marketplace and farmer portal are optimized for mobile devices. Please download our app or open this link on your smartphone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.onSurfaceVariant, fontSize: 14),
              ),
              const Text(
                'அக்ரி ப்ளோ சந்தை மற்றும் விவசாயி போர்டல் மொபைல் சாதனங்களுக்கு உகந்ததாக உள்ளது. தயவுசெய்து எங்கள் செயலியைப் பதிவிறக்கவும்.',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/admin_login'),
                child: const Text('Are you an Admin? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../widgets/support_action_card.dart';

class SupportDeveloperPage extends StatefulWidget {
  const SupportDeveloperPage({super.key});

  @override
  State<SupportDeveloperPage> createState() => _SupportDeveloperPageState();
}

class _SupportDeveloperPageState extends State<SupportDeveloperPage>
    with SingleTickerProviderStateMixin {
  static const _linkedInUrl =
      'https://www.linkedin.com/in/elshaarawy-hassan-6020002b6/';
  static const _phoneNumber = '01013348672';

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Support the Developer')),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0E1513), Color(0xFF14201C), Color(0xFF0E1513)]
                : const [Color(0xFFF8FAFA), Color(0xFFEFF8F4), Color(0xFFF8FAFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(_fadeAnimation),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryGreen,
                          AppConstants.primaryGreen.withOpacity(0.82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryGreen.withOpacity(0.18),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 86,
                          width: 86,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.code_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Elshaarawy Hassan',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Developed with ❤️ by Elshaarawy Hassan',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.92),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(_fadeAnimation),
                  child: SupportActionCard(
                    icon: Icons.business_center_rounded,
                    title: 'LinkedIn',
                    value: 'linkedin.com/in/elshaarawy-hassan-6020002b6',
                    subtitle: 'Connect, support, or contact on LinkedIn',
                    actionLabel: 'Open',
                    gradient: isDark
                        ? const [Color(0xFF172029), Color(0xFF0F2E4A)]
                        : const [Color(0xFFF8FBFF), Color(0xFFE8F3FF)],
                    onTap: _launchLinkedIn,
                  ),
                ),
                const SizedBox(height: 16),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.16),
                    end: Offset.zero,
                  ).animate(_fadeAnimation),
                  child: SupportActionCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Phone',
                    value: _phoneNumber,
                    subtitle: 'Tap to copy the phone number instantly',
                    actionLabel: 'Copy',
                    gradient: isDark
                        ? const [Color(0xFF1B241F), Color(0xFF243B31)]
                        : const [Color(0xFFFAFFFC), Color(0xFFEAF8F0)],
                    trailingIcon: Icons.copy_rounded,
                    onTap: _copyPhoneNumber,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Thanks for supporting the developer 🚀',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyPhoneNumber() async {
    await Clipboard.setData(const ClipboardData(text: _phoneNumber));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number copied to clipboard')),
    );
  }

  Future<void> _launchLinkedIn() async {
    final uri = Uri.parse(_linkedInUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open LinkedIn')),
    );
  }
}

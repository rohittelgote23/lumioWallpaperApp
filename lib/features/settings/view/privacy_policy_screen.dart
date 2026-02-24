import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Privacy Policy – Lumio Walls'),
            const SizedBox(height: 8),
            _buildText(context, 'Last Updated: 20 Feb 2026'),
            const SizedBox(height: 16),
            _buildText(
              context,
              'Your privacy matters to us. This Privacy Policy explains what information Lumio Walls collects, how we use it, and the choices you have. By using the app, you agree to this policy.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Information We Collect'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'Lumio Walls may collect the following types of information:',
            ),
            const SizedBox(height: 16),
            _buildSubSectionTitle(
              context,
              'Automatically Collected Information',
            ),
            const SizedBox(height: 8),
            _buildText(
              context,
              'When you use the app, we may collect:\n'
              '• Device information (model, version, OS)\n'
              '• App usage data (features used, sessions, interactions)\n'
              '• Crash logs and performance data\n\n'
              'This helps us improve the app and fix issues.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'No Personal Images or Sensitive Data'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We do not collect:\n'
              '• Personal photos\n'
              '• Contacts\n'
              '• SMS\n'
              '• Location\n'
              '• Sensitive personal information\n\n'
              'Your downloaded wallpapers stay on your device only.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'How We Use Your Information'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We use collected data to:\n'
              '• Improve app performance and stability\n'
              '• Fix bugs and errors\n'
              '• Provide a smooth user experience\n'
              '• Offer relevant features and updates\n\n'
              'We do not sell your data.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Third-Party Services'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'Lumio Walls may use trusted third-party services such as:\n'
              '• Analytics tools\n'
              '• Crash reporting tools\n'
              '• Cloud storage (for hosting wallpapers)\n\n'
              'These services may receive basic, non-sensitive device or usage data to help us run the app smoothly.\n\n'
              'We are not responsible for how third-party services handle data, but we choose reputable providers that follow industry standards.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Data Security'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We use standard protections to keep your information safe.\n'
              'However, no digital service is 100% secure, so we cannot guarantee absolute security.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Children’s Privacy'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We do not knowingly collect data from children under 13.\n'
              'If you believe a child has provided information, contact us and we will remove it.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Your Choices'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'You can:\n'
              '• Stop using the app anytime\n'
              '• Control permissions through your device settings',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Changes to This Privacy Policy'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We may update this policy from time to time.\n'
              'When we update it, we will change the “Last Updated” date.\n\n'
              'Continued use of the app means you accept the updated policy.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildSubSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
    );
  }

  Widget _buildText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}

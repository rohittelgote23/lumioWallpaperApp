import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

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
          'Terms of Use',
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
            _buildSectionTitle(context, 'Terms of Use – Lumio Walls'),
            const SizedBox(height: 8),
            _buildText(context, 'Last Updated: 20 Feb 2026'),
            const SizedBox(height: 16),
            _buildText(
              context,
              'Welcome to Lumio Walls. By downloading, installing, or using our app, you agree to these Terms of Use. Please read them carefully.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Use of the App'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'Lumio Walls provides mobile wallpapers for personal use only.\n'
              'You may download wallpapers for your own device and use them as your home or lock screen.\n\n'
              'You may not resell, distribute, modify, or recreate wallpapers for commercial purposes. You must not use the app in ways that break laws or harm Lumio Walls.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Intellectual Property'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'All wallpapers, graphics, logos, and content in the app belong to Lumio Walls or their respective owners.\n'
              'You receive a personal, non-commercial license to use them.\n'
              'Ownership remains with Lumio Walls.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'User Accounts (If Applicable)'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'If the app includes login or user accounts, you must provide accurate information and keep your account secure.\n'
              'We may suspend accounts that violate these Terms.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Third-Party Content'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'Some wallpapers or tools may use third-party services.\n'
              'We are not responsible for issues caused by third-party content, services, or links.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Prohibited Activities'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'You agree not to:\n'
              '• Hack, reverse-engineer, or disrupt the app\n'
              '• Upload harmful files\n'
              '• Copy, scrape, or steal wallpapers or backend data',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Privacy'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'Your privacy matters.\n'
              'Please review our Privacy Policy to understand how we handle your data.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Changes to the App'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We may update wallpapers, features, or the app interface anytime.\n'
              'Content may also be removed or changed if required.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Termination'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We may suspend or block access if you misuse the app or violate these Terms.\n'
              'You may uninstall the app anytime to stop using our service.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Limitation of Liability'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'Lumio Walls is provided “as is.”\n'
              'We are not responsible for device issues, data loss, or any indirect or accidental damages resulting from using the app.\n\n'
              'Use the app at your own risk.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Changes to Terms'),
            const SizedBox(height: 8),
            _buildText(
              context,
              'We may update these Terms as needed. Continued use of the app means you accept the updated Terms.',
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

  Widget _buildText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}

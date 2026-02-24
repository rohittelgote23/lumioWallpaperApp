import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

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
          'Feedback',
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
            _buildSectionTitle(context, 'We\'d Love Your Feedback!'),
            const SizedBox(height: 16),
            _buildText(
              context,
              'Your thoughts help us improve Lumio Walls and bring you better wallpapers every day.',
            ),
            const SizedBox(height: 16),
            _buildText(
              context,
              'If you have suggestions, found a bug, or want to share your experience:',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Mail us at:'),
            const SizedBox(height: 8),
            _buildText(context, 'lumiowalls@gmail.com'),
            const SizedBox(height: 24),
            _buildText(context, 'We usually respond within 24–48 hours.'),
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

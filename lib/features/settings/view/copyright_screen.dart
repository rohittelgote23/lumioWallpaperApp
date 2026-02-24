import 'package:flutter/material.dart';

class CopyrightScreen extends StatelessWidget {
  const CopyrightScreen({super.key});

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
          'Copyright Statement',
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
            _buildSectionTitle(context, 'Copyright Statement – Lumio Walls'),
            const SizedBox(height: 16),
            _buildText(
              context,
              'All wallpapers, images, graphics, and content inside Lumio Walls are protected by copyright laws.',
            ),
            const SizedBox(height: 16),
            _buildText(
              context,
              'Lumio Walls owns the rights to the wallpapers we create and publish.\n'
              'Some wallpapers in the app may come from free-use sources, royalty-free libraries, or platforms that allow personal-use distribution. These wallpapers are used in accordance with their respective licenses.',
            ),
            const SizedBox(height: 16),
            _buildText(
              context,
              'We do not claim ownership over wallpapers that belong to third-party creators or free-content providers.\n'
              'If you believe that any content in Lumio Walls violates your copyright, please contact us and we will review and remove it if required.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'For copyright inquiries:'),
            const SizedBox(height: 8),
            _buildText(context, 'Email: lumiowalls@gmail.com'),
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

import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

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
          'Tutorial',
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
            _buildSectionTitle(context, 'How to set a Wallpaper'),
            const SizedBox(height: 16),
            _buildStep(
              context,
              stepNumber: '1',
              title: 'Select a Wallpaper',
              description:
                  'Browse our collection and tap on any image you like.',
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              stepNumber: '2',
              title: 'Apply the Wallpaper',
              description: 'Tap the Apply button at the bottom of the screen.',
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              stepNumber: '3',
              title: 'Choose Screen',
              description:
                  'Select whether you want to set it on your Home Screen, Lock Screen, or Both.',
            ),

            const SizedBox(height: 32),

            _buildSectionTitle(context, 'How to set a Live Wallpaper'),
            const SizedBox(height: 16),
            _buildStep(
              context,
              stepNumber: '1',
              title: 'Download the Video',
              description:
                  'Open a live wallpaper and tap Apply. Wait for the video to finish downloading.',
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              stepNumber: '2',
              title: 'System Settings',
              description:
                  'You may be redirected to your phone\'s live wallpaper chooser. Choose Lumio Walls or the downloaded video.',
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              stepNumber: '3',
              title: 'Set as Wallpaper',
              description: 'Tap "Set Wallpaper" to apply it to your device.',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Troubleshooting'),
            const SizedBox(height: 16),
            _buildSubSectionTitle(context, 'Live Wallpaper not working?'),
            const SizedBox(height: 8),
            _buildText(
              context,
              '• Some Android devices (like those with MIUI, ColorOS) restrict third-party apps from setting lock screen live wallpapers. In this case, apply the downloaded video directly from your device\'s default Gallery app.\n'
              '• Make sure the app has storage permissions.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
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

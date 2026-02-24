import 'package:flutter/material.dart';
import 'package:lumiowalls/features/settings/view/copyright_screen.dart';
import 'package:lumiowalls/features/settings/view/feedback_screen.dart';
import 'package:lumiowalls/features/settings/view/privacy_policy_screen.dart';
import 'package:lumiowalls/features/settings/view/terms_of_use_screen.dart';
import 'package:lumiowalls/features/settings/view/tutorial_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/theme/theme_cubit.dart';
import '../../../core/bloc/theme/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      await DefaultCacheManager().emptyCache();

      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ), // centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Tutorial Section
          _buildSectionHeader(context, 'Tutorial'),
          _buildSettingsTile(
            context,
            icon: Icons.wallpaper_rounded,
            iconColor: Colors.deepOrange,
            title: 'How to set a Live Wallpaper',
            subtitle: 'Learn how to apply live wallpapers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TutorialScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              String themeText;
              IconData themeIcon;
              switch (state.themeMode) {
                case ThemeMode.system:
                  themeText = 'System Default';
                  themeIcon = Icons.brightness_auto_rounded;
                  break;
                case ThemeMode.light:
                  themeText = 'Light Mode';
                  themeIcon = Icons.light_mode_rounded;
                  break;
                case ThemeMode.dark:
                  themeText = 'Dark Mode';
                  themeIcon = Icons.dark_mode_rounded;
                  break;
              }

              return _buildSettingsTile(
                context,
                icon: themeIcon,
                iconColor: Colors.purple,
                title: 'Theme',
                subtitle: themeText,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Choose Theme',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _buildThemeOption(
                              context,
                              title: 'System Default',
                              mode: ThemeMode.system,
                              currentMode: state.themeMode,
                            ),
                            _buildThemeOption(
                              context,
                              title: 'Light Mode',
                              mode: ThemeMode.light,
                              currentMode: state.themeMode,
                            ),
                            _buildThemeOption(
                              context,
                              title: 'Dark Mode',
                              mode: ThemeMode.dark,
                              currentMode: state.themeMode,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Information Section
          _buildSectionHeader(context, 'Information'),
          _buildSettingsTile(
            context,
            icon: Icons.copyright_rounded,
            iconColor: Colors.blueGrey,
            title: 'Copyright Statement',
            subtitle: 'Read our copyright policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CopyrightScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_rounded,
            iconColor: Colors.blue,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.description_rounded,
            iconColor: Colors.cyan,
            title: 'Terms of Use',
            subtitle: 'Read our terms of service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUseScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.cleaning_services_rounded,
            iconColor: Colors.redAccent,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _clearCache(context),
          ),

          const SizedBox(height: 24),

          // About App Section
          _buildSectionHeader(context, 'About App'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: Colors.teal,
            title: 'Version',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.feedback_rounded,
            iconColor: Colors.purple,
            title: 'Feedback',
            subtitle: 'Send us your feedback',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.coffee_rounded,
            iconColor: Colors.brown,
            title: 'Buy me a coffee',
            subtitle: '@rohittelgote23',
            onTap: () {
              _launchUrl('https://www.buymeacoffee.com/rohittelgote23');
            },
          ),

          const SizedBox(height: 12),
          Text(
            "Created & Designed By Rohit Telgote",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        // No shadow as per user request
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).iconTheme.color?.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        context.read<ThemeCubit>().setTheme(mode);
        Navigator.pop(context);
      },
    );
  }
}

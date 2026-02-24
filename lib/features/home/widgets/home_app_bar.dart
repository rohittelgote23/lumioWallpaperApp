import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumiowalls/features/downloads/view/downloads_screen.dart';
import '../../search/view/search_page.dart';
import '../../settings/view/settings_screen.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.scaffoldBackgroundColor, // Use scaffold background
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Explore Title
            Text(
              'Explore',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displaySmall?.color,
              ),
            ),

            // Right: Icons Row
            Row(
              children: [
                // Premium Icon
                _buildIconButton(
                  context,
                  icon: Icons.file_download,
                  color: theme.iconTheme.color!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // Search Icon
                _buildIconButton(
                  context,
                  icon: Icons.search_rounded,
                  color: theme.iconTheme.color!,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // Settings Icon
                _buildIconButton(
                  context,
                  icon: Icons.settings_rounded,
                  color: theme.iconTheme.color!,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}

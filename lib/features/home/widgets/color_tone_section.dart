import 'package:flutter/material.dart';
import '../view/color_screen.dart';

class ColorToneSection extends StatelessWidget {
  const ColorToneSection({super.key});

  @override
  Widget build(BuildContext context) {
    // List of provided colors
    final List<Map<String, dynamic>> colors = [
      {'name': 'pink', 'color': Colors.pink[200]},
      {'name': 'blue', 'color': Colors.blue},
      {'name': 'purple', 'color': Colors.deepPurple},
      {'name': 'red', 'color': Colors.red},
      {'name': 'black', 'color': Colors.black},
      {'name': 'teal', 'color': Colors.teal},
      {'name': 'orange', 'color': Colors.orange},
      {'name': 'yellow', 'color': Colors.yellow},
      {'name': 'green', 'color': Colors.green},
      {'name': 'brown', 'color': Colors.brown},
      {'name': 'white', 'color': Colors.white},
      {'name': 'gray', 'color': Colors.grey},
      {'name': 'navy', 'color': const Color(0xFF000080)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'The color tone',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final colorItem = colors[index];
              final colorName = colorItem['name'] as String;
              final colorValue = colorItem['color'] as Color;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ColorScreen(
                        colorName: colorName,
                        baseColor: colorValue,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colorValue,
                    borderRadius: BorderRadius.circular(10),
                    border: colorName == 'white'
                        ? Border.all(color: Colors.grey.shade300, width: 1)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

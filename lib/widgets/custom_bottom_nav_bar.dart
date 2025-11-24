import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.house),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.comments),
            onPressed: () {},
          ),
          const SizedBox(width: 48), // Space for FAB
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.chartLine),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.user),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.onTap,
    this.currentIndex = 0,
  });

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
            icon: FaIcon(
              FontAwesomeIcons.house,
              color: currentIndex == 0
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: () => onTap(0),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.comments,
              color: currentIndex == 1
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: () => onTap(1),
          ),
          const SizedBox(width: 48), // Space for FAB
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.chartLine,
              color: currentIndex == 2
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: () => onTap(2),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.user,
              color: currentIndex == 3
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pocketai/widgets/custom_bottom_nav_bar.dart';
import 'package:pocketai/widgets/expandable_fab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header Placeholder
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 12),
                          Text(
                            'BATNA GDG',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                ),
                // Balance Card Placeholder
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '2000 DA',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Draggable Stats Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Stats Preview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    // Placeholder for charts
                    Container(
                      height: 200,
                      color: Colors.white10,
                      child: const Center(child: Text('Chart Placeholder')),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      10,
                      (index) => ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.shopping_bag),
                        ),
                        title: Text('Expense ${index + 1}'),
                        subtitle: const Text('Category'),
                        trailing: Text('-${(index + 1) * 100} DA'),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              );
            },
          ),
          // Floating Bottom Nav Bar
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: CustomBottomNavBar(),
          ),
          // Floating Action Button
          const Positioned(
            bottom: 30, // Elevated position
            left: 0,
            right: 0,
            child: ExpandableFab(),
          ),
        ],
      ),
    );
  }
}

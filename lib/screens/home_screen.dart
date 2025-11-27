import 'package:flutter/material.dart';
import 'package:pocketai/widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PocketAI',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            // Premium Upgrade Button
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Premium upgrade coming soon!',
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Premium',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Balance Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Balance',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '5,230,000 DA',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_down,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'This Week',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '850 DA',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Transactions',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '12',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Recent Expenses Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Expenses',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (transaction['color'] as Color)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      transaction['icon'] as IconData,
                                      color: transaction['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction['item'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          transaction['type'] == 'income'
                                              ? transaction['time'] as String
                                              : '${transaction['quantity']} items • ${transaction['time']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    transaction['type'] == 'income'
                                        ? '+${transaction['price']} DA'
                                        : '-${transaction['price']} DA',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: transaction['type'] == 'income'
                                              ? Colors.green
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ), // Space for draggable sheet
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Draggable Stats Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.3,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spending Overview',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'This Month',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Category Breakdown
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Categories',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryRow(
                            context,
                            'Food & Dining',
                            45,
                            '900 DA',
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryRow(
                            context,
                            'Transport',
                            30,
                            '600 DA',
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryRow(
                            context,
                            'Shopping',
                            15,
                            '300 DA',
                            Colors.pink,
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryRow(
                            context,
                            'Others',
                            10,
                            '200 DA',
                            Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_transactions.length, (index) {
                      final transaction = _transactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (transaction['color'] as Color)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                transaction['icon'] as IconData,
                                color: transaction['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['item'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transaction['type'] == 'income'
                                        ? transaction['time'] as String
                                        : '${transaction['quantity']} items • ${transaction['time']}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              transaction['type'] == 'income'
                                  ? '+${transaction['price']} DA'
                                  : '-${transaction['price']} DA',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: transaction['type'] == 'income'
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              );
            },
          ),
          // Floating Bottom Nav Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: CustomBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                if (onNavigate != null) {
                  onNavigate!(index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _transactions = [
    {
      'item': 'Freelance Project',
      'quantity': 1,
      'price': 15000,
      'icon': Icons.work_outline,
      'color': Colors.green,
      'time': 'Today, 02:00 PM',
      'type': 'income',
    },
    {
      'item': 'Pizza',
      'quantity': 2,
      'price': 800,
      'icon': Icons.local_pizza,
      'color': Colors.orange,
      'time': 'Today, 12:30 PM',
      'type': 'expense',
    },
    {
      'item': 'Coke',
      'quantity': 3,
      'price': 300,
      'icon': Icons.local_drink,
      'color': Colors.red,
      'time': 'Today, 12:35 PM',
      'type': 'expense',
    },
    {
      'item': 'Taxi Ride',
      'quantity': 1,
      'price': 600,
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'time': 'Today, 09:00 AM',
      'type': 'expense',
    },
    {
      'item': 'Salary',
      'quantity': 1,
      'price': 45000,
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'time': 'Yesterday, 09:00 AM',
      'type': 'income',
    },
    {
      'item': 'Groceries',
      'quantity': 12,
      'price': 4500,
      'icon': Icons.shopping_bag,
      'color': Colors.purple,
      'time': 'Yesterday, 06:15 PM',
      'type': 'expense',
    },
    {
      'item': 'Coffee',
      'quantity': 1,
      'price': 250,
      'icon': Icons.coffee,
      'color': Colors.brown,
      'time': 'Yesterday, 08:30 AM',
      'type': 'expense',
    },
    {
      'item': 'Cinema Ticket',
      'quantity': 2,
      'price': 1600,
      'icon': Icons.movie,
      'color': Colors.indigo,
      'time': '22 Nov, 08:00 PM',
      'type': 'expense',
    },
    {
      'item': 'Popcorn',
      'quantity': 1,
      'price': 400,
      'icon': Icons.fastfood,
      'color': Colors.amber,
      'time': '22 Nov, 08:15 PM',
      'type': 'expense',
    },
    {
      'item': 'Side Gig Payment',
      'quantity': 1,
      'price': 8000,
      'icon': Icons.monetization_on,
      'color': Colors.green,
      'time': '21 Nov, 03:00 PM',
      'type': 'income',
    },
    {
      'item': 'Gym Subscription',
      'quantity': 1,
      'price': 3500,
      'icon': Icons.fitness_center,
      'color': Colors.teal,
      'time': '20 Nov, 10:00 AM',
      'type': 'expense',
    },
    {
      'item': 'Notebooks',
      'quantity': 4,
      'price': 800,
      'icon': Icons.book,
      'color': Colors.green,
      'time': '19 Nov, 04:30 PM',
      'type': 'expense',
    },
    {
      'item': 'Cat Food',
      'quantity': 2,
      'price': 1200,
      'icon': Icons.pets,
      'color': Colors.cyan,
      'time': '18 Nov, 05:45 PM',
      'type': 'expense',
    },
  ];

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    int percentage,
    String amount,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(category, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            Text(
              amount,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

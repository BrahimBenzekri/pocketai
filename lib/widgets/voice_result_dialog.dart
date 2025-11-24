import 'package:flutter/material.dart';

class VoiceResultDialog extends StatefulWidget {
  final List<dynamic> products;

  const VoiceResultDialog({super.key, required this.products});

  @override
  State<VoiceResultDialog> createState() => _VoiceResultDialogState();
}

class _VoiceResultDialogState extends State<VoiceResultDialog> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.products.map((item) {
      return {
        'item': item['item'] ?? '',
        'price': item['price']?.toString() ?? '0',
        'quantity': item['quantity']?.toString() ?? '1',
        'controllers': {
          'name': TextEditingController(text: item['item']?.toString() ?? ''),
          'price': TextEditingController(
            text: item['price']?.toString() ?? '0',
          ),
          'quantity': TextEditingController(
            text: item['quantity']?.toString() ?? '1',
          ),
        },
      };
    }).toList();
  }

  @override
  void dispose() {
    for (var item in _items) {
      final controllers =
          item['controllers'] as Map<String, TextEditingController>;
      for (var c in controllers.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _items.add({
        'item': '',
        'price': '',
        'quantity': '1',
        'controllers': {
          'name': TextEditingController(),
          'price': TextEditingController(),
          'quantity': TextEditingController(text: '1'),
        },
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      final item = _items.removeAt(index);
      final controllers =
          item['controllers'] as Map<String, TextEditingController>;
      for (var c in controllers.values) {
        c.dispose();
      }
    });
  }

  void _confirm() {
    final List<Map<String, dynamic>> result = [];
    bool isValid = true;

    // Simple validation: ensure name is not empty
    for (var item in _items) {
      final controllers =
          item['controllers'] as Map<String, TextEditingController>;
      if (controllers['name']!.text.isEmpty) {
        isValid = false;
        break;
      }
      result.add({
        'item': controllers['name']!.text,
        'price': double.tryParse(controllers['price']!.text) ?? 0.0,
        'quantity': int.tryParse(controllers['quantity']!.text) ?? 1,
      });
    }

    if (isValid) {
      Navigator.pop(context, result);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill in all item names')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review Items',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length + 1, // +1 for Add Button
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _addNewItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Another Item'),
                      ),
                    ),
                  );
                }

                final item = _items[index];
                final controllers =
                    item['controllers'] as Map<String, TextEditingController>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: controllers['name'],
                                decoration: const InputDecoration(
                                  labelText: 'Item',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers['price'],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: controllers['quantity'],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm Items'),
            ),
          ),
        ],
      ),
    );
  }
}

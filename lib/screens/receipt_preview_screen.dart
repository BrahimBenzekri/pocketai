import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocketai/services/api_service.dart';
import 'package:pocketai/widgets/voice_result_dialog.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final String imagePath;

  const ReceiptPreviewScreen({super.key, required this.imagePath});

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _analyzeReceipt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.sendOCR(widget.imagePath);
      if (mounted) {
        // Check if we have products in the response
        if (result['success'] == true && result['products'] != null) {
          final products = result['products'] as List<dynamic>;
          
          // Show products in editable dialog (same as voice input)
          final confirmedItems =
              await showModalBottomSheet<List<Map<String, dynamic>>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => VoiceResultDialog(products: products),
          );

          if (confirmedItems != null && mounted) {
            Navigator.pop(context); // Close preview screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added ${confirmedItems.length} items successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Fallback: show raw result if format is unexpected
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Analysis Result'),
              content: SingleChildScrollView(
                child: Text(result['message'] ?? result.toString()),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close preview screen
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: FileImage(File(widget.imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _analyzeReceipt,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isLoading ? 'Analyzing...' : 'Analyze'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

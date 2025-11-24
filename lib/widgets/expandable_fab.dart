import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pocketai/screens/receipt_preview_screen.dart';
import 'package:pocketai/widgets/manual_input_dialog.dart';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:pocketai/services/api_service.dart';
import 'package:pocketai/widgets/voice_result_dialog.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;
  final ImagePicker _picker = ImagePicker();

  // Voice Recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSending = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: SizedBox(
        height: 250,
        width: 300, // Ensure enough width for fanning out
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            _buildTapToCloseFab(),
            ..._buildExpandingActionButtons(),
            _buildTapToOpenFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[
      _ActionButton(
        onPressed: () => _onActionSelected('Manual'),
        icon: const Icon(Icons.edit),
        label: 'Manual Input',
      ),
      // Voice button with hold-to-record
      GestureDetector(
        onLongPressStart: (_) => _startRecording(),
        onLongPressEnd: (_) => _stopRecording(),
        child: _ActionButton(
          onPressed: () {}, // Empty function to keep button enabled
          icon: const Icon(Icons.mic),
          label: 'Hold to Record',
          backgroundColor: _isRecording ? Colors.red : null,
          foregroundColor: _isRecording ? Colors.white : null,
        ),
      ),
      _ActionButton(
        onPressed: () => _onActionSelected('Camera'),
        icon: const Icon(Icons.camera_alt),
        label: 'Scan Receipt',
      ),
    ];

    final count = children.length;
    return List.generate(count, (index) {
      // Fan out logic: 45, 90, 135 degrees.
      // We want the middle one to be 90 (Up).
      // Let's say we want a range from 45 to 135.
      // step = (135 - 45) / (count - 1) = 90 / 2 = 45.
      // index 0: 45 + 0*45 = 45 (Right-Up)
      // index 1: 45 + 1*45 = 90 (Up)
      // index 2: 45 + 2*45 = 135 (Left-Up)
      // But wait, the list order is Camera, Voice, Manual.
      // Camera (0) -> 45 (Right-Up)
      // Voice (1) -> 90 (Up)
      // Manual (2) -> 135 (Left-Up)
      // If we want Camera on the left, we should reverse or adjust.
      // Let's make Camera 135 (Left-Up), Voice 90, Manual 45.

      final step = 90.0 / (count - 1);
      final angle = 135.0 - (index * step);

      return _ExpandingActionButton(
        directionInDegrees: angle,
        maxDistance: 100,
        progress: _expandAnimation,
        child: children[index],
      );
    });
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _isOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _isOpen ? 0.7 : 1.0,
          _isOpen ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _isOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Future<void> _onActionSelected(String action) async {
    _toggle(); // Close FAB for other actions

    if (action == 'Camera') {
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (photo != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptPreviewScreen(imagePath: photo.path),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error accessing camera: $e')));
        }
      }
    } else {
      // Manual Input
      final result = await showModalBottomSheet<Map<String, String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const ManualInputDialog(),
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added: ${result['quantity']}x ${result['name']} - ${result['price']} DA',
            ),
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) return; // Already recording

    log('Starting voice recording...');
    try {
      // Check permissions
      log('Checking permissions...');
      if (await _audioRecorder.hasPermission()) {
        log('Permission granted');
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        log('Starting recording to path: $path');

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: path,
        );
        log('Recording started');

        setState(() {
          _isRecording = true;
        });

        // Show recording overlay
        if (mounted) {
          _showRecordingOverlay();
        }
      } else {
        log('Permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      }
    } catch (e) {
      log('Exception in _startRecording: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return; // Not recording

    log('Stopping recording...');
    try {
      final path = await _audioRecorder.stop();
      log('Recording stopped. Path returned: $path');

      setState(() {
        _isRecording = false;
      });

      // Close recording overlay
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (path != null && mounted) {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          log('File exists. Size: $size bytes');
          if (size == 0) {
            log('WARNING: File is empty!');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Recorded file is empty')),
              );
            }
            return;
          }
        } else {
          log('WARNING: File does not exist at path: $path');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Recorded file not found')),
            );
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing voice command...')),
          );
        }

        try {
          log('Sending voice file to API...');
          setState(() {
            _isSending = true;
          });
          final result = await _apiService.sendVoice(path);
          setState(() {
            _isSending = false;
          });
          log('API Result: $result');
          if (mounted) {
            if (result['success'] == true && result['products'] != null) {
              final products = result['products'] as List<dynamic>;
              final confirmedItems =
                  await showModalBottomSheet<List<Map<String, dynamic>>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => VoiceResultDialog(products: products),
                  );

              if (confirmedItems != null && mounted) {
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
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Voice Command Result'),
                  content: SingleChildScrollView(
                    child: Text(result['message'] ?? result.toString()),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        } catch (e) {
          log('API Error: $e');
          setState(() {
            _isSending = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 5),
                content: Text('Error processing voice: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else {
        log('Path is null after stopping recorder');
      }
    } catch (e) {
      log('Exception in _stopRecording: $e');
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        Navigator.of(context).pop(); // Close overlay if open
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
      }
    }
  }

  void _showRecordingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RecordingOverlay(
        onCancel: _cancelRecording,
        onConfirm: _confirmRecording,
      ),
    );
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    
    log('Cancelling recording...');
    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
      });
      
      // Delete the file
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          log('Recording file deleted');
        }
      }
      
      // Close overlay
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording cancelled')),
        );
      }
    } catch (e) {
      log('Error cancelling recording: $e');
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _confirmRecording() async {
    // This will call the existing _stopRecording logic
    await _stopRecording();
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          -directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );

        // Calculate position relative to bottom center
        // Stack is 300 wide, 250 high. Center is at 150.
        // Bottom is at 250.
        // We want to position the button center at (150 + dx, 250 + dy)
        // But Positioned works with left/right/top/bottom.
        // Let's use left and bottom.
        // Center x = 150.
        // Center y (from bottom) = 28 (half of 56 fab size).

        return Positioned(
          left: 150 + offset.dx - 28, // 150 is center, 28 is half button width
          bottom:
              offset.dy *
              -1, // dy is negative for up, so multiply by -1 to get positive bottom value
          child: Opacity(opacity: progress.value, child: child),
        );
      },
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor ?? Theme.of(context).colorScheme.secondary,
      elevation: 8,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: foregroundColor ?? Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}

// Recording Overlay Widget
class _RecordingOverlay extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _RecordingOverlay({
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<_RecordingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _seconds = 0;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Pulsing animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Update timer every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _seconds = DateTime.now().difference(_startTime).inSeconds;
        });
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing microphone icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 60),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Timer
            Text(
              _formatDuration(_seconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 20),
            // Recording text
            const Text(
              'Recording...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    iconSize: 60,
                  ),
                ),
                const SizedBox(width: 60),
                // Confirm button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: widget.onConfirm,
                    icon: const Icon(Icons.check, color: Colors.white, size: 32),
                    iconSize: 60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

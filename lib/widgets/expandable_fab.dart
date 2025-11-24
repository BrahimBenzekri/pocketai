import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:pocketai/screens/receipt_preview_screen.dart';
import 'package:pocketai/widgets/manual_input_dialog.dart';


import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:pocketai/services/api_service.dart';

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
      _ActionButton(
        onPressed: () => _onActionSelected('Voice'),
        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
        label: _isRecording ? 'Stop Recording' : 'Voice Record',
        backgroundColor: _isRecording ? Colors.red : null,
        foregroundColor: _isRecording ? Colors.white : null,
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
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Future<void> _onActionSelected(String action) async {
    if (action == 'Voice') {
      // Handle voice recording without closing the FAB immediately
      await _handleVoiceRecording();
      return;
    }

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

  Future<void> _handleVoiceRecording() async {
    try {
      if (_isRecording) {
        // Stop recording
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });

        if (path != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing voice command...')),
          );
          
          _toggle(); // Close FAB after recording stops

          try {
            final result = await _apiService.sendVoice(path);
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Voice Command Result'),
                  content: SingleChildScrollView(
                    child: Text(result.toString()),
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
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error processing voice: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      } else {
        // Start recording
        if (await _audioRecorder.hasPermission()) {
          final directory = await getApplicationDocumentsDirectory();
          final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          
          await _audioRecorder.start(const RecordConfig(), path: path);
          
          setState(() {
            _isRecording = true;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording... Tap stop when done.'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Microphone permission denied')),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording: $e')),
        );
      }
    }
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
          bottom: offset.dy * -1, // dy is negative for up, so multiply by -1 to get positive bottom value
          child: Opacity(
            opacity: progress.value,
            child: child,
          ),
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

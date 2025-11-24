import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:pocketai/screens/receipt_preview_screen.dart';
import 'package:pocketai/widgets/manual_input_dialog.dart';

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
        height: 250, // Sufficient height for expansion
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
        icon: const Icon(Icons.mic),
        label: 'Voice Record',
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
    _toggle();
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
    } else if (action == 'Voice') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Voice input coming soon!')));
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
        // final offset = Offset.fromDirection(
        //   directionInDegrees * (math.pi / 180.0),
        //   progress.value * maxDistance,
        // );
        // We want the buttons to fan out upwards.
        // 0 degrees is right, 90 is down, 180 is left, 270 is up.
        // Let's adjust the angle calculation in the parent or here.
        // Let's assume the parent passes correct angles for "upwards" fan.
        // Actually, let's simplify.

        // Let's just use simple translation for now based on index.
        // But to match the sketch (fan out), we need angles.
        // Sketch shows: Left, Up, Right.
        // So angles: 225 (bottom-left? no), 180 (left), 270 (up), 0 (right).
        // Sketch shows 3 buttons above the FAB.
        // Let's map them to:
        // 1. Left-ish (150 deg)
        // 2. Up (90 deg - wait, in Flutter 0 is right, 90 is down. So -90 is up.)
        // 3. Right-ish (30 deg)

        // Use Positioned.fill to ensure the container covers the entire stack area,
        // allowing hit tests to reach the transformed button even when it moves up.
        return Positioned.fill(
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(
              bottom: 4,
            ), // Adjust for FAB height/padding if needed
            child: Transform.translate(
              offset: Offset.fromDirection(
                -directionInDegrees * (math.pi / 180.0), // Negative for up
                progress.value * maxDistance,
              ),
              child: Opacity(opacity: progress.value, child: child),
            ),
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
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.secondary,
      elevation: 8,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}

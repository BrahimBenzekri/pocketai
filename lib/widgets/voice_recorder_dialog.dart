import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceRecorderDialog extends StatefulWidget {
  const VoiceRecorderDialog({super.key});

  @override
  State<VoiceRecorderDialog> createState() => _VoiceRecorderDialogState();
}

class _VoiceRecorderDialogState extends State<VoiceRecorderDialog> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() => _text = 'Microphone permission denied');
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) {
        if (mounted) {
          setState(() {
            if (val == 'done' || val == 'notListening') {
              _isListening = false;
            } else if (val == 'listening') {
              _isListening = true;
            }
          });
        }
      },
      onError: (val) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _text = 'Error: ${val.errorMsg}';
          });
        }
      },
    );

    if (available) {
      _startListening();
    } else {
      setState(() => _text = 'Speech recognition not available');
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
      }),
    );
    setState(() => _isListening = true);
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isListening ? 'Listening...' : 'Tap mic to record',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            constraints: const BoxConstraints(minHeight: 100),
            width: double.infinity,
            child: Text(
              _text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                child: Icon(_isListening ? Icons.stop : Icons.mic),
              ),
              FilledButton(
                onPressed: _text.isNotEmpty && _text != 'Press the button and start speaking' 
                    ? () => Navigator.pop(context, _text) 
                    : null,
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

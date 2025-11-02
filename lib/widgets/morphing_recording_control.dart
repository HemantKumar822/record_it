import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/app_providers.dart';
import '../services/audio_recording_service.dart';
import '../models/entry.dart';
import 'package:uuid/uuid.dart';

enum ControlState {
  idle,       // Circle mic button
  recording,  // Horizontal bar with waveform
  processing, // Bar with loading animation
  success,    // Green bar with checkmark
}

class MorphingRecordingControl extends ConsumerStatefulWidget {
  const MorphingRecordingControl({super.key});

  @override
  ConsumerState<MorphingRecordingControl> createState() => _MorphingRecordingControlState();
}

class _MorphingRecordingControlState extends ConsumerState<MorphingRecordingControl>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _waveController;
  late AnimationController _successController;
  
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _borderRadiusAnimation;
  
  ControlState _currentState = ControlState.idle;
  String _processingText = 'Processing';
  String _successText = 'Saved';
  int _processingMessageIndex = 0;
  Timer? _processingMessageTimer;
  
  final List<String> _processingMessages = [
    'Transcribing audio',
    'Analyzing content',
    'Creating summary',
    'Polishing notes',
    'Almost done',
  ];
  
  final List<double> _amplitudes = List.generate(20, (i) => 0.3);
  Timer? _amplitudeTimer;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    
    // Morph animation (circle ↔ bar)
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Shimmer animation for processing state (slower for smooth effect)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Success animation
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Setup morph animations (needs MediaQuery, so done here instead of initState)
    _widthAnimation = Tween<double>(
      begin: 76.0,
      end: MediaQuery.of(context).size.width - 48.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutCubic,
    ));
    
    _heightAnimation = Tween<double>(
      begin: 76.0,
      end: 64.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutCubic,
    ));
    
    _borderRadiusAnimation = Tween<double>(
      begin: 38.0,
      end: 32.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _morphController.dispose();
    _waveController.dispose();
    _successController.dispose();
    _amplitudeTimer?.cancel();
    _recordingTimer?.cancel();
    _processingMessageTimer?.cancel();
    super.dispose();
  }

  void _updateState(ControlState newState) {
    if (_currentState == newState) return;
    
    setState(() {
      _currentState = newState;
    });
    
    switch (newState) {
      case ControlState.idle:
        _morphController.reverse();
        _amplitudeTimer?.cancel();
        _recordingTimer?.cancel();
        _recordingSeconds = 0;
        break;
        
      case ControlState.recording:
        _morphController.forward();
        _startAmplitudeSimulation();
        _startRecordingTimer();
        break;
        
      case ControlState.processing:
        _amplitudeTimer?.cancel();
        _recordingTimer?.cancel();
        _startProcessingMessageRotation();
        break;
        
      case ControlState.success:
        _processingMessageTimer?.cancel();
        _successController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _successController.reverse();
              _updateState(ControlState.idle);
            }
          });
        });
        break;
    }
  }

  void _startAmplitudeSimulation() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _currentState == ControlState.recording) {
        setState(() {
          for (int i = 0; i < _amplitudes.length; i++) {
            _amplitudes[i] = 0.2 + math.Random().nextDouble() * 0.8;
          }
        });
      }
    });
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _currentState == ControlState.recording) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  void _startProcessingMessageRotation() {
    _processingMessageTimer?.cancel();
    _processingMessageIndex = 0;
    setState(() {
      _processingText = _processingMessages[0];
    });
    
    _processingMessageTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted && _currentState == ControlState.processing) {
        setState(() {
          _processingMessageIndex = (_processingMessageIndex + 1) % _processingMessages.length;
          _processingText = _processingMessages[_processingMessageIndex];
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to providers for state changes
    ref.listen(recordingStateProvider, (previous, next) {
      if (next == RecordingState.recording && _currentState == ControlState.idle) {
        _updateState(ControlState.recording);
      }
    });
    
    ref.listen(processingStateProvider, (previous, next) {
      if (next && _currentState == ControlState.recording) {
        _updateState(ControlState.processing);
      } else if (next == false && previous == true && _currentState == ControlState.processing) {
        _updateState(ControlState.success);
      }
    });

    return GestureDetector(
      onTap: _currentState == ControlState.idle ? _handleStartRecording : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphController, _waveController, _successController]),
        builder: (context, child) {
          return Container(
            width: _widthAnimation.value,
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentState) {
      case ControlState.idle:
        return CupertinoColors.systemBlue;
      case ControlState.recording:
        return CupertinoColors.systemRed;
      case ControlState.processing:
        return CupertinoColors.systemBlue;
      case ControlState.success:
        return CupertinoColors.systemGreen;
    }
  }

  Widget _buildContent() {
    switch (_currentState) {
      case ControlState.idle:
        return const Center(
          child: Icon(
            CupertinoIcons.mic_fill,
            color: CupertinoColors.white,
            size: 32,
          ),
        );
        
      case ControlState.recording:
        return _buildRecordingBar();
        
      case ControlState.processing:
        return _buildProcessingBar();
        
      case ControlState.success:
        return _buildSuccessBar();
    }
  }

  Widget _buildRecordingBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Timer
          Text(
            _formatDuration(_recordingSeconds),
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          
          // Waveform
          Expanded(
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(20, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 3,
                    height: 40 * _amplitudes[index],
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Cancel button
          GestureDetector(
            onTap: _handleCancel,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: CupertinoColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Submit button
          GestureDetector(
            onTap: _handleSubmit,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                CupertinoIcons.checkmark,
                color: CupertinoColors.systemRed,
                size: 20,
                weight: 600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingBar() {
    return Stack(
      children: [
        // Shimmer effect
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ShimmerPainter(
                    animation: _waveController.value,
                  ),
                );
              },
            ),
          ),
        ),
        // Text on top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Text(
              _processingText,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _successController,
                curve: Curves.elasticOut,
              ),
            ),
            child: const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _successText,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartRecording() async {
    final audioService = ref.read(audioRecordingServiceProvider);
    
    HapticFeedback.mediumImpact();
    
    try {
      final filePath = await audioService.startRecording();
      
      if (filePath != null) {
        ref.read(currentRecordingPathProvider.notifier).state = filePath;
      } else {
        _showError('Unable to start recording. Please check microphone permissions.');
      }
    } catch (e) {
      _showError('Recording error: ${e.toString()}');
    }
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.mediumImpact();
    
    final audioService = ref.read(audioRecordingServiceProvider);
    final aiService = ref.read(aiServiceProvider);
    
    try {
      // Stop recording
      final result = await audioService.stopRecording();
      
      if (result == null) {
        _showError('No recording to process');
        _updateState(ControlState.idle);
        return;
      }
      
      final filePath = result.filePath;
      final duration = result.durationSeconds;
      
      // Update to processing state
      _updateState(ControlState.processing);
      ref.read(processingStateProvider.notifier).state = true;
      
      setState(() {
        _processingText = 'Processing';
      });
      
      // Process with AI
      final processedAudio = await aiService.processAudio(filePath);
      
      // Save to database
      final entry = Entry(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        audioPath: filePath,
        rawTranscript: processedAudio.rawTranscript,
        polishedNote: processedAudio.polishedNote,
        title: processedAudio.title,
        durationSeconds: duration,
        category: processedAudio.category,
      );
      
      // Use the entriesProvider to add the entry - this will automatically update the UI
      await ref.read(entriesProvider.notifier).addEntry(entry);
      
      // Update providers
      ref.read(processingStateProvider.notifier).state = false;
      ref.read(currentRecordingPathProvider.notifier).state = null;
      
      setState(() {
        _successText = 'Saved';
      });
      
      // Show success
      _updateState(ControlState.success);
      HapticFeedback.heavyImpact();
      
    } catch (e) {
      ref.read(processingStateProvider.notifier).state = false;
      ref.read(currentRecordingPathProvider.notifier).state = null;
      _updateState(ControlState.idle);
      
      if (mounted) {
        _showError('Processing failed: ${e.toString()}');
      }
    }
  }

  Future<void> _handleCancel() async {
    HapticFeedback.lightImpact();
    
    final audioService = ref.read(audioRecordingServiceProvider);
    
    try {
      await audioService.cancelRecording();
      ref.read(currentRecordingPathProvider.notifier).state = null;
      _updateState(ControlState.idle);
      
      // Brief feedback
      if (mounted) {
        final overlay = Overlay.of(context);
        final overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Recording cancelled',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
        
        overlay.insert(overlayEntry);
        Future.delayed(const Duration(seconds: 2), () {
          overlayEntry.remove();
        });
      }
    } catch (e) {
      _showError('Cancel failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Shimmer effect painter for processing state
class ShimmerPainter extends CustomPainter {
  final double animation;

  ShimmerPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.4, 0.5, 0.6, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(
        -size.width + (size.width * 2.5 * animation),
        0,
        size.width * 2,
        size.height,
      ));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

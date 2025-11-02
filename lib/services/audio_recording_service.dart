import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  final _audioRecorder = FlutterSoundRecorder();
  
  final _amplitudeController = StreamController<double>.broadcast();
  final _stateController = StreamController<RecordingState>.broadcast();
  
  Timer? _durationTimer;
  Timer? _amplitudeTimer;
  DateTime? _startTime;
  bool _isInitialized = false;
  String? _currentPath;
  
  static const int maxRecordingSeconds = 600;

  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Stream<RecordingState> get stateStream => _stateController.stream;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    await _audioRecorder.openRecorder();
    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> startRecording() async {
    try {
      await _initialize();
      
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/recording_$timestamp.aac';

      _currentPath = filePath;
      _startTime = DateTime.now();

      await _audioRecorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (_audioRecorder.isRecording) {
          _amplitudeController.add(0.5);
        }
      });

      _durationTimer = Timer(
        const Duration(seconds: maxRecordingSeconds),
        () => stopRecording(),
      );

      _stateController.add(RecordingState.recording);
      return filePath;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _stateController.add(RecordingState.error);
      return null;
    }
  }

  Future<RecordingResult?> stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      
      _amplitudeTimer?.cancel();
      _durationTimer?.cancel();

      final duration = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;

      _stateController.add(RecordingState.stopped);

      if (_currentPath != null && File(_currentPath!).existsSync()) {
        return RecordingResult(
          filePath: _currentPath!,
          durationSeconds: duration,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _stateController.add(RecordingState.error);
      return null;
    }
  }

  Future<void> pauseRecording() async {
    await _audioRecorder.pauseRecorder();
    _stateController.add(RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await _audioRecorder.resumeRecorder();
    _stateController.add(RecordingState.recording);
  }

  Future<void> cancelRecording() async {
    await _audioRecorder.stopRecorder();
    
    _amplitudeTimer?.cancel();
    _durationTimer?.cancel();

    if (_currentPath != null) {
      final file = File(_currentPath!);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    _stateController.add(RecordingState.cancelled);
  }

  Future<bool> isRecording() async {
    return _audioRecorder.isRecording;
  }

  void dispose() {
    _amplitudeTimer?.cancel();
    _durationTimer?.cancel();
    _amplitudeController.close();
    _stateController.close();
    _audioRecorder.closeRecorder();
  }
}

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
  processing,
  error,
  cancelled,
}

class RecordingResult {
  final String filePath;
  final int durationSeconds;

  RecordingResult({
    required this.filePath,
    required this.durationSeconds,
  });
}

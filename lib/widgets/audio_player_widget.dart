import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  const AudioPlayerWidget({super.key, required this.audioPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Play/Pause Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _togglePlayPause,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Progress Slider
              Expanded(
                child: Column(
                  children: [
                    CupertinoSlider(
                      value: _position.inSeconds.toDouble().clamp(
                        0.0,
                        _duration.inSeconds.toDouble().clamp(0.01, double.infinity),
                      ),
                      max: _duration.inSeconds.toDouble().clamp(0.01, double.infinity),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: CupertinoColors.systemBlue,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey.resolveFrom(context),
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey.resolveFrom(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero) {
        await _audioPlayer.play(DeviceFileSource(widget.audioPath));
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

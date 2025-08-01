import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

class SongPlayerScreen extends StatefulWidget {
  final Song song;

  const SongPlayerScreen({super.key, required this.song});

  @override
  State<SongPlayerScreen> createState() => _SongPlayerScreenState();
}

class _SongPlayerScreenState extends State<SongPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _playSong();

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => currentPosition = position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => totalDuration = duration);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });
  }

  void _playSong() async {
    await _audioPlayer.play(AssetSource(widget.song.path.replaceFirst('assets/', '')));
    setState(() => isPlaying = true);
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => isPlaying = !isPlaying);
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.deepOrange,
      ),
      body: Stack(
        children: [
          
          Positioned.fill(
            child: Image.asset(
              'assets/favscreen.jpg', 
              fit: BoxFit.cover,
            ),
          ),

    
          Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.music_note, size: 120, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  Text(
                    widget.song.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.song.subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Slider(
                      value: currentPosition.inSeconds.toDouble(),
                      min: 0,
                      max: totalDuration.inSeconds.toDouble() > 0
                          ? totalDuration.inSeconds.toDouble()
                          : 1,
                      onChanged: (value) => _seekTo(value),
                      activeColor: Colors.deepOrange,
                      inactiveColor: Colors.white30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(currentPosition),
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          _formatTime(totalDuration),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 80,
                        color: Colors.deepOrange,
                      ),
                      onPressed: _togglePlayPause,
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
}

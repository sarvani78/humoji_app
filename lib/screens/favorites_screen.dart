import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:humoji_app/global_state.dart';
import 'package:humoji_app/models/song.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'audio': ['gaallo.mp3', 'O_madhu.mp3']},
    {'emoji': '😢', 'audio': ['aakasam lona.mp3', 'oosupodu.mp3']},
    {'emoji': '❤️', 'audio': ['beautiful love.mp3', 'Prema_O_Prema.mp3']},
    {'emoji': '🎞️', 'audio': ['andhalalo.mp3', 'taralirada.mp3']},
    {'emoji': '💃', 'audio': ['dabidi dibidi.mp3', 'peelings.mp3']},
  ];

  int selectedIndex = 0;
  double currentAngle = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        currentAngle = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final mood = moods[selectedIndex];
        _playWheelAudio(mood['audio']);
        setState(() => isSpinning = false);
      }
    });


  }

  void _playWheelAudio(dynamic audioData) async {
    await _audioPlayer.stop();
    await _musicPlayer.stop();

    String fileName;
    if (audioData is List) {
      fileName = audioData[Random().nextInt(audioData.length)];
    } else {
      fileName = audioData;
    }

    print("🎶 Playing wheel song: telugusongs/$fileName");

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('telugu songs/$fileName'));
  }

  void _stopWheelAudio() async {
    await _musicPlayer.stop();
  }

  void _playClickSound() async {
    
  }

  void _spinWheel() async {
    if (isSpinning) return;

    setState(() => isSpinning = true);
    _playClickSound();

    final int spins = 6;
    final int targetIndex = Random().nextInt(moods.length);
    final double anglePerEmoji = 2 * pi / moods.length;
    final double targetAngle = spins * 2 * pi + (anglePerEmoji * targetIndex);

    _animation = Tween<double>(
      begin: currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    setState(() => selectedIndex = targetIndex);
    _controller.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

 void _playOrPauseSong(Song song) async {
  await _musicPlayer.stop();

  if (_isPlaying && _currentlyPlayingPath == song.path) {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  } else {
    await _audioPlayer.stop();

    print("🎵 Playing favorite song: ${song.path}");

    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Remove 'assets/' prefix if present
    final String assetPath = song.path.replaceFirst('assets/', '');

    await _audioPlayer.play(AssetSource(assetPath));

    setState(() {
      _currentlyPlayingPath = song.path;
      _isPlaying = true;
    });
  }
}
  // void _addToFavorites() {
  //   final mood = moods[selectedIndex];
  //   final audioList = mood['audio'] as List;
  //   final fileName = audioList[0];

  //   final song = Song(
  //     title: '${mood['emoji']} Mood',
  //     subtitle: 'From Emoji Wheel',
  //     path: 'assets/telugu songs/$fileName',
  //   );

  //   final exists = favoriteSongs.any((s) => s.path == song.path);
  //   if (!exists) {
  //     setState(() {
  //       favoriteSongs.insert(0, song);
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Added to Favorites!')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Already in Favorites')),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double wheelSize = 180; 

    return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    title: const Text(
      '',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/favscreen.jpg', fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.4),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Your Favorites",
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: favoriteSongs.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border, size: 60, color: Colors.white70),
                                  SizedBox(height: 12),
                                  Text("No favorites yet", style: TextStyle(fontSize: 18, color: Colors.white70)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: favoriteSongs.length,
                              itemBuilder: (context, index) {
                                final song = favoriteSongs[index];
                                final isCurrent = _currentlyPlayingPath == song.path && _isPlaying;

                                return ListTile(
                                  leading: const Icon(Icons.music_note, color: Colors.orange),
                                  title: Text(song.title, style: const TextStyle(fontSize: 14, color: Colors.black)),
                                  subtitle:
                                      Text(song.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isCurrent ? Icons.pause_circle_filled : Icons.play_arrow,
                                          color: Colors.deepOrange,
                                        ),
                                        onPressed: () => _playOrPauseSong(song),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() => favoriteSongs.remove(song));
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: currentAngle,
                          child: SizedBox(
                            height: wheelSize,
                            width: wheelSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: List.generate(moods.length, (index) {
                                final double angle = (2 * pi / moods.length) * index;
                                final Offset position = Offset(
                                  cos(angle) * wheelSize * 0.35,
                                  sin(angle) * wheelSize * 0.35,
                                );

                                return Transform.translate(
                                  offset: position,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: selectedIndex == index ? 30 : 24,
                                    child: AnimatedScale(
                                      duration: const Duration(milliseconds: 400),
                                      scale: selectedIndex == index ? 1.2 : 1.0,
                                      child: Text(
                                        moods[index]['emoji'],
                                        style: TextStyle(fontSize: selectedIndex == index ? 22 : 18),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _spinWheel,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.pinkAccent,
                            child: Text(
                              moods[selectedIndex]['emoji'],
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _stopWheelAudio,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Music'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  // ElevatedButton.icon(
                  //   onPressed: _addToFavorites,
                  //   icon: const Icon(Icons.favorite, color: Colors.white),
                  //   label: const Text("Add to Favorites"),
                  //   style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

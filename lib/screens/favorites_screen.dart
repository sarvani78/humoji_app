import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:humoji_app/global_state.dart';
import 'package:humoji_app/models/song.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playOrPauseSong(Song song) async {
    if (_isPlaying && _currentlyPlayingPath == song.path) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(song.path.replaceFirst('assets/', '')));
      setState(() {
        _currentlyPlayingPath = song.path;
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          "Favorites",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoriteSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No favorites yet",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
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
                  title: Text(song.title),
                  subtitle: Text(song.subtitle),
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
                          setState(() {
                            favoriteSongs.remove(song);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

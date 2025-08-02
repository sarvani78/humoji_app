import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:humoji_app/models/song.dart';

class VoiceAssistantScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> emojiSongMap;

  const VoiceAssistantScreen({super.key, required this.emojiSongMap});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isPlaying = false;
  String _voiceInput = '';
  String? _currentlyPlayingPath;
  List<Song> _matchedSongs = [];
  List<Song> favoriteSongs = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _voiceInput = result.recognizedWords.trim();
            });
            _searchSongByVoice(_voiceInput);
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _searchSongByVoice(String voiceInput) {
    final query = voiceInput.toLowerCase().trim();
    final allSongs = widget.emojiSongMap.values.expand((list) => list).toList();

    final matchedSongs = allSongs.where((song) {
      final title = song['title']!.toLowerCase().trim();
      return title.contains(query) || query.contains(title);
    }).toList();

    setState(() {
      _matchedSongs = matchedSongs
          .map((song) => Song(
                title: song['title']!,
                subtitle: song['subtitle']!,
                path: song['path']!,
              ))
          .toList();
    });
  }

  void _playSong(Song song) async {
    if (_currentlyPlayingPath == song.path && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
      return;
    }

    await _audioPlayer.stop();
    final correctedPath =
        song.path.startsWith("assets/") ? song.path.replaceFirst("assets/", "") : song.path;

    try {
      await _audioPlayer.play(AssetSource(correctedPath));
      setState(() {
        _currentlyPlayingPath = song.path;
        _isPlaying = true;
      });
      print("Playing: $correctedPath");
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/voice.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _voiceInput.isEmpty
                          ? "Feeling Something? Just say It.."
                          : "Your Feeling: $_voiceInput",
                      style: const TextStyle(
                          fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isListening ? 120 : 80,
                        height: _isListening ? 120 : 80,
                        decoration: BoxDecoration(
                          color:
                              _isListening ? Colors.white.withOpacity(0.7) : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _matchedSongs.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final song = _matchedSongs[index];
                  final isCurrent = _currentlyPlayingPath == song.path && _isPlaying;
                  final isFavorite = favoriteSongs.contains(song);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Text(song.subtitle,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isCurrent ? Icons.pause_circle_filled : Icons.play_arrow,
                            color: Colors.deepOrange,
                          ),
                          onPressed: () => _playSong(song),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isFavorite) {
                                favoriteSongs.remove(song);
                              } else {
                                favoriteSongs.add(song);
                              }
                              print(
                                'Favorites now: ${favoriteSongs.map((s) => s.title).toList()}',
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

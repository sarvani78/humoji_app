import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'profile_screen.dart';

class EmojiHomeScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, List<Map<String, String>>> emojiSongMap;

  const EmojiHomeScreen({
    super.key,
    required this.selectedLanguage,
    required this.emojiSongMap,
  });

  @override
  State<EmojiHomeScreen> createState() => _EmojiHomeScreenState();
}

class _EmojiHomeScreenState extends State<EmojiHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _currentEmoji = '';
  bool showEmojiPicker = false;
  bool showSongList = false;
  bool _isPlaying = false;
  String? _currentlyPlayingPath;
  final String _message = '';

  List<Map<String, String>> _currentSongList = [];

  void _playSong(String path) async {
    if (_isPlaying && _currentlyPlayingPath == path) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
      setState(() {
        _isPlaying = true;
        _currentlyPlayingPath = path;
      });
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _controller.text = emoji.emoji;
    _handleEmojiInput(emoji.emoji);
  }

  void _handleEmojiInput(String emoji) {
    List<Map<String, String>>? selectedSongs;

    for (var entry in widget.emojiSongMap.entries) {
      if (entry.key.contains(emoji)) {
        selectedSongs = entry.value;
        break;
      }
    }

    setState(() {
      _currentEmoji = emoji;
      showSongList = selectedSongs != null;
      _currentSongList = selectedSongs ?? [];
    });
  }

  void _clearInput() {
    _controller.clear();
    _audioPlayer.stop();
    setState(() {
      _currentEmoji = '';
      showSongList = false;
      _currentSongList = [];
      _isPlaying = false;
      _currentlyPlayingPath = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language: ${widget.selectedLanguage}',
                  style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Emoji in. Music out',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.deepOrange, width: 2),
                  ),
                  child: Row(
                    children: [
  const Icon(Icons.search),
  const SizedBox(width: 8),
  // ✅ Show selected emoji here
  Text(
    _currentEmoji.isNotEmpty ? _currentEmoji : 'Search with emoji...',
    style: const TextStyle(fontSize: 18, color: Colors.black54),
  ),
  const Spacer(),
  IconButton(
    icon: const Icon(Icons.clear, color: Colors.red),
    onPressed: _clearInput,
  ),
  IconButton(
    icon: const Icon(Icons.emoji_emotions, color: Colors.orange),
    onPressed: () => setState(() => showEmojiPicker = !showEmojiPicker),
  ),
],

                  ),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_message, style: const TextStyle(color: Colors.deepOrange)),
                  ),
                const SizedBox(height: 10),
                if (showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (Category? category, Emoji emoji) => _onEmojiSelected(emoji),
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32,
                        bgColor: const Color(0xFFF2F2F2),
                        indicatorColor: Colors.orange,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.orange,
                        initCategory: Category.SMILEYS,
                        recentsLimit: 28,
                        buttonMode: ButtonMode.MATERIAL,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if (showSongList)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: ListView.builder(
                        itemCount: _currentSongList.length,
                        itemBuilder: (context, index) {
                          final song = _currentSongList[index];
                          final isCurrent = _currentlyPlayingPath == song['path'] && _isPlaying;

                          return ListTile(
                            leading: const Icon(Icons.music_note, color: Colors.orange),
                            title: Text(song['title']!, style: const TextStyle(fontSize: 14, color: Colors.black)),
                            subtitle: Text(song['subtitle']!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            trailing: IconButton(
                              icon: Icon(
                                isCurrent ? Icons.pause_circle_filled : Icons.play_arrow,
                                color: Colors.deepOrange,
                              ),
                              onPressed: () => _playSong(song['path']!),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 177, 229, 253),
                      Color.fromARGB(255, 227, 121, 243),
                      Color.fromARGB(255, 248, 74, 61),
                      Color.fromARGB(255, 242, 177, 80),
                      Color.fromARGB(255, 236, 222, 99),
                      Color.fromARGB(255, 79, 181, 82),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home, size: 28, color: Colors.black87),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, size: 28, color: Colors.black87),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline, size: 28, color: Colors.black87),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String loveEmojis = '😍🥰😘😚💋🫀🫂👩‍❤‍👨👩‍❤️‍👩💑👨‍❤️‍👨👩‍❤‍💋‍👨👩‍❤️‍💋‍👩💏👨‍❤️‍💋‍👨🩷❤🧡💛💛💚🩵💙💜🖤🩶🤍🤎❤‍🔥❣💕💞💓💗💖💘💝💟♥';
const String sadEmojis = '🙃🙂😞😔😟😕🙁☹️😣😖😩😫🥺😢😭💔❤‍🩹😥😿😪😓';
const String happyEmojis = '😀😃😄😆😎😋😜🥳';
const String retroEmojis = '🎥📼🎬';
const String itemEmojis = '💃🕺🪩';


class TeluguScreen extends StatelessWidget {
  const TeluguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> teluguEmojiSongMap = {
      loveEmojis: [
        {'title': 'kola-kalle-ila', 'subtitle': 'Javed Ali', 'path': 'assets/telugu songs/Kola-Kalle-Ila.mp3'},
      ],
      sadEmojis: [
        {'title': 'Oosupodu', 'subtitle': 'Sid Sriram', 'path': 'assets/telugu songs/sad2.mp3'},
      ],
      retroEmojis:[
        {'title':'taralirada','subtitle':'SPB','path': 'assets/telugu songs/taralirada.mp3'}
        ],
      itemEmojis: [
        {'title': 'dabidi dibidi', 'subtitle': 'Armaan Malik', 'path': 'assets/telugu songs/item.mp3'},
      ],
    };

    return EmojiHomeScreen(
      selectedLanguage: 'తెలుగు',
      emojiSongMap: teluguEmojiSongMap,
    );
  }
}

class EnglishScreen extends StatelessWidget {
  const EnglishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> englishEmojiSongMap = {
      loveEmojis: [
        {'title': 'Perfect', 'subtitle': 'Ed Sheeran', 'path': 'assets/perfect.mp3'},
        {'title': 'All of Me', 'subtitle': 'John Legend', 'path': 'assets/all_of_me.mp3'},
      ],
      sadEmojis: [
        {'title': 'Someone Like You', 'subtitle': 'Adele', 'path': 'assets/someone_like_you.mp3'},
      ],
      happyEmojis: [
        {'title': 'Happy', 'subtitle': 'Pharrell Williams', 'path': 'assets/happy.mp3'},
        {'title': 'Can’t Stop the Feeling', 'subtitle': 'Justin Timberlake', 'path': 'assets/cant_stop.mp3'},
      ],
    };

    return EmojiHomeScreen(
      selectedLanguage: 'English',
      emojiSongMap: englishEmojiSongMap,
    );
  }
}

class HindiScreen extends StatelessWidget {
  const HindiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> hindiEmojiSongMap = {
      loveEmojis: [
        {'title': 'Heeriye', 'subtitle': 'Jubin Nautiyal', 'path': 'assets/heeriye.mp3'},
        {'title': 'Raataan Lambiyan', 'subtitle': 'Jubin Nautiyal', 'path': 'assets/raataan.mp3'},
      ],
      sadEmojis: [
        {'title': 'Tum Hi Ho', 'subtitle': 'Arijit Singh', 'path': 'assets/tum_hi_ho.mp3'},
        {'title': 'Channa Mereya', 'subtitle': 'Arijit Singh', 'path': 'assets/channa_mereya.mp3'},
      ],
      happyEmojis: [
        {'title': 'Kar Gayi Chull', 'subtitle': 'Badshah', 'path': 'assets/kar_gayi_chull.mp3'},
        {'title': 'Tareefan', 'subtitle': 'Badshah', 'path': 'assets/tareefan.mp3'},
      ],
    };

    return EmojiHomeScreen(
      selectedLanguage: 'हिंदी',
      emojiSongMap: hindiEmojiSongMap,
    );
  }
}

class TamilScreen extends StatelessWidget {
  const TamilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> tamilEmojiSongMap = {
      loveEmojis: [
        {'title': 'Munbe Vaa', 'subtitle': 'Shreya Ghoshal', 'path': 'assets/munbe_vaa.mp3'},
        {'title': 'Enna Solla', 'subtitle': 'Shankar Mahadevan', 'path': 'assets/enna_solla.mp3'},
      ],
      sadEmojis: [
        {'title': 'Vinnaithaandi Varuvaayaa', 'subtitle': 'Karthik', 'path': 'assets/vtv.mp3'},
      ],
      happyEmojis: [
        {'title': 'Vaathi Coming', 'subtitle': 'Anirudh Ravichander', 'path': 'assets/vaathi_coming.mp3'},
        {'title': 'Donu Donu Donu', 'subtitle': 'Anirudh & Neeti Mohan', 'path': 'assets/donu_donu.mp3'},
      ],
    };

    return EmojiHomeScreen(
      selectedLanguage: 'தமிழ்',
      emojiSongMap: tamilEmojiSongMap,
    );
  }
}

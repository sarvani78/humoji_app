import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_preview/device_preview.dart';


class EmojiHomeScreen extends StatefulWidget {
  const EmojiHomeScreen({super.key, required selectedLanguage});

  @override
  State<EmojiHomeScreen> createState() => _EmojiHomeScreenState();
}

class _EmojiHomeScreenState extends State<EmojiHomeScreen> {
  bool showEmojiPicker = false;
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _currentEmoji = '';
  bool showSongList = false;
  bool _isPlaying = false;
  String? _currentlyPlayingPath;

  final List<String> loveEmojis = ['❤','🩷','🧡','💛','💚','💙','🩵','💜','🤎','🖤','🩶','🤍','❤‍🔥','❣','💕','💞','💗','💖','💘','💝','💟','💌','😍','😘','🥰','🤩','😗','😙','🤩','🤗','🫠','🫣','🙈','😽','😻','🫀','🫦','🫶','🫰','🎀','💋','♥','🌹','🌸','🏵','🌺','🌻','🌼','🌷'];
  final List<String> sadEmojis = ['🥲','😔','☹','🥺','🥹','😥','😢','😖','😓','😿','😾','🙍‍♀','🙎‍♂','🙎‍♀','🥀','😭','🙎','💔'];
  final List<String> happyEmojis = ['😀','😁','😃','😄','😆','😉','😊','😎','😋','☺','🙂','😛','😜','😝','🤪','😇','🤭','🫣','😹','😸','😺'];
  final List<String> retroEmojis = ['🎥','🎞','📽','🎬','📼','🎦'];
  final List<String> itemEmojis = ['💃','🕺','🪩','🪭','🩰','👯','👯‍♂','👯‍♀'];


  final List<Map<String, String>> loveSongs = [
    {
      'title': 'Akhiyaan Gulab',
      'subtitle': 'Tanishk Bagchi, Jubin Nautiyal, Asees Kaur',
      'path': 'assets/akhiyaangulab.mp3',
    },
    {
      'title': 'Heeriye',
      'subtitle': 'Payal Dev, Jubin Nautiyal, Kunaal Vermaa',
      'path': 'assets/Heeriye.mp3',
    },
    {
      'title': 'Ishq Hai',
      'subtitle': 'Himesh Reshammiya',
      'path': 'assets/IshqHai.mp3',
    },
    {
      'title': 'Main Rahoon',
      'subtitle': 'Payal Dev, Jubin Nautiyal, Kunaal Vermaa',
      'path': 'assets/mainrahoon.mp3',
    },
    {
      'title': 'Manwa Laage',
      'subtitle': 'Payal Dev, Jubin Nautiyal, Kunaal Vermaa',
      'path': 'assets/ManwaLaage.mp3',
    },
    {
      'title': 'Sawar Loon',
       'subtitle': 'Payal Dev, Jubin Nautiyal, Kunaal Vermaa',
      'path': 'assets/sawarloon.mp3',
    },
    {
      'title': 'Tere Bina',
      'subtitle': 'Payal Dev, Jubin Nautiyal, Kunaal Vermaa',
      'path': 'assets/Tere_Bina.mp3',
    },
  ];

  
  final List<Map<String, String>> sadSongs = [
    {
      'title': 'Chana Mereya',
      'subtitle': 'Artist X',
      'path': 'assets/Channamereya.mp3',
    },
        {
      'title': 'Agar Tum Saath Ho',
      'subtitle': 'Artist X',
      'path': 'assets/agartumsaathho.mp3',
    },
      {
      'title': 'Abhi Na Jao Chod',
      'subtitle': 'Artist X',
      'path': 'assets/abhinajao.mp3',
    },
        {
      'title': 'HamariAdhuriKahani',
      'subtitle': 'Artist X',
      'path': 'assets/HamariAdhuriKahani.mp3',
    },
        {
      'title': 'Satranga',
      'subtitle': 'Artist X',
      'path': 'assets/Satranga.mp3',
    },
        {
      'title': 'Shayad',
      'subtitle': 'Artist X',
      'path': 'assets/Shayad.mp3',
    },
        {
      'title': 'Tum Hi Ho',
      'subtitle': 'Artist X',
      'path': 'assets/Tum Hi Ho.mp3',
    },
      
  ];



  final List<Map<String, String>> happySongs = [
    {'title': 'Happy Beats', 'subtitle': 'DJ Smile', 'path': 'assets/happy1.mp3'},
    {'title': 'Good Vibes', 'subtitle': 'Feel Crew', 'path': 'assets/happy2.mp3'},
  ];

  final List<Map<String, String>> retroSongs = [
    {'title': 'Retro Vibes', 'subtitle': 'Classic Era', 'path': 'assets/retro1.mp3'},
    {'title': 'Nostalgia', 'subtitle': 'Old Gold', 'path': 'assets/retro2.mp3'},
  ];

  final List<Map<String, String>> itemSongs = [
    {'title': 'Party Anthem', 'subtitle': 'Groove Hit', 'path': 'assets/item1.mp3'},
    {'title': 'Dance Floor', 'subtitle': 'Shake Beat', 'path': 'assets/item2.mp3'},
  ];

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
    emoji = emoji.trim();

    List<Map<String, String>>? selectedSongs;

    if (loveEmojis.contains(emoji)) {
      selectedSongs = loveSongs;
    } else if (sadEmojis.contains(emoji)) {
      selectedSongs = sadSongs;
    } else if (happyEmojis.contains(emoji)) {
      selectedSongs = happySongs;
    } else if (retroEmojis.contains(emoji)) {
      selectedSongs = retroSongs;
    } else if (itemEmojis.contains(emoji)) {
      selectedSongs = itemSongs;
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
                const Text(
                  'Emoji in. Music out',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.deepOrange, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          style: const TextStyle(fontSize: 22),
                          onFieldSubmitted: _handleEmojiInput,
                          decoration: const InputDecoration(
                            hintText: 'Enter emoji',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
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
                const SizedBox(height: 10),
                if (showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (Category? category, Emoji emoji) {
                        _onEmojiSelected(emoji);
                      },
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32,
                        bgColor: const Color(0xFFF2F2F2),
                        indicatorColor: Colors.orange,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.orange,
                        initCategory: Category.SMILEYS,
                        recentsLimit: 28,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if (showSongList)
                  Center(
                    child: Container(
                      width: 350,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: ListView.builder(
                        itemCount: _currentSongList.length,
                        itemBuilder: (context, index) {
                          final song = _currentSongList[index];
                          final isCurrent = _currentlyPlayingPath == song['path'] && _isPlaying;

                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.music_note, color: Colors.orange),
                            title: Text(song['title']!, style: const TextStyle(fontSize: 14, color: Colors.black)),
                            subtitle: Text(song['subtitle']!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            trailing: IconButton(
                              icon: Icon(isCurrent ? Icons.pause_circle_filled : Icons.play_arrow, color: Colors.deepOrange),
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
        ],
      ),
    );
  }
}
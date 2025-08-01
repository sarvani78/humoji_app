import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:humoji_app/screens/song_player_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'package:humoji_app/models/song.dart';
import 'package:humoji_app/global_state.dart';

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

  List<Song> _currentSongList = [];

  void _playSong(Song song) async {
    if (_isPlaying && _currentlyPlayingPath == song.path) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(song.path.replaceFirst('assets/', '')));
      setState(() {
        _isPlaying = true;
        _currentlyPlayingPath = song.path;
      });
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _controller.text = emoji.emoji;
    _handleEmojiInput(emoji.emoji);
  }

  void _handleEmojiInput(String emoji) async {
  List<Map<String, String>>? selectedSongsMap;

  for (var entry in widget.emojiSongMap.entries) {
    if (entry.key.contains(emoji)) {
      selectedSongsMap = entry.value;
      break;
    }
  }

  if (selectedSongsMap == null) {
    final allSongs = widget.emojiSongMap.values.expand((list) => list).toList();
    allSongs.shuffle();
    selectedSongsMap = allSongs.take(5).toList();

    // Play a random song automatically
    final randomSong = selectedSongsMap[0];
    final song = Song(
      title: randomSong['title']!,
      subtitle: randomSong['subtitle']!,
      path: randomSong['path']!,
    );
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(song.path.replaceFirst('assets/', '')));
    setState(() {
      _isPlaying = true;
      _currentlyPlayingPath = song.path;
    });
  }

  setState(() {
    _currentEmoji = emoji;
    showSongList = selectedSongsMap != null;
    _currentSongList = selectedSongsMap!.map((song) {
      return Song(
        title: song['title']!,
        subtitle: song['subtitle']!,
        path: song['path']!,
      );
    }).toList();
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
                  ' ${widget.selectedLanguage}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
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
                      Text(
                        _currentEmoji.isNotEmpty ? _currentEmoji : '',
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.33,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: ListView.builder(
                        itemCount: _currentSongList.length,
                        itemBuilder: (context, index) {
                          final song = _currentSongList[index];
                          final isCurrent = _currentlyPlayingPath == song.path && _isPlaying;
                          final isFavorite = favoriteSongs.contains(song);

                          return ListTile(
                            leading: const Icon(Icons.music_note, color: Colors.orange),
                            title: Text(song.title,
                                style: const TextStyle(fontSize: 14, color: Colors.black)),
                            subtitle: Text(song.subtitle,
                                style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                               IconButton(
  icon: Icon(
    isCurrent ? Icons.pause_circle_filled : Icons.play_arrow,
    color: Colors.deepOrange,
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongPlayerScreen(song: song),
      ),
    );
  },
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
                                      print('Favorites now: ${favoriteSongs.map((s) => s.title).toList()}');
                                    });
                                  },
                                ),
                              ],
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
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
    ).then((_) {
      
      setState(() {});
    });
  },
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
const String loveEmojis = '😍🥰😘😚💋🫀🫂👩‍❤‍👨👩‍❤️‍👩💑👨‍❤️‍👨👩‍❤‍💋‍👨👩‍❤️‍💋‍👩💏👨‍❤️‍💋‍👨🩷❤🧡💛💛💚🩵💙💜🖤🩶🤍🤎❤‍🩹❤‍🔥❣💕💞💓💗💖💘💝💟♥';
const String sadEmojis = '🙃🙂😞😔😟😕🙁☹️😣😖😩😫🥺😢😭💔❤‍🩹😥😿😪😓';
const String happyEmojis = '😀 😃 😄 😁 😆 😂 🤣 😊 😇😺 😸 😻 🥳 🤗 🙌 👏 ✨ 🎉';
const String retroEmojis = '☎️ 📼 📻 📺 🕹️ 📷 📞💿 📀 📟 🧮 📠 🧾🧷 🧵 🧶 🎞️ 🧲';
const String itemEmojis = '💃 🕺 🩰 👯 👯‍♀️ 👯‍♂️ 🪩 🎶 🎵 🎧 🥳 🎤 🎼 🎷 🪗 🥁 🪘 ✨';

class TeluguScreen extends StatelessWidget {
  const TeluguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> teluguEmojiSongMap = {
      loveEmojis: [
        {'title': 'kola-kalle-ila', 'subtitle': 'sidsriram', 'path': 'assets/telugu songs/Kola-Kalle-Ila.mp3'},
        {'title': 'beautiful love', 'subtitle': 'src', 'path': 'assets/telugu songs/beautiful love.mp3'},
        {'title': 'prema velluva', 'subtitle': 'arjith singh', 'path': 'assets/telugu songs/prema velluva.mp3'},
        {'title': 'prema O prema', 'subtitle': 'SidSriram', 'path': 'assets/telugu songs/Prema_O_Prema.mp3'},
        {'title': 'nene kaani nenai undaga', 'subtitle': 'Javed Ali', 'path': 'assets/telugu songs/sikindhar.mp3'},
        {'title': 'yemito', 'subtitle': 'Hemachandra', 'path': 'assets/telugu songs/nuvve_leni_nenu.mp3'},
  ],
      sadEmojis: [
        {'title': 'Bujji thalli', 'subtitle': 'Anurag', 'path': 'assets/telugu songs/bujji thalli.mp3'},
        {'title': 'badhulu tochani', 'subtitle': 'Hemachandra', 'path': 'assets/telugu songs/badhulu tochani.mp3'},
        {'title': 'aakasam lona', 'subtitle': 'sunitha', 'path': 'assets/telugu songs/aakasam lona.mp3'},
        {'title': 'yemai poyave', 'subtitle': 'SidSriram', 'path': 'assets/telugu songs/yemai poyave.mp3'},
        {'title': 'kuberaa', 'subtitle': 'DSP', 'path': 'assets/telugu songs/kuberaa.mp3'},
        {'title': 'Oosupodu', 'subtitle': 'DSP', 'path': 'assets/telugu songs/oosupodu.mp3'},
      ],
      retroEmojis:[
        {'title': 'andhalalo', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/andhalalo.mp3'},
        {'title': 'maateraani', 'subtitle': 'SPB', 'path': 'assets/telugu songs/maaterani.mp3'},
        {'title': 'vennelave vennelave', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/vennelave vennelave.mp3'},
        {'title': 'priya priya', 'subtitle': 'sirivennela', 'path': 'assets/telugu songs/priya priya.mp3'},
        {'title': 'pachani chilukalu', 'subtitle': 'SPB', 'path': 'assets/telugu songs/pachani chilukalu.mp3'},
        {'title':'taralirada','subtitle':'SPB','path': 'assets/telugu songs/taralirada.mp3'},
        {'title': 'jilibilipalukula', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/jilibili.mp3'},

      ],
      happyEmojis:[
        {'title': 'Hoyna Hoyna', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/hoyna hoyna.mp3'},
        {'title': 'O madhu', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/O madhu.mp3'},
        {'title': 'gaallo thelinattundhe', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/gaallo.mp3'},
       {'title': 'chitti', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/chitti.mp3'},
       {'title': 'cinema chupistha mawa', 'subtitle': 'ilayaraja', 'path': 'assets/telugu songs/cinema.mp3'},

      ],
      itemEmojis: [
        {'title': 'dabidi dibidi', 'subtitle': 'thaman', 'path': 'assets/telugu songs/dabidi dibidi.mp3'},
        {'title': 'ringa ringa', 'subtitle': 'DSP', 'path': 'assets/telugu songs/ringa ringa.mp3'},
        {'title': 'bommali', 'subtitle': 'DSP', 'path': 'assets/telugu songs/bommali.mp3'},
        {'title': 'swingzara', 'subtitle': 'Thaman', 'path': 'assets/telugu songs/swing zara.mp3'},
        {'title': 'peelings', 'subtitle': 'DSP', 'path': 'assets/telugu songs/peelings.mp3'},
        {'title': 'pakka local', 'subtitle': 'DSP', 'path': 'assets/telugu songs/pakka local.mp3'},
      ],
    };

    return EmojiHomeScreen(
      selectedLanguage: 'నమస్కారం..🙏',
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
        {'title': 'i wanna be yours', 'subtitle': 'Arctic Monkeys', 'path': 'assets/english songs/i wanna be yours.mp3'},
        {'title': 'dandelions', 'subtitle': 'Ruth B', 'path': 'assets/english sons/dandelions.mp3'},
        {'title': 'SugarBrowines','subtitle': 'DHARIA','path': 'assets/english songs/SugarBrownies.mp3'},
        {'title': 'Blue','subtitle': 'Eiffle 65','path': 'assets/english songs/Blue.mp3'},
        {'title': 'Until I Found You','subtitle': 'Stephen Sanchez','path': 'assets/english songs/Until I Found You.mp3'},
        {'title': 'Beautiful Things','subtitle': 'Benson Boone','path': 'assets/english songs/beautiful things.mp3'},
      ],
      sadEmojis: [
        {'title': 'Moral Of The Story', 'subtitle': 'Adele', 'path': 'assets/english songs/moral of the story.mp3'},
        {'title': 'little do you know','subtitle': 'Paul','path': 'assets/english songs/little do you know.mp3'},
        {'title': 'Dancing With Your  Ghost','subtitle': 'Sasha Alex','path': 'assets/english songs/dancing with your ghost.mp3'},
        {'title': 'Let Her Go','subtitle': 'Jasmine','path': 'assets/english songs/let her go.mp3'},
        {'title': 'These Memories','subtitle': 'Hollow Cloves','path': 'assets/english songs/These Memories.mp3'},
      ],
      happyEmojis: [
        {'title': 'Cheri Cheri Lady', 'subtitle': 'Modern Talkisng', 'path': 'assets/english songs/Cheri Cheri Lady.mp3'},
        {'title': 'CheapThrills', 'subtitle': 'Justin Timberlake', 'path': 'assets/english songs/CheapThrills.mp3'},
        {'title': 'Blue','subtitle': 'Eiffle 65','path': 'assets/english songs/Blue.mp3'},
        {'title': 'Bones','subtitle': 'Imagine Dragons','path': 'assets/english songs/Bones.mp3'},
        {'title': 'SugarBrowines','subtitle': 'DHARIA','path': 'assets/english songs/SugarBrownies.mp3'},
      ],
      retroEmojis: [
        {'title': 'Pretty Little Baby','subtitle': 'Connie Francis','path': 'assets/english songs/prettyl little baby.mp3'},
        {'title': 'Just What I Needed','subtitle': 'The Cars','path': 'assets/english songs/Just What I Needed.mp3'},
        {'title': 'Thirteen','subtitle': 'Big Star','path': 'assets/english songs/Thirteen.mp3'},
        {'title': 'She so High','subtitle': 'Tal Bachman','path': 'assets/english songs/She so High.mp3'},       
      ],
      itemEmojis: [
         {'title': 'Leviating','subtitle': 'DHARIA','path': 'assets/english songs/Leviating.mp3'},
         {'title': 'Unstoppable','subtitle': 'Sia','path': 'assets/english songs/Unstoppable.mp3'},
         {'title': 'Espresso','subtitle': 'Lailaa','path': 'assets/english songs/espresso.mp3'},
         {'title': 'Hips Dont Lie','subtitle': 'Wyclef jean','path': 'assets/english songs/Hips Dont Lie.mp3'},
      ],
    };
    return EmojiHomeScreen(
      selectedLanguage: 'Welcome..🙏',
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
    {'title': 'Heeriye', 'subtitle': 'Jubin Nautiyal', 'path': 'assets/hindi songs/Heeriye.mp3'},
    {'title': 'Raataan Lambiyan', 'subtitle': 'Jubin Nautiyal', 'path': 'assets/raataan.mp3'},
    {'title': 'Ik vaari aa', 'subtitle': '', 'path': 'assets/hindi songs/Ik vaari aa.mp3'},
    {'title': 'Manwa Laage', 'subtitle': '', 'path': 'assets/hindi songs/ManwaLaage.mp3'},
    {'title': 'Tere Bina', 'subtitle': '', 'path': 'assets/hindi songs/Tere_Bina.mp3'},
  ],
  sadEmojis: [
    {'title': 'Tum Hi Ho', 'subtitle': 'Arijit Singh', 'path': 'assets/hindi songs/Tum Hi Ho.mp3'},
    {'title': 'Channa Mereya', 'subtitle': 'Arijit Singh', 'path': 'assets/hindi songs/Channamereya.mp3'},
    {'title': 'Hamari Adhuri Kahani', 'subtitle': '', 'path': 'assets/hindi songs/HamariAdhuriKahani.mp3'},
    {'title': 'Matargashti', 'subtitle': '', 'path': 'assets/hindi songs/Matargashti.mp3'},
    {'title': 'Main Rahoon Ya Na Rahoon', 'subtitle': '', 'path': 'assets/hindi songs/mainrahoon.mp3'},
  ],
  happyEmojis: [
    {'title': 'Kar Gayi Chull', 'subtitle': 'Badshah', 'path': 'assets/kar_gayi_chull.mp3'},
    {'title': 'Tareefan', 'subtitle': 'Badshah', 'path': 'assets/tareefan.mp3'},
    {'title': 'Nachde Ne', 'subtitle': '', 'path': 'assets/hindi songs/Nachde Ne.mp3'},
    {'title': 'Satranga', 'subtitle': '', 'path': 'assets/hindi songs/Satranga.mp3'},
    {'title': 'Sawarlon', 'subtitle': '', 'path': 'assets/hindi songs/sawarlon.mp3'},
  ],
  retroEmojis: [
    {'title': 'Aaj Ki Raat', 'subtitle': '', 'path': 'assets/hindi songs/Aaj Ki Raat.mp3'},
    {'title': 'Bachna Ae Haseeno', 'subtitle': '', 'path': 'assets/hindi songs/BachnaAeHaseeno.mp3'},
    {'title': 'Kajra Mohabbat Wala', 'subtitle': '', 'path': 'assets/hindi songs/Kajra Mohabbat Wala.mp3'},
    {'title': 'Roop Tera Mastana', 'subtitle': '', 'path': 'assets/hindi songs/Roop Tera Mastana.mp3'},
    {'title': 'Ye Raatein', 'subtitle': '', 'path': 'assets/hindi songs/Ye raatein.mp3'},
  ],
  itemEmojis: [
    {'title': 'Chikni Chameli', 'subtitle': '', 'path': 'assets/hindi songs/Chikni Chameli.mp3'},
    {'title': 'Fevicol Se', 'subtitle': '', 'path': 'assets/hindi songs/Fevicol Se.mp3'},
    {'title': 'Tip Tip Barsa Paani', 'subtitle': '', 'path': 'assets/hindi songs/Tip Tip Barsa Paani.mp3'},
    {'title': 'Teri Baaton Mein', 'subtitle': '', 'path': 'assets/hindi songs/Teri Baaton Mein.mp3'},
    {'title': 'Ek Do Teen', 'subtitle': '', 'path': 'assets/hindi songs/ekdotheen.mp3'},
  ],
};

    return EmojiHomeScreen(
      selectedLanguage: 'नमस्कार..🙏',
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
        {'title': 'Aasa Kooda', 'subtitle': 'G.V. Prakash', 'path': 'assets/tamil songs/Aasa Kooda.mp3'},
        {'title': 'Mundhinam', 'subtitle': 'Harris', 'path': 'assets/tamil songs/Mundhinam.mp3'},
        {'title': 'Unnale', 'subtitle': 'Hariharan', 'path': 'assets/tamil songs/Unnale.mp3'},
        {'title': 'Vaseegara', 'subtitle': 'Bombay Jayashree', 'path': 'assets/tamil songs/Vaseegara.mp3'},
        {'title': 'Kadhal Sadugudu', 'subtitle': 'SPB', 'path': 'assets/tamil songs/Kadhal Sadugudu.mp3'},
        {'title': 'En Kanmani', 'subtitle': 'S.P. Balasubrahmanyam', 'path': 'assets/tamil songs/En Kanmani.mp3'},
      ],
      sadEmojis: [
        {'title': 'Thanganiram', 'subtitle': 'Harris', 'path': 'assets/tamil songs/Thanganiram.mp3'},
        {'title': 'Sugam Sugame', 'subtitle': 'Vijay Yesudas', 'path': 'assets/tamil songs/Sugam Sugame.mp3'},
        {'title': 'Porkanda Singam', 'subtitle': 'D.Imman', 'path': 'assets/tamil songs/Porkanda Singam.mp3'},
        {'title': 'Golden Sparrow', 'subtitle': 'Vijay Prakash', 'path': 'assets/tamil songs/Golden Sparrow.mp3'},
        {'title': 'pottu Thotta Pournami', 'subtitle': 'A.R.Rahman', 'path': 'assets/tamil songs/pottu Thotta Pournami.mp3'},
      ],
      happyEmojis: [
        {'title': 'Aathangara Marame', 'subtitle': 'Yuvan Shankar Raja', 'path': 'assets/tamil songs/Aathangara Marame.mp3'},
        {'title': 'Adipoli', 'subtitle': 'Vijay', 'path': 'assets/tamil songs/Adipoli.mp3'},
        {'title': 'Balle Lakka', 'subtitle': 'Shreya Ghoshal', 'path': 'assets/tamil songs/Balle Lakka.mp3'},
        {'title': 'Nee Singam Dhan', 'subtitle': 'Saabash', 'path': 'assets/tamil songs/Nee Singam Dhan.mp3'},
        {'title': 'Thuli Thuli Mazhaiyaai', 'subtitle': 'Karthikeya', 'path': 'assets/tamil songs/Thuli Thuli Mazhaiyaai.mp3'},
      ],
      itemEmojis: [
        {'title': 'Daddy Mummy', 'subtitle': 'Kannan', 'path': 'assets/tamil songs/Daddy Mummy.mp3'},
        {'title': 'Damakku Damakku', 'subtitle': 'Vijay Antony', 'path': 'assets/tamil songs/Damakku Damakku.mp3'},
        {'title': 'Jalabulajangu', 'subtitle': 'Yuvan Shankar Raja', 'path': 'assets/tamil songs/Jalabulajangu.mp3'},
        {'title': 'Jolly O Gymkhana', 'subtitle': 'Anirudh', 'path': 'assets/tamil songs/Jolly O Gymkhana.mp3'},
        {'title': 'Kaavalaa', 'subtitle': 'Srikanth Deva', 'path': 'assets/tamil songs/Kaavalaa.mp3'},
        {'title': 'Kacheri-Kacheri', 'subtitle': 'Priya Subramaniam', 'path': 'assets/tamil songs/Kacheri-Kacheri.mp3'},
        {'title': 'Private Party', 'subtitle': 'Deva', 'path': 'assets/tamil songs/Private Party.mp3'},
        {'title': 'Two Two Two', 'subtitle': 'Yuvan Shankar Raja', 'path': 'assets/tamil songs/Two Two Two.mp3'},
        {'title': 'Yethi Yethi', 'subtitle': 'Supriya Joshi', 'path': 'assets/tamil songs/Yethi Yethi.mp3'},
      ],
      retroEmojis: [
        {'title': 'Kadhal Sadugudu', 'subtitle': 'SPB', 'path': 'assets/tamil songs/Kadhal Sadugudu.mp3'},
        {'title': 'En Kanmani', 'subtitle': 'S.P. Balasubrahmanyam', 'path': 'assets/tamil songs/En Kanmani.mp3'},
        {'title': 'Nee Singam Dhan', 'subtitle': 'Retro Vibe', 'path': 'assets/tamil songs/Nee Singam Dhan.mp3'},
        {'title': 'Thuli Thuli Mazhaiyaai', 'subtitle': 'Karthikeya', 'path': 'assets/tamil songs/Thuli Thuli Mazhaiyaai.mp3'},
      ]
    };

    return EmojiHomeScreen(
      selectedLanguage: 'வணக்கம்..🙏',
      emojiSongMap: tamilEmojiSongMap,
    );
  }
}
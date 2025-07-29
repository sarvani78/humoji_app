import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:humoji_app/screens/profile_screen.dart';

class EmojiHomeScreen extends StatefulWidget {
  final String selectedLanguage;

  const EmojiHomeScreen({super.key, required this.selectedLanguage});

  @override
  State<EmojiHomeScreen> createState() => _EmojiHomeScreenState();
}

class _EmojiHomeScreenState extends State<EmojiHomeScreen> {
  bool showEmojiPicker = false;
  String emojiText = '';

  void _toggleEmojiPicker() {
    setState(() {
      showEmojiPicker = !showEmojiPicker;
    });
  }

  void _onEmojiSelected(Emoji emoji) {
    setState(() {
      emojiText += emoji.emoji;
    });
  }

  void _clearEmoji() {
    setState(() {
      emojiText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight + 20),
                const Text(
                  'How are you feeling?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 56, 11, 11),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.deepOrange, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          emojiText,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.redAccent),
                        onPressed: _clearEmoji,
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions, color: Colors.orange),
                        onPressed: _toggleEmojiPicker,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),


                if (showEmojiPicker)
                  Container(
                    height: 250,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
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
              ],
            ),
          ),

          // Bottom Navigation
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
                        onPressed: () 
                        {
                          Navigator.push(context, MaterialPageRoute(builder:(context) => ProfileScreen()));
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

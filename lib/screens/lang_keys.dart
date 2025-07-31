import 'package:flutter/material.dart';
import 'home_screen.dart'; // ✅ Import the file that contains EmojiHomeScreen & language classes

class LanguageSelectionScreen extends StatelessWidget {
  final String userName;

  LanguageSelectionScreen({super.key, required this.userName});

  final List<Map<String, dynamic>> languages = [
    {'script': 'తె', 'name': 'తెలుగు', 'color': Colors.amber, 'widget': const TeluguScreen()},
    {'script': 'E', 'name': 'English', 'color': Colors.cyan, 'widget': const EnglishScreen()},
    {'script': 'ह', 'name': 'हिंदी', 'color': Colors.orange, 'widget': const HindiScreen()},
    {'script': 'த', 'name': 'தமிழ்', 'color': Colors.brown, 'widget': const TamilScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 180),
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 172, 17, 17),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 30,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: languages.map((lang) {
                        return LanguageButton(
                          script: lang['script'],
                          name: lang['name'],
                          borderColor: lang['color'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => lang['widget'],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LanguageButton extends StatelessWidget {
  final String script;
  final String name;
  final Color borderColor;
  final VoidCallback onTap;

  const LanguageButton({
    super.key,
    required this.script,
    required this.name,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click, 
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: borderColor, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      script,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

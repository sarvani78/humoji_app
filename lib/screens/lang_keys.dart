import 'package:flutter/material.dart';
import 'package:humoji_app/screens/home_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final String userName;
  LanguageSelectionScreen({super.key, required this.userName});

  final List<Map<String, dynamic>> languages = [
   
    {'script': 'తె', 'name': 'తెలుగు', 'color': Colors.amber},
    {'script': 'E', 'name': 'English', 'color': Colors.cyan},
     {'script': 'ह', 'name': 'हिंदी', 'color': Colors.orange},
    {'script': 'த', 'name': 'தமிழ்', 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/background.jpg'),fit: BoxFit.cover)
          ),
          child: Scaffold(
          backgroundColor: Colors.transparent,
            body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(height: 180,),
      Text(
        'Select Language',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 172, 17, 17)),
      ),
      SizedBox(height: 20),
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
                debugPrint(userName);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                     EmojiHomeScreen(selectedLanguage: lang['name']),
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
      margin: EdgeInsets.all(4),
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    name,
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
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

import 'package:flutter/material.dart';
import 'package:humoji_app/screens/home_screen.dart';
import 'package:humoji_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('loggedInUserName') ?? 'User';
      userEmail = prefs.getString('loggedInUserEmail') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Colors.amberAccent, Colors.white],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.transparent,
                      foregroundImage: AssetImage('profile.jpg'),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  userName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Divider(height: 40),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile Settings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Update and modify your profile'),
                  onTap: () async {
                   await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen()),
                    );
                    _loadUserDetails(); 
                  },

                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Privacy',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Change your password'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyScreen()),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Personalize preferences'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About Us',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Know more about our team'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsScreen()),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('currentLoggedInEmail');

                   Navigator.pushAndRemoveUntil(
                     context, MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false,
                      );
 
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ResetPassScreen extends StatelessWidget {
  const ResetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.yellow],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(''), backgroundColor: Colors.transparent),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RESET PASSWORD',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.amber[100],
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _saveNewPassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInUserEmail');

    if (email != null) {
      await prefs.setString(email, newPassword); // Save new password for the email
      _showMessage('Password updated successfully');
    } else {
      _showMessage('User email not found. Please log in again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Privacy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              _buildPasswordField('New Password', _passwordController, true),
              _buildPasswordField('Confirm Password', _confirmPasswordController, true),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPassScreen()),
                    );
                  },
                  child: Text(
                    '',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNewPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  'Save Password',
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller, bool obscureText) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            labelText: hint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userNameController.text = prefs.getString('loggedInUserName') ?? '';
    _emailController.text = prefs.getString('loggedInUserEmail') ?? '';
    _mobileController.text = prefs.getString('loggedInUserMobile') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              SizedBox(height: 16),
              _buildInputField('UserName', _userNameController),
              SizedBox(height: 16),
              _buildInputField('Email', _emailController),
              SizedBox(height: 16),
              _buildInputField('Mobile Number(Optional)', _mobileController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('loggedInUserName', _userNameController.text);
                  await prefs.setString('loggedInUserEmail', _emailController.text);
                  await prefs.setString('loggedInUserMobile', _mobileController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: hint,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isAutoPlay = true;
  String selectedLanguage = 'English';
  String audioQuality = 'Automatic';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Settings'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
            child: ListView(
              children: [
                SwitchListTile(
                  title: Text('Auto Play'),
                  subtitle: Text(
                    'Enjoy your music,song completes we play other songs',
                  ),
                  value: isAutoPlay,
                  onChanged: (val) => setState(() => isAutoPlay = val),
                ),
               ListTile(
  title: const Text('App Language'),
  subtitle: const Text('Preferred App Language'),
  trailing: const Icon(Icons.arrow_drop_down),
  onTap: () {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Language'),
        content: DropdownButton<String>(
          value: selectedLanguage,
          items: ['English', 'Hindi', 'Telugu', 'Tamil']
              .map(
                (lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ),
              )
              .toList(),
          onChanged: (lang) {
            if (lang != null) {
              setState(() {
                selectedLanguage = lang;
              });
              Navigator.pop(context); // Close the dialog first

              // Then navigate based on language
              Future.delayed(Duration(milliseconds: 300), () {
                Widget targetScreen;

                switch (lang) {
                  case 'Telugu':
                    targetScreen = const TeluguScreen();
                    break;
                  case 'Tamil':
                    targetScreen = const TamilScreen();
                    break;
                  case 'Hindi':
                    targetScreen = const HindiScreen();
                    break;
                  case 'English':
                  default:
                    targetScreen = const EnglishScreen();
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => targetScreen),
                );
              });
            }
          },
        ),
      ),
    );
  },
),
             ListTile(
                  title: Text('Audio Quality'),
                  subtitle: Text('Streaming Quality'),
                  trailing: Icon(Icons.arrow_drop_down),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Audio Quality'),
                        content: DropdownButton<String>(
                          value: audioQuality,
                          items: ['Automatic', 'Normal', 'low', 'High']
                              .map(
                                (quality) => DropdownMenuItem(
                                  value: quality,
                                  child: Text(quality),
                                ),
                              )
                              .toList(),
                          onChanged: (quality) {
                            setState(() {
                              selectedLanguage = quality ?? audioQuality;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('About Us'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Text(
                  'We are a dedicated team of developers focused on building inclusive mobile apps for everyone.\n\n'
                  'Our mission is to empower users through simple, elegant, and responsive design.\n\n'
                  '🎶 Welcome to Feel the Music 🎶\n\n'
                  'Music isn\'t just sound—it'
                  'FeelIt Music is built for those moments when words fall short.\n'
                  'Just tap an emoji 😍😢💪 and let the feeling lead you to the perfect track '
                  'in Telugu, Hindi, or English.\n\n'
                  'We believe music discovery should be intuitive and inclusive.\n'
                  'Our emotion-based interface connects hearts beyond languages.\n\n'
                  '🎯 Our mission: To harmonize emotions and languages through music—one tap at a time.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
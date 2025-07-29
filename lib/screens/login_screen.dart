import 'package:flutter/material.dart';
import 'package:humoji_app/screens/lang_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  Future<bool> validateUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString(email);
    return storedPassword == password;
  }

  void _handleLogin() async {
  
    final emailOrPhone = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    bool isValid = await validateUser(emailOrPhone, password);

    if (isValid) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => LanguageSelectionScreen(userName: _loginEmailController.text)),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials. Please sign up first.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/login.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.55,
              padding:  EdgeInsets.all(30),
              decoration:  BoxDecoration(
                color: Color.fromARGB(26, 254, 180, 120),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                     SizedBox(height: 10),
                     Text('Login', style: TextStyle(color: Colors.black, fontSize: 35)),
                     SizedBox(height: 20),
                    TextField(
                      controller: _loginEmailController,
                      decoration:  InputDecoration(
                        hintText: 'Email or Mobile number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Color(0xFFE8F0F2),
                      ),
                    ),
                     SizedBox(height: 15),
                    TextField(
                      controller: _loginPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        border:  OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        prefixIcon:  Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        filled: true,
                        fillColor:  Color(0xFFE8F0F2),
                      ),
                    ),
                     SizedBox(height: 25),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color.fromARGB(255, 248, 179, 89),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _handleLogin,
                        child:  Text('Login', style: TextStyle(fontSize: 20, color: Colors.black)),
                      ),
                    ),
                     SizedBox(height: 40),
                     Text("Don't have an account?"),
                     SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Color.fromARGB(255, 248, 179, 89),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Signup()),
                        );
                      },
                      child:  Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final bool _showLoginButton = false;

  Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(email, password);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final emailOrPhone = _emailController.text.trim();
      final password = _passwordController.text;

      await saveUser(emailOrPhone, password);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created! You can login now.")),
      );

      setState(() {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:  EdgeInsets.symmetric(horizontal: 35, vertical: 25),
              decoration:  BoxDecoration(
                color: Color.fromARGB(26, 254, 180, 120),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                         SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration:  InputDecoration(
                            hintText: 'Enter User Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            prefixIcon: Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                        ),
                         SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration:  InputDecoration(
                            hintText: 'Enter Email or Mobile number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email or mobile number';
                            }

                            bool isGmail = value.contains('@');
                            bool isValidMobile = RegExp(r'^\d{10}$').hasMatch(value);

                            if (!isGmail && !isValidMobile) {
                              return 'Enter vaild Email or mobile number';
                            }

                            return null;
                          },
                        ),
                         SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:  InputDecoration(
                            hintText: 'Enter Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            prefixIcon: Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                        ),
                         SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration:  InputDecoration(
                            hintText: 'Re-enter Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            prefixIcon: Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            } else if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding:  EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            backgroundColor:  Color.fromARGB(255, 248, 179, 89),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _submitForm,
                          child:  Text(
                            'Create Account',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        if (_showLoginButton) ...[
                           SizedBox(height: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:  EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              backgroundColor:  Colors.pink[200],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Login', style: TextStyle(fontSize: 25)),
                          ),
                        ],
                      ],
                    ),
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
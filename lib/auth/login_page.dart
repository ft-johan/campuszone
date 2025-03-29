import 'package:campuszone/auth/forgot_pass.dart';
import 'package:campuszone/auth/register_page.dart';
import 'package:campuszone/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailOrCollegeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(_controller);
    _controller.forward();
  }

  Future<String?> _getEmailFromCollegeId(String collegeId) async {
    final response = await Supabase.instance.client
        .from('users')
        .select('email')
        .eq('collegeid', collegeId)
        .limit(1)
        .maybeSingle();

    return response?['email'];
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        String input = _emailOrCollegeIdController.text.trim().toUpperCase();
        String? email = input;

        if (!input.contains('@')) {
          email = await _getEmailFromCollegeId(input);
          if (email == null) {
            _showSnackBar('No matching College ID found.');
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        if (response.session != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Navbar()),
          );
        } else {
          _showSnackBar('Login failed. Please try again.');
        }
      } catch (e) {
        _showSnackBar('An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void _signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPassPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScaleTransition(
        scale: _animation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child:
                          Icon(LineIcons.lock, size: 120, color: Colors.black),
                    ),
                    const SizedBox(height: 60),
                    const Text("Welcome Back!",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 10),
                    const Text("Please sign in to continue",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 60),
                    TextFormField(
                      controller: _emailOrCollegeIdController,
                      decoration: InputDecoration(
                          labelText: 'Email or College ID',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          prefixIcon: const Icon(LineIcons.user)),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your email or College ID'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        prefixIcon: const Icon(LineIcons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureText
                                  ? LineIcons.eyeAlt
                                  : LineIcons.eyeSlashAlt,
                              color: Colors.black),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your password'
                          : value.length < 6
                              ? 'Password must be at least 6 characters long'
                              : null,
                    ),
                    const SizedBox(height: 10),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text("Forgot Password?",
                                style: TextStyle(color: Colors.grey)))),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15)),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text("Sign In",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24))),
                    ),
                    const SizedBox(height: 10),
                    Center(
                        child: TextButton(
                            onPressed: _signUp,
                            child: const Text("Don't have an account? Sign Up",
                                style: TextStyle(color: Colors.grey)))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailOrCollegeIdController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }
}

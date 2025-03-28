import 'package:campuszone/auth/login_page.dart';
import 'package:campuszone/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final session = snapshot.data?.session;
            if (session != null) {
              return Navbar();
            } else {
              return LoginPage();
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/ui_components.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Zaloguj sie',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 40),
              buildLogo(),
              const SizedBox(height: 40),
              buildCustomTextField(
                controller: _usernameController,
                hintText: 'Nazwa uzytkownika',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              buildCustomTextField(
                controller: _passwordController,
                hintText: 'Haslo',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              buildActionButton(
                text: 'Zaloguj sie',
                color: const Color(0xFFFF7A45),
                isLoading: _isLoading,
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final url = Uri.parse(
                          'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/auth/login/',
                        );
                        try {
                          final response = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode({
                              'username': _usernameController.text,
                              'password': _passwordController.text,
                            }),
                          );
                          if (response.statusCode == 200) {
                            final responseData = jsonDecode(response.body);
                            await _storage.write(
                              key: 'jwt_token',
                              value: responseData['access'],
                            );
                            await _storage.write(
                              key: 'username',
                              value: _usernameController.text,
                            );
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            }
                          } else {
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Blad logowania: ${response.statusCode}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                          }
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Blad polaczenia: $e'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                        } finally {
                          if (mounted)
                            setState(() {
                              _isLoading = false;
                            });
                        }
                      },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nie masz konta? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      'Zarejestruj sie',
                      style: TextStyle(
                        color: Color(0xFF6B72FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

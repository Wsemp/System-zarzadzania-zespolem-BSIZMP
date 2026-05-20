import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/ui_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              buildLogo(),
              const SizedBox(height: 24),
              const Text(
                'Zarejestruj sie',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 32),
              buildCustomTextField(
                controller: _usernameController,
                hintText: 'Nazwa uzytkownika',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              buildCustomTextField(
                controller: _emailController,
                hintText: 'Adres e-mail',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 16),
              buildCustomTextField(
                controller: _passwordController,
                hintText: 'Haslo',
                icon: Icons.key_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              buildCustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Powtorz haslo',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              buildActionButton(
                text: 'Zarejestruj sie',
                color: const Color(0xFF8C7BFF),
                isLoading: _isLoading,
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_passwordController.text !=
                            _confirmPasswordController.text)
                          return;
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          final response = await http.post(
                            Uri.parse(
                              'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/auth/register/',
                            ),
                            headers: {
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode({
                              'username': _usernameController.text,
                              'email': _emailController.text,
                              'password': _passwordController.text,
                            }),
                          );
                          if (response.statusCode == 201 ||
                              response.statusCode == 200) {
                            if (mounted) Navigator.pop(context);
                          }
                        } catch (e) {
                          print(e);
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
                    'Masz juz konto? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Zaloguj sie',
                      style: TextStyle(
                        color: Color(0xFFFF7A45),
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

import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  final String? userType;

  const RegistrationScreen({super.key, this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Registration Screen for: ${userType ?? "Unknown"}'),
            const SizedBox(height: 16),
            const Text('TODO: Implement registration form'),
          ],
        ),
      ),
    );
  }
}

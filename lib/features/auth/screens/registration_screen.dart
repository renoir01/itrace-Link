import 'package:flutter/material.dart';
import '../../registration/screens/farmer_registration_screen.dart';
import '../../registration/screens/aggregator_registration_screen.dart';
import '../../registration/screens/institution_registration_screen.dart';
import '../../registration/screens/agro_dealer_registration_screen.dart';
import '../../registration/screens/seed_producer_registration_screen.dart';

class RegistrationScreen extends StatelessWidget {
  final String? userType;

  const RegistrationScreen({super.key, this.userType});

  @override
  Widget build(BuildContext context) {
    // Route to appropriate registration screen based on user type
    switch (userType?.toLowerCase()) {
      case 'farmer':
      case 'cooperative':
        return const FarmerRegistrationScreen();
      case 'aggregator':
        return const AggregatorRegistrationScreen();
      case 'institution':
      case 'school':
      case 'hospital':
        return const InstitutionRegistrationScreen();
      case 'agro_dealer':
      case 'agro-dealer':
        return const AgroDealerRegistrationScreen();
      case 'seed_producer':
      case 'seed-producer':
        return const SeedProducerRegistrationScreen();
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('Registration')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text('Unknown user type: ${userType ?? "Not specified"}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

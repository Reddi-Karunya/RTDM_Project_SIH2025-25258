import 'package:flutter/material.dart';
import 'login_screen.dart';      // To navigate back to the login screen
import 'main.dart';             // To navigate to the TrainingLogForm
import 'search_screen.dart';  // To navigate to the SearchScreen

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // MODIFIED: Title updated for the new theme
        title: const Text('NDMA Training Dashboard'),
        backgroundColor: Colors.indigo[400],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Navigate back to the LoginScreen and clear the history
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: const Text('Log New Training Session'),
                onPressed: () {
                  Navigator.push(
                    context,
                    // FIX: Changed DoctorEntryForm to the new TrainingLogForm
                    MaterialPageRoute(builder: (context) => const TrainingLogForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                // MODIFIED: Button text updated
                label: const Text('Search Existing Programs'),
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                   textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

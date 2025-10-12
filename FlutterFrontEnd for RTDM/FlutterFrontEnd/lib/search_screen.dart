import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'program_history_screen.dart'; // FIX: Import the correct history screen

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _idController = TextEditingController();

  // MODIFIED: Function logic is updated to search for training programs
  Future<void> _searchProgram() async {
    // Hide the keyboard
    FocusScope.of(context).unfocus();
    
    final String programID = _idController.text.trim();

    if (programID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Program ID to search.')),
      );
      return;
    }

    // MODIFIED: Query the correct 'training_programs' collection
    final programDocRef =
        FirebaseFirestore.instance.collection('training_programs').doc(programID);
    final programSnapshot = await programDocRef.get();

    if (programSnapshot.exists) {
      final programData = programSnapshot.data() as Map<String, dynamic>;
      // MODIFIED: Get the program title
      final programTitle = programData['title'] ?? 'Unknown Program';

      // FIX: Navigate to the new ProgramHistoryScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProgramHistoryScreen(
            programId: programID,
            programTitle: programTitle,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A program with this ID was not found.')),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // MODIFIED: Updated title
        title: const Text('Search Existing Program'),
        backgroundColor: Colors.indigo[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                // MODIFIED: Updated label text
                labelText: 'Enter Unique Program ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // MODIFIED: Call the correct search function
              onPressed: _searchProgram,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

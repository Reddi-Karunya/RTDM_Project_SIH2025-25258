import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart'; // Assuming you have this file

// MODIFIED: Enum for new vs. existing training programs
enum ProgramType { newProgram, existing }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enables offline support for your web app
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const NDMATrainingApp());
}

// MODIFIED: App name changed to reflect the new purpose
class NDMATrainingApp extends StatelessWidget {
  const NDMATrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDMA Training Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // A more official color scheme
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Or TrainingLogForm() for direct testing
    );
  }
}

// MODIFIED: Renamed the main form widget
class TrainingLogForm extends StatefulWidget {
  final String? documentId; // This would be a Program ID if needed later

  const TrainingLogForm({
    super.key,
    this.documentId,
  });

  @override
  State<TrainingLogForm> createState() => _TrainingLogFormState();
}

class _TrainingLogFormState extends State<TrainingLogForm> {
  // MODIFIED: Controllers for new training-related fields
  final _programIdController = TextEditingController();
  final _programTitleController = TextEditingController();
  final _sessionDateController = TextEditingController();
  final _attendeesController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedLocation;
  String? _selectedTheme;
  
  // MODIFIED: List of all Indian states and UTs for the location dropdown
  final List<String> _locations = const [
    'Andaman and Nicobar Islands', 'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 
    'Chandigarh', 'Chhattisgarh', 'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 
    'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Ladakh', 'Lakshadweep', 
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 
    'Odisha', 'Puducherry', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];
  ProgramType _selectedProgramType = ProgramType.newProgram;

  @override
  void dispose() {
    // Clean up all the new controllers
    _programIdController.dispose();
    _programTitleController.dispose();
    _sessionDateController.dispose();
    _attendeesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log New Training Session'),
        backgroundColor: Colors.indigo[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MODIFIED: UI for selecting program type
            SegmentedButton<ProgramType>(
              segments: const <ButtonSegment<ProgramType>>[
                ButtonSegment<ProgramType>(
                  value: ProgramType.newProgram,
                  label: Text('New Program'),
                  icon: Icon(Icons.add),
                ),
                ButtonSegment<ProgramType>(
                  value: ProgramType.existing,
                  label: Text('Existing Program'),
                  icon: Icon(Icons.history),
                ),
              ],
              selected: {_selectedProgramType},
              onSelectionChanged: (Set<ProgramType> newSelection) {
                setState(() {
                  _selectedProgramType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            // MODIFIED: UI fields for training data
            TextField(
              controller: _programIdController,
              decoration: const InputDecoration(
                labelText: 'Unique Program ID',
                hintText: 'e.g., STATE-NGO-001',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _programTitleController,
              enabled: _selectedProgramType == ProgramType.newProgram,
              decoration: InputDecoration(
                labelText: 'Program Title',
                hintText: 'e.g., Community First Responder Training',
                border: const OutlineInputBorder(),
                filled: _selectedProgramType != ProgramType.newProgram,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sessionDateController,
              decoration: const InputDecoration(
                labelText: 'Date of Session',
                hintText: 'e.g., dd-mm-yyyy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _attendeesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Attendees',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location (State/UT)',
                border: OutlineInputBorder(),
              ),
              items: _locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() { _selectedLocation = newValue; });
              },
            ),
             const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedTheme,
              decoration: InputDecoration(
                labelText: 'Training Theme',
                border: const OutlineInputBorder(),
                filled: _selectedProgramType != ProgramType.newProgram,
                fillColor: Colors.grey[200],
              ),
              disabledHint: const Text("Set for new programs only"),
              items: <String>['Earthquake Preparedness', 'Flood Response', 'Cyclone Safety', 'First Aid', 'Community Evacuation', 'Search and Rescue', 'Fire Safety']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: _selectedProgramType == ProgramType.newProgram
                  ? (String? newValue) { setState(() { _selectedTheme = newValue; }); }
                  : null, // Disable if it's an existing program
            ),
            const SizedBox(height: 16),
             TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes / Remarks',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Training Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MODIFIED: The entire data submission logic
  Future<void> _submitData() async {
    // --- 1. VALIDATION ---
    final String programID = _programIdController.text.trim();
    final String date = _sessionDateController.text.trim();
    final RegExp dateFormat = RegExp(r'^([0-2][0-9]|3[0-1])-(0[1-9]|1[0-2])-\d{4}$');

    if (programID.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program ID and Session Date are required.')));
      return;
    }
    if (!dateFormat.hasMatch(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format. Use dd-mm-yyyy.')));
      return;
    }
    
    try {
      final firestore = FirebaseFirestore.instance;

      // --- CHECK FOR DUPLICATE ID (ONLY WHEN CREATING A NEW PROGRAM) ---
      if (_selectedProgramType == ProgramType.newProgram) {
        final programDocRef = firestore.collection('training_programs').doc(programID);
        final docSnapshot = await programDocRef.get();
        if (docSnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A program with this ID already exists. Use "Existing Program" or a new ID.'))
          );
          return; 
        }
      }
      
      final programDocRef = firestore.collection('training_programs').doc(programID);

      // --- 2. PREPARE SESSION DATA ---
      final Map<String, dynamic> sessionData = {
        'date': date,
        'attendees': int.tryParse(_attendeesController.text.trim()) ?? 0,
        'location': _selectedLocation,
        'notes': _notesController.text.trim(),
        'recordedAt': FieldValue.serverTimestamp(),
      };

      // --- 3. EXECUTE DATABASE OPERATIONS ---
      // If it's a brand new program, create its main document first.
      if (_selectedProgramType == ProgramType.newProgram) {
        await programDocRef.set({
          'title': _programTitleController.text.trim(),
          'theme': _selectedTheme,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Add the new session document to the sub-collection. This happens for both new and existing programs.
      await programDocRef.collection('sessions').add(sessionData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Training session for program "$programID" logged successfully!')),
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// MODIFIED: This screen now displays the history for a training program.
class ProgramHistoryScreen extends StatefulWidget {
  final String programId;
  final String programTitle;

  const ProgramHistoryScreen({
    super.key,
    required this.programId,
    required this.programTitle,
  });

  @override
  State<ProgramHistoryScreen> createState() => _ProgramHistoryScreenState();
}

class _ProgramHistoryScreenState extends State<ProgramHistoryScreen> {
  // A Future to hold the list of training sessions
  late Future<List<QueryDocumentSnapshot>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchProgramSessions();
  }

  // MODIFIED: Fetches all 'sessions' for the given 'training_program' ID from Firebase
  Future<List<QueryDocumentSnapshot>> _fetchProgramSessions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('training_programs')
        .doc(widget.programId)
        .collection('sessions')
        .orderBy('recordedAt', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History for ${widget.programTitle}"),
        backgroundColor: Colors.indigo[400],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No training session history found for this program.'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionDoc = sessions[index];
              final sessionData = sessionDoc.data() as Map<String, dynamic>;

              // MODIFIED: The card now displays training session details
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Date: ${sessionData['date'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 16),
                          const SizedBox(width: 8),
                          Text('Location: ${sessionData['location'] ?? 'N/A'}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.grey, size: 16),
                          const SizedBox(width: 8),
                          Text('Attendees: ${sessionData['attendees'] ?? 0}'),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        'Remarks:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(sessionData['notes'] ?? 'No remarks provided.'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class Tab1Screen extends StatelessWidget {
  const Tab1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getTabData('tab1'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No connection to database',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry Connection'),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text(data['description'] ?? 'No description'),
                trailing: Text(
                  data['timestamp']?.toDate().toString() ?? 'No date',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

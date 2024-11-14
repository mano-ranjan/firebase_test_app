import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class Tab3Screen extends StatelessWidget {
  const Tab3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getTabData('tab3'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tab 3 Content',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final data = documents[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ExpansionTile(
                      title: Text(data['title'] ?? 'No title'),
                      subtitle: Text(
                        data['timestamp']?.toDate().toString() ?? 'No date',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(data['content'] ?? 'No content'),
                        ),
                      ],
                    ),
                  );
                },
                childCount: documents.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2/services/firestore_service.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  context.go('/dashboard');
                },
              ),
              const SizedBox(width: 8),
              const Text(
                "User Management",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Pending Users"),
              Tab(text: "Rejected Users"),
              Tab(text: "Active Users"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PendingUsersTab(),
            RejectedUsersTab(),
            ActiveUsersTab(),
          ],
        ),
      ),
    );
  }
}

class PendingUsersTab extends StatelessWidget {
  const PendingUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pending_users")
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No pending users"));
          }

          return ListView(
            children: users.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                color: const Color(0xFFE3DFF3),
                child: ListTile(
                  title: Text("${data['firstName']} ${data['lastName']}"),
                  subtitle: Text(data['email'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await FirestoreService().approveUser(doc.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await FirestoreService().rejectUser(doc.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
    );
  }
}

class RejectedUsersTab extends StatelessWidget {
  const RejectedUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("pending_users")
          .where("status", isEqualTo: "rejected")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;
        if (users.isEmpty) return const Center(child: Text("No rejected users"));

        return ListView(
          children: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              color: Colors.grey.shade300,
              child: ListTile(
                title: Text("${data['firstName']} ${data['lastName']}"),
                subtitle: Text(data['email'] ?? ""),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("pending_users")
                        .doc(doc.id)
                        .delete();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class ActiveUsersTab extends StatelessWidget {
  const ActiveUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text("No active users"));
        }

        return ListView(
          children: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              color: const Color(0xFFFFE5E5),
              child: ListTile(
                title: Text("${data['firstName']} ${data['lastName']}"),
                subtitle: Text(data['email'] ?? ""),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(doc.id)
                        .delete();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

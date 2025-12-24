import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/profile_logic_page.dart';

void main() {
  
  group('Profile Page Widget Tests', () {

    // 1  Page loads correctly
    testWidgets('Profile page loads correctly',
            (WidgetTester tester) async {

          await tester.pumpWidget(
            const MaterialApp(
              home: MockProfilePage(
                name: 'Rasha ',
                email: 'rasha@test.com',
                phone: '0790000000',
                location: 'Amman',
                bank: 'Arab Bank',
              ),
            ),
          );

          expect(find.text('Change Profile Image'), findsOneWidget);
          expect(find.text('Save Changes'), findsOneWidget);
          expect(find.byType(TextFormField), findsNWidgets(3));
          
        });

    // 2 Save button shows success message
    testWidgets('Save changes shows success snackbar',
            (WidgetTester tester) async {

          await tester.pumpWidget(
            MaterialApp(
              home: ScaffoldMessenger(
                child: const MockProfilePage(
                  name: 'Rasha',
                  email: 'rasha@test.com',
                  phone: '0790000000',
                  location: 'Amman',
                  bank: 'Arab Bank',
                ),
              ),
            ),
          );

          final saveButton = find.text('Save Changes');

          await tester.ensureVisible(saveButton);
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          expect(find.text('Profile updated successfully'), findsOneWidget);
          
          
        });


  });
  
}








class MockProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String bank;

  const MockProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.bank,
  });

  @override
  State<MockProfilePage> createState() => _MockProfilePageState();
}

class _MockProfilePageState extends State<MockProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late MockProfileLogic logic;

  @override
  void initState() {
    super.initState();
    logic = MockProfileLogic(
      fullName: widget.name,
      email: widget.email,
      phone: widget.phone,
      location: widget.location,
      bank: widget.bank,
    );
  }

  Widget buildRow({required IconData icon, required Widget child}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F0F46), Color(0xFF8A005D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// BACK
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {},
                ),
              ),

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person,
                                size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text("Change Profile Image",
                              style: TextStyle(color: Colors.blue)),
                          const Divider(),

                          buildRow(
                            icon: Icons.person,
                            child: TextFormField(
                              key: const Key('full_name'),
                              initialValue: logic.fullName,
                              decoration: const InputDecoration(
                                  labelText: "Full Name"),
                              onSaved: (v) =>
                              logic.fullName = v ?? logic.fullName,
                            ),
                          ),

                          buildRow(
                            icon: Icons.email,
                            child: TextFormField(
                              key: const Key('email'),
                              initialValue: logic.email,
                              decoration:
                              const InputDecoration(labelText: "Email"),
                              onSaved: (v) =>
                              logic.email = v ?? logic.email,
                            ),
                          ),

                          buildRow(
                            icon: Icons.phone,
                            child: TextFormField(
                              key: const Key('phone'),
                              initialValue: logic.phone,
                              decoration: const InputDecoration(
                                  labelText: "Phone Number"),
                              onSaved: (v) =>
                              logic.phone = v ?? logic.phone,
                            ),
                          ),

                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: const Text("My Location"),
                            subtitle: Text(logic.location),
                          ),

                          ListTile(
                            leading:
                            const Icon(Icons.account_balance),
                            title: const Text("Bank Information"),
                            subtitle: Text(logic.bank),
                          ),

                          const ListTile(
                            leading:
                            Icon(Icons.verified_user),
                            title: Text("Account verification"),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () async {
                              _formKey.currentState!.save();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Profile updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text("Save Changes"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class MockProfileLogic {
  String fullName;
  String email;
  String phone;
  String location;
  String bank;

  MockProfileLogic({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.bank,
  });
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasExecuted = false;
  @override
  void initState() {
    super.initState();
    checkAndExecuteContactPermission();
  }

  Future<void> checkAndExecuteContactPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasExecutedBefore =
        prefs.getBool('hasExecutedContactPermission') ?? false;

    if (!hasExecutedBefore) {
      await saveAndRequestContactPermission();
      prefs.setBool('hasExecutedContactPermission', true);
    }
  }

  Future<void> saveAndRequestContactPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contact = Contact(
        givenName: 'OctDaily',
        phones: [Item(label: 'mobile', value: '123-456-7890')],
      );
      await ContactsService.addContact(contact);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('OctDaily phone number saved in your Contacts successfully'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blue,
      ));
    } else if (status.isDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Permission'),
      ),
      body: const Center(
        child: Text('Request to save our number in your contacts'),
      ),
    );
  }
}

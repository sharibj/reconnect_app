import 'package:flutter/material.dart';
import 'package:reconnect_app/ContactDetails.dart';

import 'contacts.dart';

class ReconnectApp extends StatelessWidget {
  const ReconnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
      ),
      home: const ReconnectHomePage(title: 'Reconnect'),
    );
  }
}

class ReconnectHomePage extends StatefulWidget {
  const ReconnectHomePage({super.key, required this.title});

  final String title;

  @override
  State<ReconnectHomePage> createState() => _ReconnectHomePageState();
}

class _ReconnectHomePageState extends State<ReconnectHomePage> {
  late Future<List<Contact>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = getContacts();
  }

  void _fetchContacts() async {
    final contacts = await getContacts();
    setState(() {
      print(contacts);
      _contacts = Future.value(contacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Contacts:'),
            FutureBuilder<List<Contact>>(
              future: _contacts,
              builder: (context, snapshot) {
                String allNames = '';
                if (snapshot.hasData) {
                  List<Contact> contacts = snapshot.data!;
                  for (var contact in contacts) {
                    allNames += '${contact.nickName}, ';
                  }
                  return Text(allNames);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchContacts,
        tooltip: 'Fetch Contacts',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

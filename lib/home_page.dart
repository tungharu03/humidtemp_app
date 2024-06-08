import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_list_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _temperature = 0.0;
  int _humidity = 0;

  @override
  void initState() {
    super.initState();
  }

  void _getData() {
    print('Getting data from Firebase...');
    _databaseReference.child('data').get().then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        print('Data received: $data');
        setState(() {
          _temperature = data['temperature'].toDouble();
          _humidity = data['humidity'].toInt();
        });

        _saveDataToFirestore(data);
      } else {
        print('No data available');
      }
    }).catchError((error) {
      print('Failed to read data: $error');
    });
  }

  void _saveDataToFirestore(Map<String, dynamic> data) {
    _firestore.collection('measurements').add({
      'temperature': data['temperature'],
      'humidity': data['humidity'],
      'timestamp': DateTime.now(), 
    }).then((value) {
      print('Data saved to Firestore');
    }).catchError((error) {
      print('Failed to save data to Firestore: $error');
    });
  }

  void _readDataFromFirestore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataListPage()),
    );
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
            Text(
              'Temperature: $_temperature °C',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Humidity: $_humidity %',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getData,
              child: const Text('Measure'),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _readDataFromFirestore,
              tooltip: 'Read data to Firestore',
            ),
          ],
        ),
      ),
    );
  }
}

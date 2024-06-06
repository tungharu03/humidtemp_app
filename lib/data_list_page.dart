import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class DataListPage extends StatefulWidget {
  @override
  _DataListPageState createState() => _DataListPageState();
}

class _DataListPageState extends State<DataListPage> {
  late Stream<QuerySnapshot> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance.collection('measurements').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                final String temperature = data['temperature'].toString();
                final String humidity = data['humidity'].toString();
                final Timestamp timestamp = data['timestamp'] as Timestamp;
                final DateTime dateTime = timestamp.toDate();
                final String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format the DateTime object
                return ListTile(
                  title: Text('Temperature: $temperature °C, Humidity: $humidity %'),
                  subtitle: Text('Timestamp: $formattedDateTime'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

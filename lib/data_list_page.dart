import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  Future<void> _editData(BuildContext context, DocumentSnapshot doc) async {
    final TextEditingController tempController = TextEditingController(text: doc['temperature'].toString());
    final TextEditingController humidityController = TextEditingController(text: doc['humidity'].toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: tempController,
                decoration: InputDecoration(labelText: 'Temperature'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: humidityController,
                decoration: InputDecoration(labelText: 'Humidity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
   
                double? temperature = double.tryParse(tempController.text);
                double? humidity = double.tryParse(humidityController.text);

                if ((temperature != null && temperature != doc['temperature']) || 
                    (humidity != null && humidity != doc['humidity'])) {
                  Map<String, dynamic> updatedData = {};
                  if (temperature != null && temperature != doc['temperature']) {
                    updatedData['temperature'] = temperature;
                  }
                  if (humidity != null && humidity != doc['humidity']) {
                    updatedData['humidity'] = humidity;
                  }

                  doc.reference.update(updatedData).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data updated')));
                  }).catchError((error) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update data: $error')));
                  });
                } else {

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid input. Please enter valid numbers.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, DocumentSnapshot doc) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteData(doc);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteData(DocumentSnapshot doc) {
    doc.reference.delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete data: $error')));
    });
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
                final String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
                return ListTile(
                  title: Text('Temperature: $temperature °C, Humidity: $humidity %'),
                  subtitle: Text('Timestamp: $formattedDateTime'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editData(context, documents[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, documents[index]),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

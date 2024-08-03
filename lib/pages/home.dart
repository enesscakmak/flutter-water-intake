import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final amountController = TextEditingController();

  void saveWater(String amount) async {
    final url = Uri.https(
        'water-intaker-3633a-default-rtdb.europe-west1.firebasedatabase.app',
        'water.json');

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': double.parse(amount),
          'unit': 'ml',
          'dateTime': DateTime.now().toString()
        }));

    if (response.statusCode == 200) {
      print("Data saved.");
    } else {
      print('Data is not saved.');
    }
  }

  void addWater() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Water'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add water to your daily intake'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Amount'),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () {
                      // save to db
                      saveWater(amountController.text);
                    },
                    child: Text('Save'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.map))],
        elevation: 4,
        centerTitle: true,
        title: const Text('Water Intake'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: addWater,
        child: const Icon(Icons.add),
      ),
    );
  }
}

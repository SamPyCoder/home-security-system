import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'addfamily.dart';

class FamiliarPersonsPage extends StatefulWidget {
  const FamiliarPersonsPage({super.key});

  @override
  State<FamiliarPersonsPage> createState() => _FamiliarPersonsPageState();
}

class _FamiliarPersonsPageState extends State<FamiliarPersonsPage> {
  List persons = [];
  bool loading = true;
  String baseUrl = "";
  String imgurl = "";

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? ""; // Django server URLd
    imgurl = sh.getString("imgurl") ?? ""; // Django server URLd
    String lid = sh.getString("lid") ?? "1"; // login id

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_familiar_person/"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            persons = jsonData['data'];
            loading = false;
          });
        } else {
          setState(() => loading = false);
        }
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Familiar Persons"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : persons.isEmpty
          ? const Center(child: Text("No familiar persons found"))
          : ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  "$imgurl${person['image']}", // full image path
                ),
              ),
              title: Text(
                person['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Relation: ${person['relation']}"),
                  Text("Gender: ${person['gender']}"),
                  Text("Added on: ${person['date']}"),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade400,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFamilyPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}

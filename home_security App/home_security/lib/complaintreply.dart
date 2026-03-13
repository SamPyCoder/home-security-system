import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'ent complaint.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  List complaints = [];
  bool loading = true;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? ""; // Django server URL
    String lid = sh.getString("lid") ?? "1"; // login id

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_complaint/"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            complaints = jsonData['data'];
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
        title: const Text("My Complaints"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
          ? const Center(child: Text("No complaints found"))
          : ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Police Station: ${complaint['POLICE']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo)),
                  const SizedBox(height: 6),
                  Text("Complaint: ${complaint['complaint']}",
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 6),
                  Text("Reply: ${complaint['reply']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: complaint['reply'].isEmpty
                            ? Colors.red
                            : Colors.green,
                      )),
                  const SizedBox(height: 6),
                  Text("Date: ${complaint['date']}",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),

      // 👇 Floating Action Button Added
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade400,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddComplaintPage()),
          ).then((_) {
            _loadComplaints(); // refresh list after adding
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}

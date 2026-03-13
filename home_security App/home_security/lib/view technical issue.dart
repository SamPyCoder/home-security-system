import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'add technical issue.dart';

class TechnicalIssuesPage extends StatefulWidget {
  const TechnicalIssuesPage({super.key});

  @override
  State<TechnicalIssuesPage> createState() => _TechnicalIssuesPageState();
}

class _TechnicalIssuesPageState extends State<TechnicalIssuesPage> {
  List issues = [];
  bool loading = true;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? ""; // saved Django URL
    String lid = sh.getString("lid") ?? "1"; // saved login id

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_techinical_issue/"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            issues = jsonData['data']; // directly assign list
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
        title: const Text("Technical Issues"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : issues.isEmpty
          ? const Center(child: Text("No issues reported"))
          : ListView.builder(
        itemCount: issues.length,
        itemBuilder: (context, index) {
          final issue = issues[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.report_problem,
                  color: Colors.redAccent, size: 30),
              title: Text(issue['issue'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("Reply: ${issue['reply']}"),
                  const SizedBox(height: 4),
                  Text("Date: ${issue['date']}"),
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
            MaterialPageRoute(builder: (context) => const AddTechnicalIssuePage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}

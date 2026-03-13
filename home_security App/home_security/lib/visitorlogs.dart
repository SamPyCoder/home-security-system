import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: VisitorLogsPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class VisitorLogsPage extends StatefulWidget {
  const VisitorLogsPage({super.key});

  @override
  State<VisitorLogsPage> createState() => _VisitorLogsPageState();
}

class _VisitorLogsPageState extends State<VisitorLogsPage> {
  List logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }
String imgurl="";
  Future<void> _loadLogs() async {
    final sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString("url") ?? ""; // saved URL
    String lid = sh.getString("lid") ?? "1";    // saved login id
    imgurl = sh.getString("imgurl") ?? "";
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_visitor_log"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            logs = jsonData['data']; // directly store list
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
      appBar: AppBar(
        title: const Text("Visitor Logs"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
          ? const Center(child: Text("No visitor logs available"))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index]; // like for loop item
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  "$imgurl${log['image']}",
                ),
              ),
              title: Text("${log['type']} - ${log['FAMILIAR_PERSON']}"),
              subtitle: Text("${log['date']} at ${log['time']}"),
            ),
          );
        },
      ),
    );
  }
}

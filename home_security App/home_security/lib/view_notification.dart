import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'addfamily.dart';

class View_Notification_User extends StatefulWidget {
  const View_Notification_User({super.key});

  @override
  State<View_Notification_User> createState() => _View_Notification_UserState();
}

class _View_Notification_UserState extends State<View_Notification_User> {
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
        Uri.parse(baseUrl+"view_notification_user"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'ok') {
          print(jsonData);
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
  void _forwardNotification(person) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Forward Notification"),
          content: const Text("Do you want to forward this notification?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Example forward API call
                final response = await http.post(
                  Uri.parse(baseUrl + "forward_notification"),
                  body: {
                    "nid": person['id'].toString(),
                  },
                );

                if (response.statusCode == 200) {
                  final jsonData = json.decode(response.body);
                  if (jsonData['status'] == "ok") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notification Forwarded!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to forward!")),
                    );
                  }
                }
              },
              child: const Text("Forward"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Unknown Persons"),
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
          // return
          //   Card(
          //   margin: const EdgeInsets.all(10),
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   elevation: 3,
          //   child: ListTile(
          //     leading: CircleAvatar(
          //       radius: 28,
          //       backgroundImage: NetworkImage(
          //         "$imgurl${person['image']}", // full image path
          //       ),
          //     ),
          //     title: Text(
          //       person['date'],
          //       style: const TextStyle(
          //           fontWeight: FontWeight.w600, fontSize: 16),
          //     ),
          //     subtitle: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //
          //         Text("Status: ${person['status']}"),
          //
          //       ],
          //     ),
          //   ),
          // );
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
                  "$imgurl${person['image']}",
                ),
              ),
              title: Text(
                person['date'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status: ${person['status']}"),
                ],
              ),

              // ------------------------- NEW FORWARD BUTTON -------------------------


              trailing:person['status'] == "pending"||person['status'] == "viwed"? IconButton(
                icon: const Icon(Icons.forward, color: Colors.indigo),
                onPressed: () {
                  _forwardNotification(person);
                },
              ):Column(children: [
                Text(person['ac'] ),
                Text(person['res'] ),
              ],),
            ),
          );

        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.indigo.shade400,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const AddFamilyPage()),
      //     );
      //   },
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),

    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_security/view_notification.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:home_security/view%20camera.dart';
import 'package:home_security/view%20technical%20issue.dart';
import 'package:home_security/viewfamily.dart';
import 'package:home_security/visitorlogs.dart';
import 'package:home_security/profilr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'complaintreply.dart';

void main() {
  runApp(const MaterialApp(
    home: UserHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

/// Stateless wrapper
class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: _UserHomeBody(),
      ),
    );
  }
}

/// Stateful body
class _UserHomeBody extends StatefulWidget {
  const _UserHomeBody({super.key});

  @override
  State<_UserHomeBody> createState() => _UserHomeBodyState();
}

class _UserHomeBodyState extends State<_UserHomeBody> {
_UserHomeBodyState()
{
  print("ok");
  backgroundTask("");
}
  void backgroundTask( String s) {
    Timer.periodic(Duration(seconds: 20), (timer) {
      location_fn();
      // Perform your periodic task here
      //print('Background task executed at ${DateTime.now()}');
    });
  }
  // Show a test notification
  Future<void> showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification',
      'Unknown Person Detected',
      platformDetails,
    );
  }

  Future<void>  location_fn() async {

    final sh = await SharedPreferences.getInstance();

    String url = sh.getString("url") ?? "";
    String lid = sh.getString("lid") ?? "";



    try {
      var response = await http.post(
        Uri.parse(url + "view_notification_alert"),
        body: {
          'lid': lid,

        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();

        if (status == "ok") {

          final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
          await showNotification(flutterLocalNotificationsPlugin);

        } else {
          print("❌ Invalid username or password");
        }
      } else {
        print(
            "❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception during login: $e");
    }



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("User Home"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildMenuCard(
              context,
              "View & Update Profile",
              Icons.person,
                  (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),));

                  }
            ),
            _buildMenuCard(
              context,
              "Manage Family Person",
              Icons.group,
                  () {

                    Navigator.push(context, MaterialPageRoute(builder: (context) => FamiliarPersonsPage(),));

                    // TODO: Navigate to Manage Family Page
              },
            ),
            _buildMenuCard(
              context,
              "View Visitor Logs",
              Icons.history,
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VisitorLogsPage(),));
               // TODO: Navigate to Visitor Logs Page
              },
            ),
            _buildMenuCard(
              context,
              "Get Unknown Person Alert",
              Icons.notification_important,
                  () { Navigator.push(context, MaterialPageRoute(builder: (context) => View_Notification_User(),));

                    // TODO: Navigate to Alerts Page
              },
            ),
            _buildMenuCard(
              context,
              "Complaint",

              Icons.report_problem,
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintsPage(),));

                    // TODO: Navigate to Complaint Page
              },
            ),
            _buildMenuCard(
              context,
              "Technical Issue",
              Icons.build,
                  () {

                    Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicalIssuesPage(),));

                    // TODO: Navigate to Technical Issue Page
              },
            ),
            _buildMenuCard(
              context,
              "Camera",
              Icons.videocam,


                  () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(),));
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Back to login
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: Colors.indigo.shade200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Icon(icon, color: Colors.indigo.shade600),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.indigo.shade400),
        onTap: onTap,
      ),
    );
  }
}

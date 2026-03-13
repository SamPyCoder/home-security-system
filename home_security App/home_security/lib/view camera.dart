import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'add_camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List cameras = [];
  bool loading = true;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? ""; // Django server URL
    String lid = sh.getString("lid") ?? "1"; // login id

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_camera/"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            cameras = jsonData['data'];
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

  /// Call Django activate_camera API
  Future<void> _activateCamera(String camId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/activate_camera/"), // Django endpoint
        body: {"camid": camId},                 // send camid
      );

      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera activated successfully")),
        );
        _loadCameras(); // reload list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to activate camera")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// Call Django deactivate_camera API
  Future<void> _deactivateCamera(String camId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/deactivate_camera/"), // Django endpoint
        body: {"camid": camId},                   // send camid
      );

      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera deactivated successfully")),
        );
        _loadCameras();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to deactivate camera")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Camera Details"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cameras.isEmpty
          ? const Center(child: Text("No cameras found"))
          : ListView.builder(
        itemCount: cameras.length,
        itemBuilder: (context, index) {
          final cam = cameras[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.videocam,
                  color: Colors.indigo, size: 32),
              title: Text(
                "Camera ${cam['camera_number']}",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${cam['date']}"),
                  Text("Status: ${cam['status']}"),
                ],
              ),
              trailing: Icon(
                cam['status'] == "Active"
                    ? Icons.check_circle
                    : Icons.cancel,
                color: cam['status'] == "Active"
                    ? Colors.green
                    : Colors.red,
              ),

              // 👇 Popup to Activate / Deactivate
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Camera Options"),
                    content: Text(
                        "Do you want to change the status of Camera ${cam['camera_number']}?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _activateCamera(cam['id'].toString());
                        },
                        child: const Text("Activate"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deactivateCamera(cam['id'].toString());
                        },
                        child: const Text("Deactivate"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade400,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const add_camera()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

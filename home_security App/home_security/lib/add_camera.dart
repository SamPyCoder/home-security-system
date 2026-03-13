import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_security/view%20camera.dart';
import 'package:home_security/view%20technical%20issue.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: add_camera(),
    debugShowCheckedModeBanner: false,
  ));
}

class add_camera extends StatefulWidget {
  const add_camera({super.key});

  @override
  State<add_camera> createState() => _add_cameraState();
}

class _add_cameraState extends State<add_camera> {
  final _cameraController = TextEditingController();
  String? baseUrl;
  bool loading = false;

  Future<void> _submitIssue() async {
    if (_cameraController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Camera number")),
      );
      return;
    }

    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? "";
    final lid = sh.getString("lid") ?? "";

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_add_camera/"),
        body: {
          "lid": lid,
          "camera": _cameraController.text,
        },
      );

      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera submitted successfully")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit issue")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Add Camera"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _cameraController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter your camera number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : _submitIssue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

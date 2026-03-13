import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddComplaintPage extends StatefulWidget {
  const AddComplaintPage({super.key});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  String? baseUrl;
  List policeStations = [];
  String? selectedPoliceId;
  final _complaintController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? "";

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_policestation/"),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            policeStations = jsonData['data'];
            loading = false;
          });
        }
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _submitComplaint() async {
    if (selectedPoliceId == null || _complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a station and enter complaint")),
      );
      return;
    }

    final sh = await SharedPreferences.getInstance();
    final lid = sh.getString("lid") ?? "";

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_add_complaint/"),
        body: {
          "lid": lid,
          "policeid": selectedPoliceId!,
          "complaint": _complaintController.text,
        },
      );

      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint sent successfully")),
        );
        Navigator.pop(context); // go back to complaints page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send complaint")),
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
        title: const Text("Add Complaint"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Police Station",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value: selectedPoliceId,
              items: policeStations.map<DropdownMenuItem<String>>((station) {
                return DropdownMenuItem<String>(
                  value: station['id'].toString(),
                  child: Text(station['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPoliceId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _complaintController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter Complaint",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Submit Complaint"),
            ),
          ],
        ),
      ),
    );
  }
}

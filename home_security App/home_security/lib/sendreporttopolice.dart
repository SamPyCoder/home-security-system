import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: SendReportPage(),
    debugShowCheckedModeBanner: false,
  ));
}

/// Stateless wrapper
class SendReportPage extends StatelessWidget {
  const SendReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: _SendReportForm()),
    );
  }
}

/// Stateful form
class _SendReportForm extends StatefulWidget {
  const _SendReportForm({super.key});

  @override
  State<_SendReportForm> createState() => _SendReportFormState();
}

class _SendReportFormState extends State<_SendReportForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  String? selectedStation;

  final List<String> stations = [
    "Station A",
    "Station B",
    "Station C",
  ];

  void _sendReport() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Report sent to $selectedStation: ${_descController.text}"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      setState(() {
        selectedStation = null;
        _descController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Send Report to Police"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Police Station Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Police Station",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedStation,
                items: stations.map((station) {
                  return DropdownMenuItem(
                    value: station,
                    child: Text(station),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStation = value;
                  });
                },
                validator: (value) =>
                value == null ? "Please select a police station" : null,
              ),
              const SizedBox(height: 16),

              // Description Box
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Description is required";
                  }
                  if (value.trim().length < 10) {
                    return "Description must be at least 10 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Send Button
              Center(
                child: ElevatedButton(
                  onPressed: _sendReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Send",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
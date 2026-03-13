import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: ResponseActionPage(),
    debugShowCheckedModeBanner: false,
  ));
}

/// Stateless wrapper
class ResponseActionPage extends StatelessWidget {
  const ResponseActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: _ResponseActionForm()),
    );
  }
}

/// Stateful form
class _ResponseActionForm extends StatefulWidget {
  const _ResponseActionForm({super.key});

  @override
  State<_ResponseActionForm> createState() => _ResponseActionFormState();
}

class _ResponseActionFormState extends State<_ResponseActionForm> {
  final _formKey = GlobalKey<FormState>();

  final _stationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responseController = TextEditingController();
  final _actionController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Response & Action submitted"),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator ??
                (value) {
              if (value == null || value.trim().isEmpty) {
                return "$label is required";
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo[50], // light indigo background
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "View Response & Action",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            _buildTextField(_stationController, "Station",
                Icons.account_balance, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Station is required";
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return "Station must contain only letters";
                  }
                  return null;
                }),
            _buildTextField(
              _descriptionController,
              "Description",
              Icons.description,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Description is required";
                }
                return null;
              },
            ),
            _buildTextField(
                _responseController, "Response", Icons.message_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Response is required";
                  }
                  return null;
                }),
            _buildTextField(_actionController, "Action", Icons.check_circle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Action is required";
                  }
                  return null;
                }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Submit", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
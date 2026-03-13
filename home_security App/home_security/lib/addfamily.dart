import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_security/viewfamily.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final _nameController = TextEditingController();
  String? _selectedRelation;
  String? _selectedGender;
  File? _selectedImage;
  bool loading = false;
  String? baseUrl;

  final List<String> relations = ["Father", "Mother", "Brother", "Sister", "Other"];
  final List<String> genders = ["Male", "Female", "Other"];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submitFamily() async {
    if (_nameController.text.isEmpty ||
        _selectedRelation == null ||
        _selectedGender == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and pick an image")),
      );
      return;
    }

    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? "";
    final lid = sh.getString("lid") ?? "";

    setState(() => loading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/user_add_family/"),
      );

      request.fields["lid"] = lid;
      request.fields["name"] = _nameController.text;
      request.fields["relation"] = _selectedRelation!;
      request.fields["gender"] = _selectedGender!;
      request.files.add(
        await http.MultipartFile.fromPath("image", _selectedImage!.path),
      );

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      final jsonData = json.decode(responseData.body);

      if (jsonData['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Family member added successfully")),
        );
        Navigator.push(context,MaterialPageRoute(builder: (context) => FamiliarPersonsPage(),));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add family member")),
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
        title: const Text("Add Family Member"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedRelation,
                items: relations.map((rel) {
                  return DropdownMenuItem(value: rel, child: Text(rel));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRelation = val),
                decoration: const InputDecoration(
                  labelText: "Relation",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: genders.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.add_a_photo, size: 50),
                )
                    : Image.file(_selectedImage!, height: 150),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: loading ? null : _submitFamily,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade400,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Family Member"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

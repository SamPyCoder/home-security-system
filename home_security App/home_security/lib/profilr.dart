import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(
    home: ProfilePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: _ProfilePageBody(),
      ),
    );
  }
}

class _ProfilePageBody extends StatefulWidget {
  const _ProfilePageBody({super.key});

  @override
  State<_ProfilePageBody> createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<_ProfilePageBody> {
  _ProfilePageBodyState() {
    _loadProfile();
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final RegExp nameRegExp = RegExp(r'^[A-Za-z ]{2,25}$');
  final RegExp emailRegExp =
  RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,25}$');
  final RegExp phoneRegExp = RegExp(r'^[6789]\d{9}$');
  final RegExp placeRegExp = RegExp(r'^[A-Za-z ]{2,25}$');
  final RegExp postRegExp = RegExp(r'^[A-Za-z ]{2,25}$');
  final RegExp pinRegExp = RegExp(r'^[0-9]{6}$');

  String baseUrl = "";
  String imgurl = "";
  bool loading = true;

  /// Store image text
  String profileImageText = "";
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadProfile() async {
    final sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? ""; // Django server URL
    imgurl = sh.getString("imgurl") ?? ""; // Django server URL
    String lid = sh.getString("lid") ?? "1"; // login id

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user_view_profile/"),
        body: {"lid": lid},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          setState(() {
            _nameController.text = jsonData['name'];
            _emailController.text = jsonData['email'];
            _postController.text = jsonData['post'];
            _pinController.text = jsonData['pin'];
            _placeController.text = jsonData['place'];
            _phoneController.text = jsonData['phone'];

            /// Build full image URL
            if (jsonData['image'] != null &&
                jsonData['image'].toString().isNotEmpty) {
              profileImageText = imgurl + jsonData['image'].toString();
              print(profileImageText);
              print('profileImageText==========');
            }
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
        title: const Text("View & Update Profile"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (profileImageText.isNotEmpty
                        ? NetworkImage(profileImageText)
                        : null) as ImageProvider<Object>?,
                    child: _pickedImage == null &&
                        profileImageText.isEmpty
                        ? const Icon(Icons.person,
                        size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.indigo.shade400,
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                        onPressed: _pickImage, // ✅ choose file
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Show image as plain text
              if (profileImageText.isNotEmpty)
                // Text(
                //   "Image: $profileImageText",
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.indigo.shade700,
                //   ),
                // ),

              const SizedBox(height: 20),

              _buildTextField("Name", _nameController, Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Name";
                    }
                    if (!nameRegExp.hasMatch(value.trim())) {
                      return "Name must be 2-25 letters only";
                    }
                    return null;
                  }),
              _buildTextField("Email", _emailController, Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Email";
                    }
                    if (!emailRegExp.hasMatch(value.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  }),
              _buildTextField("Phone", _phoneController, Icons.phone,
                  keyboardType: TextInputType.phone, validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Phone";
                    }
                    if (!phoneRegExp.hasMatch(value.trim())) {
                      return "Enter a valid 10-digit phone starting with 6-9";
                    }
                    return null;
                  }),
              _buildTextField("Place", _placeController,
                  Icons.location_city, validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Place";
                    }
                    if (!placeRegExp.hasMatch(value.trim())) {
                      return "Place must be 2-25 letters only";
                    }
                    return null;
                  }),
              _buildTextField("Post", _postController,
                  Icons.markunread_mailbox, validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Post";
                    }
                    if (!postRegExp.hasMatch(value.trim())) {
                      return "Post must be 2-25 letters only";
                    }
                    return null;
                  }),
              _buildTextField("Pin", _pinController, Icons.pin,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter Pin";
                    }
                    if (!pinRegExp.hasMatch(value.trim())) {
                      return "Pin must be 6 digits";
                    }
                    return null;
                  }),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Updated")),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Update Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade400,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon,
      {TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigo.shade400),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}

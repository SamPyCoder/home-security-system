import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_security/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController placeController = TextEditingController(); // NEW
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  XFile? _image;

  // Regex for validation
  final RegExp nameRegExp = RegExp(r'^[A-Za-z ]{2,25}$');
  final RegExp placeRegExp = RegExp(r'^[A-Za-z ]{2,25}$'); // letters only
  final RegExp pinRegExp = RegExp(r'^[0-9]{6}$');
  final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,25}$');
  final RegExp phoneRegExp = RegExp(r'^[6789]\d{9}$');
  final RegExp usernameRegExp = RegExp(r'^[A-Za-z]{3,25}$');
  final RegExp passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$');

  // Image picker
  _imgFromCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) setState(() => _image = image);
  }

  _imgFromGallery() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _image = image);
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _imgFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("User Registration"),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: Colors.indigo.shade200,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => _showPicker(context),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[200],
                        child: _image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(File(_image!.path),
                              width: 100, height: 100, fit: BoxFit.cover),
                        )
                            : Icon(Icons.camera_alt, color: Colors.grey[800], size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Personal Information"),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: nameController,
                    label: "Full Name",
                    icon: Icons.person,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter your name";
                      if (!nameRegExp.hasMatch(val)) return "Name must be 2-25 letters only";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter your email";
                      if (!emailRegExp.hasMatch(val)) return "Enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter your phone number";
                      if (!phoneRegExp.hasMatch(val)) return "Enter a valid 10-digit phone starting with 6-9";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: postController,
                    label: "Post",
                    icon: Icons.location_city,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter post";
                      if (!RegExp(r'^[A-Za-z ]{2,25}$').hasMatch(val)) return "Post must be 2-25 letters only";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: placeController, // NEW FIELD
                    label: "Place",
                    icon: Icons.place,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter place";
                      if (!placeRegExp.hasMatch(val)) return "Place must be 2-25 letters only";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: pinController,
                    label: "Pin Code",
                    icon: Icons.pin_drop,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter pin";
                      if (!pinRegExp.hasMatch(val)) return "Pin must be 6 digits";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Login Information"),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: usernameController,
                    label: "Username",
                    icon: Icons.person_outline,
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter username";
                      if (!usernameRegExp.hasMatch(val)) return "Username must be 3-25 letters only";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      String val = value!.trim();
                      if (val.isEmpty) return "Please enter password";
                      if (!passwordRegExp.hasMatch(val))
                        return "Password must be 8+ chars with upper, lower & number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_image == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please select a profile image")),
                            );
                            return;
                          }

                          final sh = await SharedPreferences.getInstance();
                          String url = sh.getString("url") ?? "";
                          if (url.isEmpty) return;

                          try {
                            var uri = Uri.parse(url + 'user_register');
                            var request = http.MultipartRequest('POST', uri);
                            request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
                            request.fields['name'] = nameController.text.trim();
                            request.fields['email'] = emailController.text.trim();
                            request.fields['post'] = postController.text.trim();
                            request.fields['place'] = placeController.text.trim(); // SEND PLACE
                            request.fields['pin'] = pinController.text.trim();
                            request.fields['phone'] = phoneController.text.trim();
                            request.fields['username'] = usernameController.text.trim();
                            request.fields['password'] = passwordController.text.trim();

                            var response = await request.send();
                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Successfully Registered'), duration: Duration(seconds: 4)),
                              );
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) => Login_page()));
                            }
                          } catch (e) {
                            print("Registration error: $e");
                          }
                        }
                      },
                      child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo.shade400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.indigo.shade700,
      ),
    );
  }
}

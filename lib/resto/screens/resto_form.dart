import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halal_bites/resto/screens/list_resto.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestoFormPage extends StatefulWidget {
  const RestoFormPage({super.key});

  @override
  State<RestoFormPage> createState() => _RestoFormPageState();
}

class _RestoFormPageState extends State<RestoFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _foodName = "";
  int _foodPrice = 0;
  String _foodPromo = "";
  String _foodImage = "";
  String _location = "";

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        cursorColor: const Color.fromARGB(255, 3, 90, 6),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 3, 90, 6),
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 3, 90, 6),
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          prefixIcon: Icon(
            _getIconForField(label),
            color: Colors.black87,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  IconData _getIconForField(String label) {
    switch (label) {
      case 'Restaurant Name':
        return Icons.restaurant;
      case 'Food Name':
        return Icons.fastfood;
      case 'Food Price':
        return Icons.attach_money;
      case 'Food Promo':
        return Icons.local_offer;
      case 'Food Image (URL)':
        return Icons.image;
      case 'Location':
        return Icons.location_on;
      default:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow.shade700, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: AppBar(
            title: const Text('Add New Restaurant'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade50, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Restaurant Name',
                  hint: 'Enter restaurant name',
                  onChanged: (value) => setState(() => _name = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Restaurant name is required!" : null,
                ),
                _buildTextField(
                  label: 'Food Name',
                  hint: 'Enter food name',
                  onChanged: (value) => setState(() => _foodName = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Food name is required!" : null,
                ),
                _buildTextField(
                  label: 'Food Price',
                  hint: 'Enter food price',
                  onChanged: (value) => setState(() => _foodPrice = int.tryParse(value!) ?? 0),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Price is required!";
                    if (int.tryParse(value) == null) return "Price must be a number!";
                    if (int.tryParse(value)! < 1) return "Price must be greater than 0!";
                    return null;
                  },
                  isNumber: true,
                ),
                _buildTextField(
                  label: 'Food Promo',
                  hint: 'Enter food promotion',
                  onChanged: (value) => setState(() => _foodPromo = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Promotion details are required!" : null,
                ),
                _buildTextField(
                  label: 'Food Image (URL)',
                  hint: 'Enter food image URL',
                  onChanged: (value) => setState(() => _foodImage = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Image URL is required!" : null,
                ),
                _buildTextField(
                  label: 'Location',
                  hint: 'Enter restaurant location',
                  onChanged: (value) => setState(() => _location = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Location is required!" : null,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.yellow.shade700, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await request.postJson(
                            "http://127.0.0.1:8000/resto/create-flutter/",
                            jsonEncode(<String, String>{
                              'name': _name,
                              'name_makanan': _foodName,
                              'price': _foodPrice.toString(),
                              'image': _foodImage,
                              'promo': _foodPromo,
                              'lokasi': _location,
                            }),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Restaurant successfully added!"),
                                  backgroundColor: Color.fromARGB(255, 3, 90, 6),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => RestoPage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("An error occurred. Please try again."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Save Restaurant",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halal_bites/food/screen/food_admin.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  String _foodName = "";
  String _foodPrice = "";
  String _foodImage = "";
  String _promo = "";

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
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
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
            title: const Text('Add Food'),
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
                  label: 'Food Name',
                  hint: 'Enter food name',
                  onChanged: (value) => setState(() => _foodName = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Food name is required!" : null,
                ),
                _buildTextField(
                  label: 'Food Price',
                  hint: 'Enter food price',
                  onChanged: (value) => setState(() => _foodPrice = value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Price is required!";
                    if (int.tryParse(value) == null) return "Price must be a number!";
                    return null;
                  },
                  isNumber: true,
                ),
                _buildTextField(
                  label: 'Food Image (URL)',
                  hint: 'Enter food image URL',
                  onChanged: (value) => setState(() => _foodImage = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Image URL is required!" : null,
                ),
                _buildTextField(
                  label: 'Food Promo',
                  hint: 'Enter food promotion',
                  onChanged: (value) => setState(() => _promo = value!),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Promotion details are required!" : null,
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
                            "http://127.0.0.1:8000/menu/create-flutter/",
                            jsonEncode(<String, String>{
                              'name_makanan': _foodName,
                              'price': _foodPrice,
                              'image': _foodImage,
                              'promo': _promo,
                            }),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Food successfully added!"),
                                  backgroundColor: Color.fromARGB(255, 200, 247, 202),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => FoodAdminPage()),
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
                        "Add Food",
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
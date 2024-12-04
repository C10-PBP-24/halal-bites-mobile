import 'package:flutter/material.dart';
import '../widgets/food_dropdown.dart'; // Import dropdown makanan

class AddFoodPage extends StatefulWidget {
  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  String? _selectedFood;
  double _rating = 0;

  final List<String> _foodOptions = [
    'Pizza',
    'Burger',
    'Sushi',
    'Pasta',
    'Salad'
  ]; // Daftar makanan

  void _saveFood() {
    if (_selectedFood != null && _rating > 0) {
      final foodData = {
        'name': _selectedFood,
        'rating': _rating,
      };
      Navigator.pop(context, foodData); // Mengirim data kembali ke halaman utama
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a food and give a rating!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoodDropdown(
              foodOptions: _foodOptions,
              onFoodSelected: (food) {
                setState(() {
                  _selectedFood = food;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Rating:'),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveFood,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

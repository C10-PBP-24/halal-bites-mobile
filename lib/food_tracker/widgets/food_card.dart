import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final Map<String, dynamic> food;

  const FoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(food['name']),
        subtitle: Text('Rating: ${food['rating']}'),
        leading: Icon(Icons.fastfood),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class FoodDropdown extends StatelessWidget {
  final List<String> foodOptions;
  final Function(String?) onFoodSelected;

  const FoodDropdown({
    required this.foodOptions,
    required this.onFoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Food',
        border: OutlineInputBorder(),
      ),
      items: foodOptions.map((food) {
        return DropdownMenuItem(
          value: food,
          child: Text(food),
        );
      }).toList(),
      onChanged: onFoodSelected,
    );
  }
}

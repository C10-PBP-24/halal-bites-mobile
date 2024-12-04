import 'package:flutter/material.dart';
import 'add_food_page.dart'; // Import halaman tambah makanan
import '../widgets/food_card.dart'; // Import widget card makanan

class FoodTrackerPage extends StatefulWidget {
  @override
  _FoodTrackerPageState createState() => _FoodTrackerPageState();
}

class _FoodTrackerPageState extends State<FoodTrackerPage> {
  final List<Map<String, dynamic>> _trackedFoods = []; // List untuk makanan yang sudah ditambahkan

  void _addFood(Map<String, dynamic> foodData) {
    setState(() {
      _trackedFoods.add(foodData); // Menambahkan makanan ke dalam daftar
    });
  }
  //abc//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _trackedFoods.isEmpty
                ? Center(
                    child: Text('No food tracked yet!'),
                  )
                : ListView.builder(
                    itemCount: _trackedFoods.length,
                    itemBuilder: (context, index) {
                      final food = _trackedFoods[index];
                      return FoodCard(food: food); // Menggunakan widget card
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman AddFoodPage dan menerima data yang dikirim
          final newFood = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFoodPage()),
          );

          if (newFood != null) {
            _addFood(newFood);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:halal_bites/food_tracker/screens/food_tracker.dart';
import 'package:halal_bites/rating/screens/rated_foods.dart';
import 'package:halal_bites/resto/screens/list_resto.dart';

// Halaman Menu dengan navigasi
class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Resto Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestoPage()),
              );
            },
          ),
          ListTile(
            title: Text('Food Tracker Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoodTrackerPage()),
              );
            },
          ),
          ListTile(
            title: Text('Food Review Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoodReviewPage()),
              );
            },
          ),
          // ListTile(
          //   title: Text('Food Page'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => FoodPage()),
          //     );
          //   },
          // ),
          // ListTile(
          //   title: Text('Forum Page'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => ForumPage()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
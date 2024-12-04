import 'package:flutter/material.dart';
import 'package:halal_bites/food_tracker/screens/food_tracker.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan di setiap tab
  final List<Widget> _pages = [
    Center(child: Text('Home Page Placeholder')), // Placeholder untuk Home
    FoodTrackerPage(), // Halaman Food Tracker
    Center(child: Text('Profile Page Placeholder')), // Placeholder untuk Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navbar Example'),
      ),
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai tab yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Food Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

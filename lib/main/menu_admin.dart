import 'package:flutter/material.dart';
import 'package:halal_bites/food_tracker/screens/food_tracker.dart';
import 'package:halal_bites/forum/screens/thread_list.dart';
import 'package:halal_bites/rating/screens/rated_foods.dart';
import 'package:halal_bites/resto/screens/list_resto_admin.dart';
import 'package:halal_bites/food/screen/food_admin.dart';
import 'package:halal_bites/auth/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MenuAdminPage extends StatelessWidget {
  final String username;

  MenuAdminPage({required this.username});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      body: Container(
        color: Colors.amber,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halal Bites Admin",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Welcome Admin $username,\nManage Halal Bites Effectively",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAnimatedButton(
                    context,
                    "Resto",
                    Icons.restaurant,
                    Colors.brown,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RestoPageAdmin()),
                    ),
                  ),
                  _buildAnimatedButton(
                    context,
                    "Food",
                    Icons.fastfood,
                    Colors.brown,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodAdminPage()),
                    ),
                  ),
                  _buildAnimatedButton(
                    context,
                    "Tracker",
                    Icons.track_changes,
                    Colors.brown,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodTrackerPage()),
                    ),
                  ),
                  _buildAnimatedButton(
                    context,
                    "Review",
                    Icons.rate_review,
                    Colors.brown,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodReviewPage()),
                    ),
                  ),
                  _buildAnimatedButton(
                    context,
                    "Forum",
                    Icons.forum,
                    Colors.brown,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ThreadPage()),
                    ),
                  ),
                  _buildAnimatedButton(
                    context,
                    "Logout",
                    Icons.logout,
                    Colors.red,
                    () async{
                      final response = await request.logout(
                        "http://127.0.0.1:8000/auth/logout-flutter/",
                      );
                      String message = response["message"];
                      if (context.mounted) {
                        if (response['status']) {
                          String uname = response["username"];
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("$message Sampai jumpa, $uname."),
                          ));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

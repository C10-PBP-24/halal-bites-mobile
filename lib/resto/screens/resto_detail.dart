  import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halal_bites/food/screen/detail_food.dart';
import 'package:halal_bites/resto/models/resto.dart';
import 'package:halal_bites/food/models/food.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestoDetailPage extends StatelessWidget {
  final Resto resto;

  const RestoDetailPage({super.key, required this.resto});

  Future<Food> fetchFood(CookieRequest request, int foodId) async {
    final response = await request.get('http://127.0.0.1:8000/menu/get_food/$foodId/');
    if (response != null) {
      // Convert JSON response to a String where necessary
      final List<dynamic> rawList = json.decode(json.encode(response));
      final processedList = rawList.map((item) {
        item['fields']['price'] = item['fields']['price'].toString(); // Convert price to String
        return item;
      }).toList();

      return Food.fromJson(processedList[0]);
    } else {
      throw Exception('Failed to load food');
    }
  }


  Widget _buildFoodSection(BuildContext context, CookieRequest request) {
    return FutureBuilder<Food?>(
      future: fetchFood(request, resto.fields.makanan),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          print(snapshot.data);
          return _buildInfoSection(
            title: 'Food Details',
            content: 'Failed to load food details',
            icon: Icons.fastfood,
          );
        } else {
          final food = snapshot.data!;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailPage(food: food),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.shade100, Colors.yellow.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.network(
                    food.fields.image,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover, // Ensures the image covers the 50x50 box
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.fastfood, // You can replace this with any other relevant icon
                        size: 50, // Size should match the image size
                        color: Colors.grey, // Set color if needed
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.fields.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${food.fields.price}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    IconData? icon,
    bool isMainTitle = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade100, Colors.yellow.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMainTitle ? 24.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (!isMainTitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
            title: Text(resto.fields.nama),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Restaurant Name Section
              _buildInfoSection(
                title: resto.fields.nama,
                content: '',
                icon: Icons.restaurant,
                isMainTitle: true,
              ),

              // Location Section
              _buildInfoSection(
                title: 'Location',
                content: lokasiValues.reverse[resto.fields.lokasi] ?? 'Unknown',
                icon: Icons.location_on,
              ),

              // Food Section
              _buildFoodSection(context, request),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
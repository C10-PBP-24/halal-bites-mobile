import 'package:flutter/material.dart';
import 'package:halal_bites/food/models/food.dart';

class FoodDetailPage extends StatelessWidget {
  final Food food;

  const FoodDetailPage({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${food.fields.name}"),
        backgroundColor: const Color(0xffffc107),
      ),
      body: Column(
        
        children: [
          // Container dengan dekorasi
          Container(
            width: double.infinity,
            height: 50,
          ),
          // Gambar
          Image.network(
            "${food.fields.image}",
            errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                  // Text('Gambar tidak ditemukan');
                                },
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          // Nama makanan
          Text(
            "${food.fields.name}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          // Harga makanan
          Text(
            "Rp ${food.fields.price}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          // Deskripsi makanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "${food.fields.promo}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

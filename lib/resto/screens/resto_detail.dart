import 'package:flutter/material.dart';
import 'package:halal_bites/resto/models/resto.dart';

class RestoDetailPage extends StatelessWidget {
  final Resto resto;

  const RestoDetailPage({super.key, required this.resto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resto.fields.nama),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name
            Text(
              resto.fields.nama,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Restaurant Location
            Text(
              "Lokasi: ${lokasiValues.reverse[resto.fields.lokasi] ?? 'Tidak diketahui'}",
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),

            // Food ID (for now, interpreted as a number)
            Text(
              "Makanan (ID): ${resto.fields.makanan}",
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),

            // Model Information (optional, for debugging or completeness)
            Text(
              "Model: ${modelValues.reverse[resto.model]}",
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

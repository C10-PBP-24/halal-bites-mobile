import 'package:flutter/material.dart';
import 'package:halal_bites/food/models/foods.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Future<List<Food>> fetchFoods(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/menu/get_food');
    var data = response;
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
      }
    }
    return listFood;
  }
  double budgetFilter = 0;
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: Column(
        children: [
          // Bagian atas dengan latar belakang kuning
          Container(
            width: double.infinity,
            height: 183,
            color: Colors.amber,
            alignment: Alignment.center,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filter by budget',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  budgetFilter = double.tryParse(value) ?? double.infinity;
                });
              },
            ),
          ),
          // Bagian daftar makanan
          Expanded(
            child: FutureBuilder(
              future: fetchFoods(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data.'));
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(child: Text('No items found.'));
                } else {
                  List<Food> filteredList = snapshot.data;
                  if (budgetFilter != 0) {
                    filteredList = snapshot.data.where((element) => element.fields.price <= budgetFilter).toList();
                  }
                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final food = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Gambar makanan
                            food.fields.image != null
                                ? Image.network(
                                    'http://127.0.0.1:8000/static/${food.fields.image}',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.fastfood, size: 70),
                            const SizedBox(width: 16.0),
                            // Informasi makanan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.fields.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${food.fields.price}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

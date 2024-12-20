import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halal_bites/food/models/food.dart';
import 'package:halal_bites/food/screen/detail_food.dart';
import 'package:halal_bites/food/screen/food_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;

class FoodUserPage extends StatefulWidget {
  const FoodUserPage({super.key});

  @override
  State<FoodUserPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodUserPage> {
  Future<List<Food>> fetchFoods(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/menu/get_food/');
    // print('Response: $response');
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
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text(
          "Food",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bagian atas dengan latar belakang kuning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            height: 100,
            color: Colors.yellow[700], // Latar belakang kuning
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filter by budget',
                      icon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        budgetFilter =
                            double.tryParse(value) ?? double.infinity;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bagian daftar makanan
          Expanded(
            child: FutureBuilder(
              future: fetchFoods(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        'No data available.',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  } else {
                    List<Food> filteredList = snapshot.data!.where((food) {
                      final double price =
                          double.parse(food.fields.price.toString());
                      final priceMatches =
                          budgetFilter == 0 || price <= budgetFilter;
                      return priceMatches;
                    }).toList();
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (_, index) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodDetailPage(food: filteredList[index]),
                              ),
                            );
                          },
                          child: Container(
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
                                Image.network(
                                  "${filteredList[index].fields.image}",
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                        Icons.image_not_supported);
                                    // Text('Gambar tidak ditemukan');
                                  },
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 16.0),
                                // Informasi makanan
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${filteredList[index].fields.name}",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rp.${filteredList[index].fields.price}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Promo: ${filteredList[index].fields.promo}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

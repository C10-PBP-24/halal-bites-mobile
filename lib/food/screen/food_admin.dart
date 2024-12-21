import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halal_bites/food/models/food.dart';
import 'package:halal_bites/food/screen/detail_food.dart';
import 'package:halal_bites/food/screen/food_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;

class FoodAdminPage extends StatefulWidget {
  const FoodAdminPage({super.key});

  @override
  State<FoodAdminPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodAdminPage> {
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

  Future<void> deleteFood(int id) async {
    final request = context.read<CookieRequest>();
    try {
      final response =
          await request.get('http://127.0.0.1:8000/menu/delete_food/$id/');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted Failed')),
      );
    }
  }

  Future<void> editFood(
      int id, String image, String name, String price, String promo) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
          'http://127.0.0.1:8000/menu/edit-flutter/$id/',
          jsonEncode(
            <String, String>{
              'name': name,
              'price': price,
              'image': image,
              'promo': promo,
            },
          ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit successful')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit failed')),
      );
    }
  }

  void showEditDialog(Food food) {
    final imageController = TextEditingController(text: food.fields.image);
    final nameController = TextEditingController(text: food.fields.name);
    final priceController = TextEditingController(text: food.fields.price);
    final promoController =
        TextEditingController(text: food.fields.promo ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Food'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: promoController,
                decoration: const InputDecoration(labelText: 'Promo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final image = imageController.text;
                final name = nameController.text;
                final price = priceController.text;
                final promo = promoController.text;

                await editFood(food.pk, image, name, price, promo);
                setState(() {}); // Refresh UI
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  double budgetFilter = 0;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // return Scaffold(

    // );
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
                const SizedBox(width: 8.0), // Jarak antara filter dan tombol
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddFoodPage(), // Navigasi ke form tambah makanan
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Food'),
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
                              gradient: LinearGradient(
                              colors: [Colors.yellow.shade100, Colors.yellow.shade300],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
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
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      showEditDialog(filteredList[index]),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    // Konfirmasi penghapusan
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                            'Are you sure you want to delete this item?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await deleteFood(filteredList[index].pk);
                                      setState(
                                          () {}); // Refresh UI after deletion
                                    }
                                  },
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

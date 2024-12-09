import 'package:flutter/material.dart';
import 'package:halal_bites/models/resto.dart';
import 'package:halal_bites/resto/resto_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RestoPage extends StatefulWidget {
  const RestoPage({super.key});

  @override
  State<RestoPage> createState() => _RestoPageState();
}

class _RestoPageState extends State<RestoPage> {
  Future<List<Resto>> fetchResto(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/resto/json/');
    var data = response;
    List<Resto> listResto = [];
    for (var d in data) {
      if (d != null) {
        listResto.add(Resto.fromJson(d));
      }
    }
    return listResto;
  }

  Future<void> deleteResto(int id) async {
    final url = Uri.parse('http://127.0.0.1:8000/resto/delete-resto/$id/');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 204) {
        // Successfully deleted
        print('Restaurant deleted');
      } else {
        // Error handling
        print('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String nameFilter = '';
  String locationFilter = '';

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
      ),
      body: Row(
        children: [
          // Filter Section
          Container(
            width: 250,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Restaurants',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nama:',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      nameFilter = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Lokasi:',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      locationFilter = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.black,
                //   ),
                //   child: const Text('Filter'),
                // ),
              ],
            ),
          ),
          // List Section
          Expanded(
            child: FutureBuilder(
              future: fetchResto(request),
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
                    List<Resto> filteredList = snapshot.data!.where((resto) {
                      final nameMatches = nameFilter.isEmpty ||
                          resto.fields.nama.toLowerCase().contains(nameFilter);
                      final locationMatches = locationFilter.isEmpty ||
                          resto.fields.lokasi
                              .toString()
                              .toLowerCase()
                              .contains(locationFilter);
                      return nameMatches && locationMatches;
                    }).toList();

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (_, index) => Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${filteredList[index].fields.nama}",
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Lokasi: ${filteredList[index].fields.lokasi}",
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Detail navigation logic
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                      ),
                                      child: const Text(
                                        'Lihat Detail',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        deleteResto(filteredList[index].pk);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestoFormPage(), // Navigate to form page
            ),
          );
        },
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

extension on CookieRequest {
  delete(String s) {}
}

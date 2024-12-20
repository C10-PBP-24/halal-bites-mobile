import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:halal_bites/resto/models/resto.dart';
import 'package:halal_bites/resto/screens/resto_detail.dart';
import 'package:halal_bites/resto/screens/resto_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RestoPage extends StatefulWidget {
  const RestoPage({super.key});

  @override
  State<RestoPage> createState() => _RestoPageState();
}

class _RestoPageState extends State<RestoPage> {
  List<Resto> filteredList = [];
  String nameFilter = '';
  String locationFilter = '';
  String? csrfToken;

  Future<List<Resto>> fetchResto(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/resto/json/');
    List<Resto> listResto = [];
    for (var d in response) {
      if (d != null) {
        try {
          listResto.add(Resto.fromJson(d));
        } catch (e) {
          print('Error parsing Resto for data: $d');          
        }
      }
    }
    
    return listResto;
  }


  Future<void> fetchCsrfToken() async {
    final url = Uri.parse('http://127.0.0.1:8000/resto/get-csrf-token/');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        csrfToken = data['csrfToken'];
      } else {
        print('Failed to fetch CSRF token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching CSRF token: $e');
    }
  }

  Future<void> deleteRestoById(int id) async {
    if (csrfToken == null) {
      await fetchCsrfToken();
    }

    final url = Uri.parse('http://127.0.0.1:8000/resto/delete-resto/$id/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken!,
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted successfully'),
            duration: Duration(seconds: 2), // Customize duration as needed
          ),
        );
        setState(() {});
      } else {
        print('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCsrfToken(); // Fetch CSRF token when the widget initializes
  }

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
              ],
            ),
          ),
          // List Section
          Expanded(
            child: FutureBuilder(
              future: fetchResto(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
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
                                "Lokasi: ${lokasiValues.reverse[filteredList[index].fields.lokasi]}",
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RestoDetailPage(
                                            resto: filteredList[index], // Pass the Resto object
                                          ),
                                        ),
                                      );
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
                                      deleteRestoById(filteredList[index].pk);
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
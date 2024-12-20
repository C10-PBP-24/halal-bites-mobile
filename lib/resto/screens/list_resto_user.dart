import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:halal_bites/resto/models/resto.dart';
import 'package:halal_bites/resto/screens/resto_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RestoPageUser extends StatefulWidget {
  const RestoPageUser({super.key});

  @override
  State<RestoPageUser> createState() => _RestoPageState();
}

class _RestoPageState extends State<RestoPageUser> {
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


  @override
  void initState() {
    super.initState();
    fetchCsrfToken();
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
            title: const Text('Restaurants'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow.shade700, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: const Color.fromARGB(255, 3, 90, 6),
                        decoration: InputDecoration(
                          labelText: 'Nama:',
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 3, 90, 6),
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 3, 90, 6),
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.auto_awesome, color: Colors.black),
                        ),
                        onChanged: (value) {
                          setState(() {
                            nameFilter = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        cursorColor: const Color.fromARGB(255, 3, 90, 6),
                        decoration: InputDecoration(
                          labelText: 'Lokasi:',
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 3, 90, 6),
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 3, 90, 6),
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.location_on, color: Colors.black),
                        ),
                        onChanged: (value) {
                          setState(() {
                            locationFilter = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                        resto.fields.lokasi.toString().toLowerCase().contains(locationFilter);
                    return nameMatches && locationMatches;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (_, index) {
                      final resto = filteredList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestoDetailPage(resto: resto),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.yellow.shade100, Colors.yellow.shade300],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.black),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resto.fields.nama,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Lokasi: ${lokasiValues.reverse[filteredList[index].fields.lokasi]}",
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
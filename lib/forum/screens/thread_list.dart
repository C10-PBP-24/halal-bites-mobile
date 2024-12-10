import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';  // Assuming you have authentication setup
import 'package:halal_bites/forum/models/thread_entry.dart';  // Import your Thread model here

class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key});

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  Future<List<Thread>> fetchThread(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/threads/json/');
    return threadFromJson(jsonEncode(response));
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread Details'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Thread>>(
        future: fetchThread(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title: ${snapshot.data![0].fields.title}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Created by: ${snapshot.data![0].fields.user}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Foods: ${snapshot.data![0].fields.foods.join(", ")}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 20, thickness: 2),
                    const Text(
                      'Posts:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(snapshot.data![index].fields.content),
                            subtitle: Text('By ${snapshot.data![index].fields.user}'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add post logic or navigation
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

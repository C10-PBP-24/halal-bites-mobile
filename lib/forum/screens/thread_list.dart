import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';  // Assuming you have authentication setup
import 'package:halal_bites/forum/models/thread_entry.dart';  // Import your Thread model here
import 'package:halal_bites/forum/widgets/thread_form.dart';
import 'package:halal_bites/forum/widgets/edit_thread_form.dart';
import 'package:halal_bites/forum/screens/post_list.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key});

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  Future<List<Thread>> fetchThread(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/forum/threads/json/');
    return threadFromJson(jsonEncode(response));
  }

  Future<void> deleteThread(CookieRequest request, int threadId) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/threads/$threadId/delete/',
        {},
      );

      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thread berhasil dihapus!")),
          );
          setState(() {}); 
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus thread")),
        );
      }
    }
  }

  Future<String> getFoodNames(List<int> foodIds) async {
    try {
      List<String> foodNames = [];
      for (var id in foodIds) {
        final response = await http.get(
          Uri.parse('http://127.0.0.1:8000/food/get_food/$id/'),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List && data.isNotEmpty) {
            var food = data[0];
            if (food['fields'] != null && food['fields']['name'] != null) {
              foodNames.add(food['fields']['name']);
            }
          }
        }
      }
      return foodNames.join(", ");
    } catch (e) {
      print('Error getting food names: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forum Threads',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
      ),
      body: FutureBuilder<List<Thread>>(
        future: fetchThread(request),
        builder: (context, AsyncSnapshot<List<Thread>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada thread.',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final thread = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostListPage(
                          threadId: thread.pk,
                          threadTitle: thread.fields.title,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                thread.fields.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (thread.fields.user == request.jsonData['username'])
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditThreadForm(
                                            threadId: thread.pk,
                                            currentTitle: thread.fields.title,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Konfirmasi'),
                                        content: const Text(
                                          'Apakah Anda yakin ingin menghapus thread ini?'
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              deleteThread(request, thread.pk);
                                            },
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dibuat oleh: ${thread.fields.user}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        if (thread.fields.foods.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: getFoodNames(thread.fields.foods),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                return Text(
                                  'Makanan: ${snapshot.data}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Dibuat pada: ${thread.fields.createdAt.toString().split('.')[0]}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThreadFormPage(),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

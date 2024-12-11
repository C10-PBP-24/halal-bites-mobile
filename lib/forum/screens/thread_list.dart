import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';  // Assuming you have authentication setup
import 'package:halal_bites/forum/models/thread_entry.dart';  // Import your Thread model here
import 'package:halal_bites/forum/widgets/thread_form.dart';
import 'package:halal_bites/forum/widgets/edit_thread_form.dart';

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

  Future<void> deleteThread(CookieRequest request, int threadId) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/threads/$threadId/delete/',
        {},
      );
      
      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thread berhasil dihapus!")),
          );
          setState(() {}); // Refresh the list
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final thread = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      thread.fields.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dibuat oleh: ${thread.fields.user}'),
                        if (thread.fields.foods.isNotEmpty)
                          Text('Foods: ${thread.fields.foods.join(", ")}'),
                      ],
                    ),
                    trailing: thread.fields.user == request.jsonData['username']
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
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
                                    setState(() {}); // Refresh list jika edit berhasil
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Konfirmasi'),
                                      content: const Text(
                                        'Apakah Anda yakin ingin menghapus thread ini?'
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => 
                                            Navigator.pop(context),
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
                                  );
                                },
                              ),
                            ],
                          )
                        : null,
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
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Tidak ada thread.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThreadFormPage(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

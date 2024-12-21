import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:halal_bites/forum/models/post_entry.dart';
import 'package:halal_bites/forum/widgets/post_form.dart';
import 'package:halal_bites/forum/widgets/edit_post_form.dart';

class PostListPage extends StatefulWidget {
  final int threadId;
  final String threadTitle;

  const PostListPage({
    super.key, 
    required this.threadId,
    required this.threadTitle,
  });

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  Future<List<Post>> fetchPosts(CookieRequest request) async {
    final response = await request.get(
      'http://127.0.0.1:8000/forum/threads/${widget.threadId}/json/'
    );
    return postFromJson(jsonEncode(response));
  }

  Future<void> deletePost(CookieRequest request, int postId) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/posts/$postId/delete/',
        {},
      );

      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post berhasil dihapus!")),
          );
          setState(() {}); // Refresh the list
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus post")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.threadTitle),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada post dalam thread ini.',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            post.fields.user,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              if (post.fields.user == request.jsonData['username']) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPostForm(
                                          postId: post.pk,
                                          currentContent: post.fields.content,
                                        ),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      setState(() {}); // Refresh list
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Konfirmasi'),
                                        content: const Text(
                                          'Apakah Anda yakin ingin menghapus post ini?'
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              deletePost(request, post.pk);
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
                              Text(
                                post.fields.createdAt.toString().split('.')[0],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.fields.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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
              builder: (context) => PostFormPage(
                threadId: widget.threadId,
                threadTitle: widget.threadTitle,
              ),
            ),
          );
          
          if (result == true) {
            setState(() {}); // Refresh the list when returning
          }
        },
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SamplePage extends StatefulWidget {
  SamplePage({super.key, http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  late Future<List<ApiPost>> _postsFuture;
  List<ApiPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  Future<List<ApiPost>> _fetchPosts() async {
    final response = await widget._client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      final posts = decoded
          .map((item) => ApiPost.fromJson(item as Map<String, dynamic>))
          .toList();

      _posts = posts;
      return posts;
    }

    throw Exception('Failed to load posts from the API.');
  }

  Future<void> _deletePost(int id) async {
    final response = await widget._client.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        _posts.removeWhere((post) => post.id == id);
      });
      return;
    }

    throw Exception('Failed to delete the selected post.');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.article, size: 72),
          const SizedBox(height: 12),
          const Text(
            'Sample Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<ApiPost>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final posts = snapshot.data ?? _posts;

                if (posts.isEmpty) {
                  return const Center(child: Text('No posts available.'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          post.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(post.body),
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await _deletePost(post.id);
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            foregroundColor: Colors.red.shade900,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ApiPost {
  final int id;
  final String title;
  final String body;

  const ApiPost({required this.id, required this.title, required this.body});

  factory ApiPost.fromJson(Map<String, dynamic> json) {
    return ApiPost(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      body: json['body'] as String? ?? '',
    );
  }
}

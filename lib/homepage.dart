import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'detail_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _get = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Ganti dengan API key Anda dari newsapi.org
  var api_key = '422010dfdb7a4b6fae1b4913c8ef2e4e';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future _getData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://newsapi.org/v2/everything?q=apple&sortBy=publishedAt&language=en&apiKey=$api_key",
        ),
      );

      // cek apakah respon berhasil
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // memasukan data yang diperoleh dari internet ke variabel _get
          _get = data['articles'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: ${response.statusCode}';
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      print(e);
    }
  }

  Widget _buildNewsItem(int index) {
    String imageUrl = _get[index]['urlToImage'] ?? '';
    String defaultImage =
        "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80";

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl.isNotEmpty ? imageUrl : defaultImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(defaultImage, fit: BoxFit.cover);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          title: Text(
            _get[index]['title'] ?? "No title available",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                _get[index]['description'] ?? "No description available",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(_get[index]['publishedAt'] ?? ""),
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  url: _get[index]['url'] ?? "",
                  title: _get[index]['title'] ?? "No title available",
                  content:
                      _get[index]['content'] ??
                      _get[index]['description'] ??
                      "No content available",
                  urlToImage: imageUrl.isNotEmpty ? imageUrl : defaultImage,
                  author: _get[index]['author'] ?? "Unknown Author",
                  publishedAt: _get[index]['publishedAt'] ?? "",
                  source: _get[index]['source']['name'] ?? "Unknown Source",
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "Apple News",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Apple news...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _get.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No news available', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _getData,
              child: ListView.builder(
                itemCount: _get.length,
                itemBuilder: (context, index) {
                  return _buildNewsItem(index);
                },
              ),
            ),
    );
  }
}

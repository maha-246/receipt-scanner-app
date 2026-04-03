import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // GET /documents
  Future<List<Document>> fetchDocuments() async {
    final response = await http.get(Uri.parse('$baseUrl/documents'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Document.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  // POST /documents
  Future<Document> createDocument(Document document) async {
    final response = await http.post(
      Uri.parse('$baseUrl/documents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(document.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Document.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create document: ${response.body}');
    }
  }

  // PUT /documents/{id}
  Future<Document> updateDocument(int id, Document document) async {
    final response = await http.put(
      Uri.parse('$baseUrl/documents/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(document.toJson()),
    );

    if (response.statusCode == 200) {
      return Document.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update document: ${response.body}');
    }
  }

  // DELETE /documents/{id}
  Future<void> deleteDocument(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/documents/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete document: ${response.body}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/network_recipe.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET
  Future<NetworkRecipe> fetchRecipe() async {
    final response = await http.get(Uri.parse('$baseUrl/albums/1'));

    if (response.statusCode == 200) {
      return NetworkRecipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load recipe: ${response.statusCode}');
    }
  }

  // POST
  Future<NetworkRecipe> createRecipe(NetworkRecipe recipe) async {
    final response = await http.post(
      Uri.parse('$baseUrl/albums'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(recipe.toJson()),
    );

    if (response.statusCode == 201) {
      return NetworkRecipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create recipe: ${response.statusCode}');
    }
  }

  // PUT/PATCH
  Future<NetworkRecipe> updateRecipe(int id, String newTitle) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/albums/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'title': newTitle}),
    );

    if (response.statusCode == 200) {
      return NetworkRecipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update recipe: ${response.statusCode}');
    }
  }

  // DELETE
  Future<void> deleteRecipe(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/albums/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe: ${response.statusCode}');
    }
  }
}

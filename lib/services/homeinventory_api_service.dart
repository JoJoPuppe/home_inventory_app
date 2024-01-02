import 'dart:convert';
import 'package:http/http.dart' as http;
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '/models/item_model.dart';

class CreateItemService {
  static Future<Map<String, bool>> addItem(BuildContext context, Map<String, dynamic> data) async {
    // Pick an image
    if (data.containsKey('image') && data['image'] != null) {
      // Create MultipartRequest
      String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
      final url = Uri.parse('$apiDomain/items/');

      var request = http.MultipartRequest('POST', url);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name for the file
          data['image'],
          filename: 'upload.jpg', // Optional: customize the file name
        ),
      );
      // Add other fields if needed
      request.fields['name'] = data['name'] ?? '';
      request.fields['comment'] = data['comment'] ?? '';

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        throw Exception('Failed to create item.');
      }
    }
    else {
      return {'success': false};
    }
  }

  static Future<List<Item>> getChildren(BuildContext context, int? id) async {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    id = id ?? 0;
    final url = Uri.parse('$apiDomain/items/children/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Item> items = data.map((item) => Item.fromJson(item)).toList();
      print(items);
      return items;
    } else {
      throw Exception('Failed to load items.');
    }

  }

  static Future<List<Item>> getItems(BuildContext context) async {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    final url = Uri.parse('$apiDomain/items/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Item> items = data.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load items.');
    }
  }

}

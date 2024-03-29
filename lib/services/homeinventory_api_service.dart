import 'dart:convert';
import 'package:http/http.dart' as http;
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '/models/item_model.dart';

class CreateItemService {
  static Future<String> addItem(
      BuildContext context, Map<String, dynamic> data) async {
    // Pick an image
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/items/');
    final request = http.MultipartRequest('POST', url);

    if (data.containsKey('image') && data['image'] != null) {
      // Create MultipartRequest
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name for the file
          data['image'],
          filename: 'upload.jpg', // Optional: customize the file name
        ),
      );
    }
    // Add other fields if needed
    request.fields['name'] = data['name'] ?? '';
    request.fields['comment'] = data['comment'] ?? '';
    request.fields['label_id'] = data['label_id'] ?? '';
    if (data.containsKey('parent_item_id')) {
      if (data['parent_item_id'] != null && data['parent_item_id'] != 'null') {
        request.fields['parent_item_id'] = data['parent_item_id'];
      }
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return data['name'];
    } else {
      throw Exception('Failed to create item.');
    }
  }

  static Future<bool> updateItem(
      BuildContext context, Map<String, dynamic> data, int? id) async {
    // Pick an image
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/items/$id');
    final request = http.MultipartRequest('PUT', url);

    if (data.containsKey('image') && data['image'] != null) {
      // Create MultipartRequest
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name for the file
          data['image'],
          filename: 'upload.jpg', // Optional: customize the file name
        ),
      );
    }
    if (data.containsKey('parent_item_id')) {
      if (data['parent_item_id'] != null && data['parent_item_id'] != 'null') {
        request.fields['parent_item_id'] = data['parent_item_id'];
      }
    }
    if (data.containsKey('label_id')) {
      if (data['label_id'] != null && data['label_id'] != 'null') {
        request.fields['label_id'] = data['label_id'];
      }
    }
    if (data.containsKey('comment')) {
      if (data['comment'] != null && data['comment'] != 'null') {
        request.fields['comment'] = data['comment'];
      }
    }
    if (data.containsKey('name')) {
      if (data['name'] != null && data['name'] != 'null') {
        request.fields['name'] = data['name'];
      }
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create item.');
    }
  }

  static Future<List<Item>> getChildren(BuildContext context, int? id) async {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    id = id ?? 0;
    final url = Uri.parse('$apiDomain/items/children/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Item> items = data.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load items.');
    }
  }

  static Future<List<Item>> getItems(BuildContext context) async {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/items/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Item> items = data.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load items.');
    }
  }

  static Future<Item> getItem(BuildContext context, int id) async {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/items/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      final Item item = Item.fromJson(data);
      return item;
    } else {
      throw Exception('Failed to load item.');
    }
  }

  static Future<Item> getItemByLabelCode(
      BuildContext context, String labelId) async {
    // try to cast to lableId to int
    try {
      int.parse(labelId);
    } catch (e) {
      throw Exception('only number codes are allowed');
    }
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/items/label/$labelId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      final Item item = Item.fromJson(data);
      return item;
    } else {
      String errorMessage =
          jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw Exception(errorMessage);
    }
  }

  static Future<List<Item>> searchItems(
      BuildContext context, String? query) async {
    if (query == null || query.isEmpty) {
      return [];
    }
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/search/?query=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Item> items = data.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      String errorMessage =
          jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw Exception('Failed to load items. $errorMessage');
    }
  }

  static Future<Item> deleteItem(BuildContext context, int id) async {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    final url = Uri.parse('$apiDomain/items/$id');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      final Item item = Item.fromJson(data);
      return item;
    } else {
      throw Exception('Failed to delete item.');
    }
  }
}

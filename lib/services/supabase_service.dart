// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String baseUrl = 'https://lsyonosmjndjefhpmpoy.supabase.co/rest/v1';
  static const String apiKey = 'sb_publishable_npecpb6lu5NrkYHxgLC2qA_z_rNXhFH';

  Map<String, String> get _headers => {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation,resolution=merge-duplicates',
      };

  /// Fetch all rows from a table
  Future<List<Map<String, dynamic>>> get(String table, {String query = 'select=*'}) async {
    try {
      final url = '$baseUrl/$table?$query';
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: _headers,
      );
      if (response.status != null && response.status! >= 200 && response.status! < 300) {
        final List list = jsonDecode(response.responseText ?? '[]');
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      // ignore network errors / fallback gracefully
    }
    return [];
  }

  /// Upsert a single row into a table
  Future<bool> upsert(String table, Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/$table';
      final response = await html.HttpRequest.request(
        url,
        method: 'POST',
        sendData: jsonEncode(data),
        requestHeaders: _headers,
      );
      return response.status != null && response.status! >= 200 && response.status! < 300;
    } catch (_) {
      return false;
    }
  }

  /// Upsert a batch of rows
  Future<bool> upsertBatch(String table, List<Map<String, dynamic>> dataList) async {
    if (dataList.isEmpty) return true;
    try {
      final url = '$baseUrl/$table';
      final response = await html.HttpRequest.request(
        url,
        method: 'POST',
        sendData: jsonEncode(dataList),
        requestHeaders: _headers,
      );
      return response.status != null && response.status! >= 200 && response.status! < 300;
    } catch (_) {
      return false;
    }
  }

  /// Delete a row by column
  Future<bool> delete(String table, String column, String value) async {
    try {
      final url = '$baseUrl/$table?$column=eq.$value';
      final response = await html.HttpRequest.request(
        url,
        method: 'DELETE',
        requestHeaders: _headers,
      );
      return response.status != null && response.status! >= 200 && response.status! < 300;
    } catch (_) {
      return false;
    }
  }
}

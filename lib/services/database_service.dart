// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import '../models/app_models.dart';
import 'app_store.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // 1. Export Full Database to JSON file for offline backup / DB migration
  void exportDatabaseBackupJson() {
    final store = AppStore();
    final backupData = {
      'app': 'E-Comes Abel\'z Handmade',
      'version': '4.9.1',
      'exportedAt': DateTime.now().toIso8601String(),
      'products': store.products.map((e) => e.toJson()).toList(),
      'orders': store.orders.map((e) => e.toJson()).toList(),
      'transactions': store.transactions.map((e) => e.toJson()).toList(),
      'customers': store.customers.map((e) => e.toJson()).toList(),
      'categories': store.categories.map((e) => e.toJson()).toList(),
      'brands': store.brands.map((e) => e.toJson()).toList(),
      'promos': store.promos.map((e) => e.toJson()).toList(),
      'reviews': store.reviews.map((e) => e.toJson()).toList(),
      'chatMessages': store.chatMessages.map((e) => e.toJson()).toList(),
      'settings': store.settings.toJson(),
      'landingConfig': store.landingConfig.toJson(),
    };

    final jsonString = jsonEncode(backupData);
    final blob = html.Blob([jsonString], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'ecomes_database_backup_${DateTime.now().millisecondsSinceEpoch}.json')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // 2. Import Full Database from JSON file
  Future<bool> importDatabaseBackupJson(dynamic event) async {
    final target = (event as dynamic).target;
    if (target is html.InputElement && target.files != null && target.files!.isNotEmpty) {
      final file = target.files![0];
      final reader = html.FileReader();
      reader.readAsText(file);
      await reader.onLoadEnd.first;

      if (reader.result != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(reader.result as String);
          final store = AppStore();

          if (data.containsKey('products')) {
            store.products = (data['products'] as List).map((e) => ProductItem.fromJson(e)).toList();
          }
          if (data.containsKey('orders')) {
            store.orders = (data['orders'] as List).map((e) => OrderItem.fromJson(e)).toList();
          }
          if (data.containsKey('transactions')) {
            store.transactions = (data['transactions'] as List).map((e) => TransactionItem.fromJson(e)).toList();
          }
          if (data.containsKey('customers')) {
            store.customers = (data['customers'] as List).map((e) => CustomerItem.fromJson(e)).toList();
          }
          if (data.containsKey('categories')) {
            store.categories = (data['categories'] as List).map((e) => CategoryItem.fromJson(e)).toList();
          }
          if (data.containsKey('reviews')) {
            store.reviews = (data['reviews'] as List).map((e) => ReviewItem.fromJson(e)).toList();
          }
          if (data.containsKey('settings')) {
            store.settings = StoreSettings.fromJson(data['settings']);
          }

          store.saveAll();
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    return false;
  }

  // 3. REST API / Supabase Remote Database Sync Stub
  Future<Map<String, dynamic>> syncWithCloudDatabase({
    required String apiEndpoint,
    required String apiKey,
  }) async {
    // Stub function ready to connect to external PostgreSQL / Supabase REST API
    final store = AppStore();
    return {
      'status': 'success',
      'syncedProducts': store.products.length,
      'syncedOrders': store.orders.length,
      'endpoint': apiEndpoint.isEmpty ? 'https://api.supabase.co/rest/v1' : apiEndpoint,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

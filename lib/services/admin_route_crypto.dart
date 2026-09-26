// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';
import 'package:jaspr/jaspr.dart';

import '../pages/about.dart';
import '../pages/categories.dart';
import '../pages/chat_page.dart';
import '../pages/customers.dart';
import '../pages/home.dart';
import '../pages/invoice_page.dart';
import '../pages/kanban.dart';
import '../pages/landing_cms.dart';
import '../pages/not_found.dart';
import '../pages/orders.dart';
import '../pages/products.dart';
import '../pages/profile.dart';
import '../pages/promos.dart';
import '../pages/reports.dart';
import '../pages/reviews.dart';
import '../pages/settings.dart';

/// Service untuk enkripsi, dekripsi, dan resolusi URL Admin E-Comes.
/// Memastikan semua route admin berformat /admin/{content} dan terenkripsi aman.
class AdminRouteCrypto {
  // Secret key untuk enkripsi URL-safe
  static const String _secretKey = 'EcomesAdminSecurityKey2026Protected';
  static const String _prefix = 'ecm';

  // Toggle global untuk mode enkripsi URL
  static bool isEncryptionEnabled = true;

  // Pemetaan rute resmi admin
  static const Map<String, String> pageTitles = {
    'dashboard': 'Dashboard V1 - E-Comes Admin',
    'products': 'Produk & Stok - E-Comes Admin',
    'orders': 'Pesanan Toko - E-Comes Admin',
    'kanban': 'Fulfillment Kanban - E-Comes Admin',
    'customers': 'Pelanggan (CRM) - E-Comes Admin',
    'categories': 'Kategori & Brand - E-Comes Admin',
    'promos': 'Kupon & Diskon - E-Comes Admin',
    'reviews': 'Ulasan & Rating - E-Comes Admin',
    'chat': 'Live Chat Support - E-Comes Admin',
    'invoice': 'Cetak Invoice - E-Comes Admin',
    'reports': 'Laporan Penjualan - E-Comes Admin',
    'landing': 'Manajemen Landing Page - E-Comes Admin',
    'landing-cms': 'Manajemen Landing Page - E-Comes Admin',
    'settings': 'Pengaturan Toko - E-Comes Admin',
    'profile': 'Profil Admin - E-Comes Admin',
    'about': 'Tentang Aplikasi - E-Comes Admin',
  };

  /// Mengenkripsi nama target halaman menjadi token URL-safe: `e-{token}`
  static String encrypt(String target) {
    try {
      final normalized = target.toLowerCase().trim();
      final payload = '$_prefix|$normalized|${_simpleChecksum(normalized)}';
      final bytes = utf8.encode(payload);
      final keyBytes = utf8.encode(_secretKey);

      final encryptedBytes = <int>[];
      for (var i = 0; i < bytes.length; i++) {
        encryptedBytes.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      final base64Str = base64Url.encode(encryptedBytes).replaceAll('=', '');
      return 'e-$base64Str';
    } catch (_) {
      return 'e-$target';
    }
  }

  /// Mendekripsi token `e-{token}` kembali ke target halaman asli
  static String? decrypt(String encrypted) {
    try {
      if (!encrypted.startsWith('e-')) {
        // Jika bukan format terenkripsi, cek apakah merupakan slug yang valid
        final plain = encrypted.toLowerCase().trim();
        if (pageTitles.containsKey(plain)) return plain;
        return null;
      }

      final rawToken = encrypted.substring(2);
      // Tambahkan padding base64 jika diperlukan
      var padded = rawToken;
      while (padded.length % 4 != 0) {
        padded += '=';
      }

      final bytes = base64Url.decode(padded);
      final keyBytes = utf8.encode(_secretKey);

      final decryptedBytes = <int>[];
      for (var i = 0; i < bytes.length; i++) {
        decryptedBytes.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      final payload = utf8.decode(decryptedBytes);
      final parts = payload.split('|');
      if (parts.length == 3 && parts[0] == _prefix) {
        final target = parts[1];
        final checksum = int.tryParse(parts[2]);
        if (checksum == _simpleChecksum(target)) {
          return target;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Menghasilkan URL lengkap untuk halaman admin tertentu.
  /// Jika [isEncryptionEnabled] true, menghasilkan `/admin/e-{encrypted_token}`.
  /// Jika false, menghasilkan `/admin/{target}`.
  static String pathFor(String target) {
    final cleanTarget = target.startsWith('/admin/')
        ? target.substring(7)
        : target.startsWith('/')
            ? target.substring(1)
            : target;

    if (isEncryptionEnabled) {
      return '/admin/${encrypt(cleanTarget)}';
    } else {
      return '/admin/$cleanTarget';
    }
  }

  /// Memeriksa apakah suatu path adalah halaman aktif tertentu (baik versi terenkripsi maupun plain)
  static bool isPageActive(String currentPath, String targetPage) {
    final cleanPath = currentPath.replaceAll('/ecomes', '');
    if (cleanPath == '/admin' || cleanPath == '/admin/') {
      return targetPage == 'dashboard' || targetPage == 'admin';
    }

    if (cleanPath.startsWith('/admin/')) {
      final slug = cleanPath.substring(7);
      if (slug.startsWith('e-')) {
        final decrypted = decrypt(slug);
        return decrypted == targetPage;
      }
      return slug == targetPage;
    }

    // Cek route lama (backward compatibility)
    return cleanPath == '/$targetPage';
  }

  /// Meresolusi slug atau token menjadi Component Jaspr yang tepat
  static Component resolveComponent(String? slugOrToken) {
    if (slugOrToken == null || slugOrToken.isEmpty || slugOrToken == 'dashboard') {
      return const Home();
    }

    String? page = slugOrToken;
    if (slugOrToken.startsWith('e-')) {
      page = decrypt(slugOrToken);
    }

    if (page == null) {
      return const NotFoundPage();
    }

    switch (page) {
      case 'dashboard':
      case 'admin':
        return const Home();
      case 'products':
        return const ProductsPage();
      case 'orders':
        return const OrdersPage();
      case 'kanban':
        return const KanbanPage();
      case 'customers':
        return const CustomersPage();
      case 'categories':
        return const CategoriesPage();
      case 'promos':
        return const PromosPage();
      case 'reviews':
        return const ReviewsPage();
      case 'chat':
        return const ChatPage();
      case 'invoice':
        return const InvoicePage();
      case 'reports':
        return const ReportsPage();
      case 'landing':
      case 'landing-cms':
        return const LandingCmsPage();
      case 'settings':
        return const SettingsPage();
      case 'profile':
        return const ProfilePage();
      case 'about':
        return const About();
      default:
        return const NotFoundPage();
    }
  }

  static int _simpleChecksum(String str) {
    var sum = 0;
    for (var i = 0; i < str.length; i++) {
      sum = (sum + str.codeUnitAt(i) * (i + 1)) % 10007;
    }
    return sum;
  }
}

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/admin_layout.dart';
import 'pages/about.dart';
import 'pages/categories.dart';
import 'pages/chat_page.dart';
import 'pages/customers.dart';
import 'pages/home.dart';
import 'pages/invoice_page.dart';
import 'pages/landing_cms.dart';
import 'pages/landing_page.dart';
import 'pages/login.dart';
import 'pages/not_found.dart';
import 'pages/orders.dart';
import 'pages/products.dart';
import 'pages/profile.dart';
import 'pages/promos.dart';
import 'pages/reports.dart';
import 'pages/reviews.dart';
import 'pages/settings.dart';
import 'services/admin_route_crypto.dart';
import 'services/auth_service.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: '/',
          title: "Abel'z Handmade - Toko Rajutan & Kerajinan Estetik",
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/ecomes',
          title: "Abel'z Handmade - Toko Rajutan & Kerajinan Estetik",
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/landing',
          title: "Abel'z Handmade - Toko Rajutan & Kerajinan Estetik",
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/ecomes/landing',
          title: "Abel'z Handmade - Toko Rajutan & Kerajinan Estetik",
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/store',
          title: "Abel'z Handmade - Toko Rajutan & Kerajinan Estetik",
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/ecomes/store',
          title: "Abel'z Handmade - Toko Rajutan & Kerajinan Estetik",
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/login',
          title: 'Masuk Akun - Abel\'z Handmade & E-Comes',
          builder: (context, state) => const LoginPage(initialMode: 'login'),
        ),
        Route(
          path: '/ecomes/login',
          title: 'Masuk Akun - Abel\'z Handmade & E-Comes',
          builder: (context, state) => const LoginPage(initialMode: 'login'),
        ),
        Route(
          path: '/register',
          title: 'Daftar Member - Abel\'z Handmade & E-Comes',
          builder: (context, state) => const LoginPage(initialMode: 'register'),
        ),
        Route(
          path: '/ecomes/register',
          title: 'Daftar Member - Abel\'z Handmade & E-Comes',
          builder: (context, state) => const LoginPage(initialMode: 'register'),
        ),
        Route(
          path: '/auth',
          title: 'Portal Akun - Abel\'z Handmade & E-Comes',
          builder: (context, state) => const LoginPage(),
        ),
        Route(
          path: '/ecomes/auth',
          title: 'Portal Akun - Abel\'z Handmade & E-Comes',
          builder: (context, state) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final auth = AuthService();
            if (!auth.isLoggedIn) {
              return const LoginPage();
            }
            return AdminLayout(child: child);
          },
          routes: [
            // Rute dinamis admin terenkripsi & berslug: /admin/:slug
            Route(
              path: '/admin/:slug',
              title: 'E-Comes Admin Panel - Protected',
              builder: (context, state) {
                final slug = state.params['slug'];
                return AdminRouteCrypto.resolveComponent(slug);
              },
            ),
            Route(
              path: '/ecomes/admin/:slug',
              title: 'E-Comes Admin Panel - Protected',
              builder: (context, state) {
                final slug = state.params['slug'];
                return AdminRouteCrypto.resolveComponent(slug);
              },
            ),
            Route(path: '/admin', title: 'Dashboard V1 - E-Comes Admin', builder: (context, state) => const Home()),
            Route(path: '/ecomes/admin', title: 'Dashboard V1 - E-Comes Admin', builder: (context, state) => const Home()),
            Route(path: '/dashboard', title: 'Dashboard V1 - E-Comes Admin', builder: (context, state) => const Home()),
            Route(path: '/ecomes/dashboard', title: 'Dashboard V1 - E-Comes Admin', builder: (context, state) => const Home()),
            Route(path: '/products', title: 'Produk & Stok - E-Comes Admin', builder: (context, state) => const ProductsPage()),
            Route(path: '/ecomes/products', title: 'Produk & Stok - E-Comes Admin', builder: (context, state) => const ProductsPage()),
            Route(path: '/admin/products', title: 'Produk & Stok - E-Comes Admin', builder: (context, state) => const ProductsPage()),
            Route(path: '/ecomes/admin/products', title: 'Produk & Stok - E-Comes Admin', builder: (context, state) => const ProductsPage()),
            Route(path: '/orders', title: 'Pesanan Toko - E-Comes Admin', builder: (context, state) => const OrdersPage()),
            Route(path: '/ecomes/orders', title: 'Pesanan Toko - E-Comes Admin', builder: (context, state) => const OrdersPage()),
            Route(path: '/admin/orders', title: 'Pesanan Toko - E-Comes Admin', builder: (context, state) => const OrdersPage()),
            Route(path: '/ecomes/admin/orders', title: 'Pesanan Toko - E-Comes Admin', builder: (context, state) => const OrdersPage()),
            Route(path: '/customers', title: 'Pelanggan - E-Comes Admin', builder: (context, state) => const CustomersPage()),
            Route(path: '/ecomes/customers', title: 'Pelanggan - E-Comes Admin', builder: (context, state) => const CustomersPage()),
            Route(path: '/admin/customers', title: 'Pelanggan - E-Comes Admin', builder: (context, state) => const CustomersPage()),
            Route(path: '/ecomes/admin/customers', title: 'Pelanggan - E-Comes Admin', builder: (context, state) => const CustomersPage()),
            Route(path: '/categories', title: 'Kategori & Brand - E-Comes Admin', builder: (context, state) => const CategoriesPage()),
            Route(path: '/ecomes/categories', title: 'Kategori & Brand - E-Comes Admin', builder: (context, state) => const CategoriesPage()),
            Route(path: '/admin/categories', title: 'Kategori & Brand - E-Comes Admin', builder: (context, state) => const CategoriesPage()),
            Route(path: '/ecomes/admin/categories', title: 'Kategori & Brand - E-Comes Admin', builder: (context, state) => const CategoriesPage()),
            Route(path: '/promos', title: 'Kupon & Diskon - E-Comes Admin', builder: (context, state) => const PromosPage()),
            Route(path: '/ecomes/promos', title: 'Kupon & Diskon - E-Comes Admin', builder: (context, state) => const PromosPage()),
            Route(path: '/admin/promos', title: 'Kupon & Diskon - E-Comes Admin', builder: (context, state) => const PromosPage()),
            Route(path: '/ecomes/admin/promos', title: 'Kupon & Diskon - E-Comes Admin', builder: (context, state) => const PromosPage()),
            Route(path: '/reviews', title: 'Ulasan & Rating - E-Comes Admin', builder: (context, state) => const ReviewsPage()),
            Route(path: '/ecomes/reviews', title: 'Ulasan & Rating - E-Comes Admin', builder: (context, state) => const ReviewsPage()),
            Route(path: '/admin/reviews', title: 'Ulasan & Rating - E-Comes Admin', builder: (context, state) => const ReviewsPage()),
            Route(path: '/ecomes/admin/reviews', title: 'Ulasan & Rating - E-Comes Admin', builder: (context, state) => const ReviewsPage()),
            Route(path: '/chat', title: 'Live Chat Support - E-Comes Admin', builder: (context, state) => const ChatPage()),
            Route(path: '/ecomes/chat', title: 'Live Chat Support - E-Comes Admin', builder: (context, state) => const ChatPage()),
            Route(path: '/admin/chat', title: 'Live Chat Support - E-Comes Admin', builder: (context, state) => const ChatPage()),
            Route(path: '/ecomes/admin/chat', title: 'Live Chat Support - E-Comes Admin', builder: (context, state) => const ChatPage()),
            Route(path: '/invoice', title: 'Cetak Invoice - E-Comes Admin', builder: (context, state) => const InvoicePage()),
            Route(path: '/ecomes/invoice', title: 'Cetak Invoice - E-Comes Admin', builder: (context, state) => const InvoicePage()),
            Route(path: '/admin/invoice', title: 'Cetak Invoice - E-Comes Admin', builder: (context, state) => const InvoicePage()),
            Route(path: '/ecomes/admin/invoice', title: 'Cetak Invoice - E-Comes Admin', builder: (context, state) => const InvoicePage()),
            Route(path: '/reports', title: 'Laporan Penjualan - E-Comes Admin', builder: (context, state) => const ReportsPage()),
            Route(path: '/ecomes/reports', title: 'Laporan Penjualan - E-Comes Admin', builder: (context, state) => const ReportsPage()),
            Route(path: '/admin/reports', title: 'Laporan Penjualan - E-Comes Admin', builder: (context, state) => const ReportsPage()),
            Route(path: '/ecomes/admin/reports', title: 'Laporan Penjualan - E-Comes Admin', builder: (context, state) => const ReportsPage()),
            Route(path: '/landing-cms', title: 'Manajemen Landing Page - E-Comes Admin', builder: (context, state) => const LandingCmsPage()),
            Route(path: '/ecomes/landing-cms', title: 'Manajemen Landing Page - E-Comes Admin', builder: (context, state) => const LandingCmsPage()),
            Route(path: '/admin/landing', title: 'Manajemen Landing Page - E-Comes Admin', builder: (context, state) => const LandingCmsPage()),
            Route(path: '/ecomes/admin/landing', title: 'Manajemen Landing Page - E-Comes Admin', builder: (context, state) => const LandingCmsPage()),
            Route(path: '/settings', title: 'Pengaturan Toko - E-Comes Admin', builder: (context, state) => const SettingsPage()),
            Route(path: '/ecomes/settings', title: 'Pengaturan Toko - E-Comes Admin', builder: (context, state) => const SettingsPage()),
            Route(path: '/admin/settings', title: 'Pengaturan Toko - E-Comes Admin', builder: (context, state) => const SettingsPage()),
            Route(path: '/ecomes/admin/settings', title: 'Pengaturan Toko - E-Comes Admin', builder: (context, state) => const SettingsPage()),
            Route(path: '/profile', title: 'Profil Admin - E-Comes Admin', builder: (context, state) => const ProfilePage()),
            Route(path: '/ecomes/profile', title: 'Profil Admin - E-Comes Admin', builder: (context, state) => const ProfilePage()),
            Route(path: '/admin/profile', title: 'Profil Admin - E-Comes Admin', builder: (context, state) => const ProfilePage()),
            Route(path: '/ecomes/admin/profile', title: 'Profil Admin - E-Comes Admin', builder: (context, state) => const ProfilePage()),
            Route(path: '/about', title: 'Tentang Aplikasi - E-Comes Admin', builder: (context, state) => const About()),
            Route(path: '/ecomes/about', title: 'Tentang Aplikasi - E-Comes Admin', builder: (context, state) => const About()),
            Route(path: '/admin/about', title: 'Tentang Aplikasi - E-Comes Admin', builder: (context, state) => const About()),
            Route(path: '/ecomes/admin/about', title: 'Tentang Aplikasi - E-Comes Admin', builder: (context, state) => const About()),
            Route(path: '/*', title: '404 Halaman Tidak Ditemukan', builder: (context, state) => const NotFoundPage()),
          ],
        ),
      ],
    );
  }
}

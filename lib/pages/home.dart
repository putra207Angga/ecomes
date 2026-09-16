// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String chatInput = '';

  void _sendChat() {
    if (chatInput.trim().isEmpty) return;
    final store = AppStore();
    final newMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactId: 'CUST-001',
      sender: 'Admin Toko',
      text: chatInput.trim(),
      time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      isAdmin: true,
    );
    store.addChatMessage(newMsg);
    setState(() {
      chatInput = '';
    });
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final totalSales = store.orders.fold<double>(0, (sum, item) => sum + item.total);
    final totalProducts = store.products.length;
    final totalOrders = store.orders.length;
    final totalCustomers = store.customers.length;

    final formattedSales = 'Rp ${(totalSales / 1000000).toStringAsFixed(1)}M';

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header & Title
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Dashboard V1 - Ringkasan Toko')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Pantau kinerja penjualan, statistik stok, dan pesanan terbaru.')]),
            ]),
            div(classes: 'col-sm-6', [
              ol(classes: 'breadcrumb float-sm-end mb-0 bg-transparent p-0', [
                li(classes: 'breadcrumb-item active', [Component.text('Home / Dashboard')]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 2. Small-Box Metrics Cards (AdminLTE 4 Style)
      div(classes: 'row g-3 mb-4', [
        _buildSmallBox(formattedSales, 'Total Omset Penjualan', 'bi-currency-dollar', 'text-bg-primary', '/reports'),
        _buildSmallBox('$totalOrders Pesanan', 'Pesanan Baru Masuk', 'bi-cart-check', 'text-bg-success', '/orders'),
        _buildSmallBox('$totalProducts Katalog', 'Total Produk Aktif', 'bi-box-seam', 'text-bg-warning text-dark', '/products'),
        _buildSmallBox('$totalCustomers Pembeli', 'Pelanggan Terdaftar', 'bi-people', 'text-bg-danger', '/customers'),
      ]),

      // 2.5 Status Database DB Widget (Embedded SQLite / Zero External Server Required)
      div(classes: 'card border-0 shadow-sm rounded-4 mb-4 bg-gradient bg-light overflow-hidden', [
        div(classes: 'card-body p-3 p-md-4 d-flex align-items-center justify-content-between flex-wrap gap-3', [
          div(classes: 'd-flex align-items-center gap-3', [
            div(classes: 'bg-success text-white rounded-circle d-flex align-items-center justify-content-center shadow-sm flex-shrink-0', styles: Styles(width: 48.px, height: 48.px), [
              i(classes: 'bi bi-database-check fs-4', []),
            ]),
            div([
              div(classes: 'd-flex align-items-center gap-2 mb-1', [
                h6(classes: 'fw-bold text-dark mb-0 fs-6', [Component.text('Status Database Engine: Active')]),
                span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill fs-8 fw-bold', [
                  Component.text('SQLite / Local DB Engine'),
                ]),
              ]),
              p(classes: 'text-muted mb-0 fs-7', [
                Component.text('Standalone Local Persistence Store aktif ($totalProducts Produk, $totalOrders Pesanan, $totalCustomers Pelanggan). Siap didemokan tanpa butuh MySQL atau server eksternal.'),
              ]),
            ]),
          ]),
          Link(
            to: '/settings',
            child: a(classes: 'btn btn-outline-primary btn-sm rounded-pill px-3 py-1.5 fw-semibold shadow-xs', href: '/settings', [
              i(classes: 'bi bi-gear me-1', []),
              Component.text('Pengaturan DB & Toko'),
            ]),
          ),
        ]),
      ]),

      // 3. Main Dashboard Widgets Grid
      div(classes: 'row g-4', [
        // Left Column (Charts & Map)
        div(classes: 'col-lg-8', [
          // Sales Value Chart Card
          div(classes: 'card shadow-sm border-0 mb-4 rounded-3 overflow-hidden', [
            div(classes: 'card-header bg-white py-3 d-flex align-items-center justify-content-between border-bottom-0', [
              h5(classes: 'card-title fw-bold mb-0 text-dark', [
                i(classes: 'bi bi-graph-up-arrow text-primary me-2', []),
                Component.text('Grafik Tren Penjualan & Profit (2026)'),
              ]),
              span(classes: 'badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill', [
                Component.text('Real-Time Data'),
              ]),
            ]),
            div(classes: 'card-body', [
              div(classes: 'd-flex align-items-baseline gap-3 mb-3', [
                h2(classes: 'fw-bold mb-0 text-primary', [Component.text('Rp 1.485.000.000')]),
                span(classes: 'text-success fw-bold fs-7', [
                  i(classes: 'bi bi-arrow-up-right me-1', []),
                  Component.text('+18.5% dibanding bulan lalu'),
                ]),
              ]),
              div(classes: 'progress mb-3', styles: Styles(height: 10.px), [
                div(classes: 'progress-bar bg-primary', attributes: {'style': 'width: 65%'}, []),
                div(classes: 'progress-bar bg-success', attributes: {'style': 'width: 25%'}, []),
                div(classes: 'progress-bar bg-warning', attributes: {'style': 'width: 10%'}, []),
              ]),
              div(classes: 'd-flex justify-content-between text-muted fs-7', [
                span([i(classes: 'bi bi-circle-fill text-primary me-1', []), Component.text('Penjualan Online (65%)')]),
                span([i(classes: 'bi bi-circle-fill text-success me-1', []), Component.text('Marketplace (25%)')]),
                span([i(classes: 'bi bi-circle-fill text-warning me-1', []), Component.text('Offline Store (10%)')]),
              ]),
            ]),
          ]),

          // Top Selling Products Card
          div(classes: 'card shadow-sm border-0 rounded-3', [
            div(classes: 'card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between', [
              h5(classes: 'card-title fw-bold mb-0 text-dark', [
                i(classes: 'bi bi-fire text-danger me-2', []),
                Component.text('Produk Terlaris (Top Sellers)'),
              ]),
              Link(to: '/products', child: a(href: '/products', classes: 'btn btn-sm btn-outline-primary', [Component.text('Lihat Semua')])),
            ]),
            div(classes: 'card-body p-0', [
              div(classes: 'table-responsive', [
                table(classes: 'table table-hover align-middle mb-0', [
                  thead(classes: 'table-light fs-7', [
                    tr([
                      th(classes: 'ps-3 text-start text-nowrap', [Component.text('Produk')]),
                      th(classes: 'text-start text-nowrap', [Component.text('Kategori')]),
                      th(classes: 'text-start text-nowrap', [Component.text('Harga')]),
                      th(classes: 'text-center text-nowrap', [Component.text('Stok Tersedia')]),
                      th(classes: 'text-end pe-3 text-nowrap', [Component.text('Status')]),
                    ]),
                  ]),
                  tbody([
                    for (var p in store.products)
                      tr([
                        td(classes: 'ps-3 text-start', [
                          div(classes: 'd-flex align-items-center gap-2', [
                            img(src: p.image, classes: 'rounded-2 border', attributes: {'width': '36', 'height': '36', 'alt': p.name}),
                            div([
                              div(classes: 'fw-semibold fs-7 text-dark', [Component.text(p.name)]),
                              div(classes: 'text-muted fs-8', [Component.text('SKU: ${p.sku}')]),
                            ]),
                          ]),
                        ]),
                        td(classes: 'fs-7 text-start text-nowrap', [Component.text(p.category)]),
                        td(classes: 'fw-bold fs-7 text-primary text-start text-nowrap', [Component.text('Rp ${p.price.toInt()}')]),
                        td(classes: 'fs-7 text-center text-nowrap', [Component.text('${p.stock} item')]),
                        td(classes: 'text-end pe-3 text-nowrap', [
                          span(classes: 'badge ${p.status == 'Aktif' ? 'bg-success' : p.status == 'Menipis' ? 'bg-warning text-dark' : 'bg-danger'} rounded-pill', [
                            Component.text(p.status),
                          ]),
                        ]),
                      ]),
                  ]),
                ]),
              ]),
            ]),
          ]),
        ]),

        // Right Column (Direct Chat & Recent Orders)
        div(classes: 'col-lg-4', [
          // Direct Chat Support Widget
          div(classes: 'card shadow-sm border-0 mb-4 rounded-3 overflow-hidden', [
            div(classes: 'card-header bg-primary text-white py-3 d-flex align-items-center justify-content-between', [
              h5(classes: 'card-title fw-bold mb-0 fs-6', [
                i(classes: 'bi bi-chat-dots-fill me-2', []),
                Component.text('Direct Chat Customer Support'),
              ]),
              span(classes: 'badge bg-white text-primary rounded-pill fs-8', [Component.text('Online')]),
            ]),
            div(classes: 'card-body bg-light p-3', [
              div(classes: 'chat-messages overflow-y-auto mb-3 pe-1', styles: Styles(maxHeight: 240.px), [
                for (var msg in store.chatMessages)
                  div(classes: 'mb-2 d-flex flex-column ${msg.isAdmin ? 'align-items-end' : 'align-items-start'}', [
                    span(classes: 'fs-8 text-muted mb-1', [Component.text('${msg.sender} • ${msg.time}')]),
                    div(
                      classes: 'p-2 rounded-3 fs-7 ${msg.isAdmin ? 'bg-primary text-white' : 'bg-white border shadow-sm text-dark'}',
                      styles: Styles(maxWidth: 85.percent),
                      [Component.text(msg.text)],
                    ),
                  ]),
              ]),
              form(
                events: {
                  'submit': (e) {
                    e.preventDefault();
                    _sendChat();
                  }
                },
                [
                  div(classes: 'input-group input-group-sm', [
                    input(
                      type: InputType.text,
                      classes: 'form-control',
                      value: chatInput,
                      attributes: {'placeholder': 'Ketik pesan balasan...'},
                      events: {
                        'input': (e) {
                          chatInput = (e.target as html.InputElement).value ?? '';
                        }
                      },
                    ),
                    button(type: ButtonType.submit, classes: 'btn btn-primary', [
                      i(classes: 'bi bi-send-fill', []),
                    ]),
                  ]),
                ],
              ),
            ]),
          ]),

          // Quick Action Box
          div(classes: 'card shadow-sm border-0 rounded-3 bg-body-tertiary p-3', [
            h6(classes: 'fw-bold text-dark mb-3', [
              i(classes: 'bi bi-lightning-charge-fill text-warning me-2', []),
              Component.text('Aksi Cepat Manajemen'),
            ]),
            div(classes: 'd-grid gap-2', [
              Link(
                to: '/products',
                child: a(classes: 'btn btn-outline-primary btn-sm text-start d-flex align-items-center justify-content-between', href: '/products', [
                  span([i(classes: 'bi bi-plus-circle me-2', []), Component.text('Tambah Produk Baru')]),
                  i(classes: 'bi bi-chevron-right', []),
                ]),
              ),
              Link(
                to: '/orders',
                child: a(classes: 'btn btn-outline-success btn-sm text-start d-flex align-items-center justify-content-between', href: '/orders', [
                  span([i(classes: 'bi bi-truck me-2', []), Component.text('Update Resi Pesanan')]),
                  i(classes: 'bi bi-chevron-right', []),
                ]),
              ),
              Link(
                to: '/promos',
                child: a(classes: 'btn btn-outline-warning text-dark btn-sm text-start d-flex align-items-center justify-content-between', href: '/promos', [
                  span([i(classes: 'bi bi-ticket-perforated me-2', []), Component.text('Buat Voucher Promo')]),
                  i(classes: 'bi bi-chevron-right', []),
                ]),
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildSmallBox(String title, String subtitle, String icon, String colorClass, String route) {
    return div(classes: 'col-lg-3 col-sm-6', [
      div(classes: 'small-box $colorClass shadow-sm rounded-3 overflow-hidden position-relative p-3', [
        div(classes: 'inner', [
          h3(classes: 'fw-bold mb-1 display-7', [Component.text(title)]),
          p(classes: 'mb-0 opacity-75 fs-7', [Component.text(subtitle)]),
        ]),
        i(classes: 'bi $icon position-absolute bottom-0 end-0 fs-1 opacity-25 me-3 mb-2', []),
        Link(
          to: route,
          child: a(classes: 'small-box-footer d-block text-white text-decoration-none mt-3 pt-2 border-top border-white border-opacity-25 fs-8 fw-semibold', href: route, [
            Component.text('Kelola Detail '),
            i(classes: 'bi bi-arrow-right-circle ms-1', []),
          ]),
        ),
      ]),
    ]);
  }
}

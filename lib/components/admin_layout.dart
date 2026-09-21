// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../models/app_models.dart';
import '../services/admin_route_crypto.dart';
import '../services/app_store.dart';
import '../services/auth_service.dart';

class AdminLayout extends StatefulComponent {
  final Component child;

  const AdminLayout({required this.child, super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  String quickMessage = '';
  String headerSearchQuery = '';

  void _toggleSidebar() {
    final body = html.document.body;
    if (body != null) {
      final width = html.window.innerWidth ?? 1000;
      if (width < 992) {
        if (body.classes.contains('sidebar-open')) {
          body.classes.remove('sidebar-open');
          body.classes.add('sidebar-collapse');
        } else {
          body.classes.add('sidebar-open');
          body.classes.remove('sidebar-collapse');
        }
      } else {
        if (body.classes.contains('sidebar-collapse')) {
          body.classes.remove('sidebar-collapse');
          body.classes.add('sidebar-open');
        } else {
          body.classes.add('sidebar-collapse');
          body.classes.remove('sidebar-open');
        }
      }
    }
  }

  void _handleLogout() {
    AuthService().logout();
    Router.of(context).push('/login');
  }

  void _sendQuickChat() {
    if (quickMessage.trim().isEmpty) return;
    final store = AppStore();
    final auth = AuthService();
    final newMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactId: 'CUST-001',
      sender: auth.currentUser?.name ?? 'Admin',
      text: quickMessage.trim(),
      time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      isAdmin: true,
    );
    store.addChatMessage(newMsg);
    setState(() {
      quickMessage = '';
    });

    // Simulate customer auto-reply
    Future.delayed(const Duration(milliseconds: 1500), () {
      final autoReply = ChatMessageItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        contactId: 'CUST-001',
        sender: 'Budi Santoso',
        text: 'Terima kasih banyak atas infonya min! 👍',
        time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        isAdmin: false,
      );
      store.addChatMessage(autoReply);
      if (mounted) setState(() {});
    });
  }

  @override
  Component build(BuildContext context) {
    final user = AuthService().currentUser;
    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A';

    return div(classes: 'app-wrapper', [
      // 1. Navbar Header (Pinned Fixed at Top)
      _buildHeader(context, user, initial),

      // 2. Main Menu Sidebar (Left)
      _buildSidebar(context),

      // 3. Main Content Area
      main_(classes: 'app-main', [
        component.child,
      ]),

      // 4. Direct Chat Support Offcanvas Right Sidebar
      _buildDirectChatRightSidebar(),

      // 5. Footer
      _buildFooter(),
    ]);
  }

  Component _buildHeader(BuildContext context, UserSession? user, String initial) {
    final store = AppStore();
    final unreadChats = store.chatMessages.where((element) => !element.isAdmin).length;

    // Search Results Filtering
    final query = headerSearchQuery.trim().toLowerCase();
    final matchedProducts = query.isEmpty
        ? <ProductItem>[]
        : store.products.where((prod) => prod.name.toLowerCase().contains(query) || prod.category.toLowerCase().contains(query)).take(4).toList();
    final matchedOrders = query.isEmpty
        ? <OrderItem>[]
        : store.orders.where((o) => o.orderNo.toLowerCase().contains(query) || o.customerName.toLowerCase().contains(query)).take(4).toList();
    final matchedCustomers = query.isEmpty
        ? <CustomerItem>[]
        : store.customers.where((c) => c.name.toLowerCase().contains(query) || c.phone.contains(query)).take(4).toList();

    return nav(classes: 'app-header navbar navbar-expand bg-body shadow-sm sticky-top z-3', [
      div(classes: 'container-fluid', [
        // Left Navbar Links
        ul(classes: 'navbar-nav', [
          li(classes: 'nav-item me-2', [
            button(
              type: ButtonType.button,
              classes: 'nav-link btn btn-link text-body border-0 p-1 me-1',
              attributes: {'title': 'Toggle Sidebar Expanded / Collapsed'},
              events: {
                'click': (e) {
                  e.preventDefault();
                  e.stopPropagation();
                  _toggleSidebar();
                }
              },
              [i(classes: 'bi bi-list fs-4 text-dark', [])],
            ),
          ]),
          li(classes: 'nav-item d-none d-md-block', [
            Link(
              to: AdminRouteCrypto.pathFor('dashboard'),
              child: a(classes: 'nav-link fw-semibold text-primary d-flex align-items-center', href: AdminRouteCrypto.pathFor('dashboard'), [
                i(classes: 'bi bi-bag-check me-1', []),
                Component.text('E-Commerce Admin Panel'),
                span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill ms-2 fs-8 align-items-center gap-1 py-1 px-2', [
                  i(classes: 'bi bi-shield-lock-fill me-1', []),
                  Component.text('URL Encrypted'),
                ]),
              ]),
            ),
          ]),
        ]),

        // Interactive Premium Global Search Bar (UI/UX Upgraded)
        div(classes: 'navbar-search position-relative d-none d-md-block ms-md-4 flex-grow-1 max-w-400px', [
          div(classes: 'input-group input-group-sm rounded-pill border bg-body-tertiary shadow-xs overflow-hidden px-2 py-1 align-items-center', [
            span(classes: 'input-group-text bg-transparent border-0 pe-1 text-primary', [
              i(classes: 'bi bi-search fs-7', []),
            ]),
            input(
              type: InputType.text,
              classes: 'form-control border-0 bg-transparent shadow-none fs-7 py-1',
              attributes: {
                'placeholder': 'Cari produk, invoice, pelanggan... (Ctrl+K)',
                'value': headerSearchQuery,
              },
              events: {
                'input': (e) {
                  setState(() {
                    headerSearchQuery = (e.target as html.InputElement).value ?? '';
                  });
                }
              },
            ),
            if (headerSearchQuery.isNotEmpty)
              button(
                type: ButtonType.button,
                classes: 'btn btn-sm btn-link text-secondary p-0 me-1 border-0 text-decoration-none',
                events: {'click': (e) => setState(() => headerSearchQuery = '')},
                [i(classes: 'bi bi-x-circle-fill fs-7', [])]
              )
            else
              span(classes: 'badge bg-secondary-subtle text-secondary border rounded px-1.5 py-0.5 fs-8 me-1 fw-mono', [
                Component.text('Ctrl K'),
              ]),
          ]),

          // Live Search Results Dropdown Overlay
          if (headerSearchQuery.trim().isNotEmpty)
            div(classes: 'position-absolute top-100 start-0 w-100 mt-1 bg-white border rounded-3 shadow-lg z-3 overflow-hidden p-2 text-start', [
              if (matchedProducts.isEmpty && matchedOrders.isEmpty && matchedCustomers.isEmpty)
                div(classes: 'p-3 text-center text-muted fs-7', [
                  i(classes: 'bi bi-search text-secondary mb-1 d-block fs-5', []),
                  Component.text('Tidak ditemukan hasil untuk "${headerSearchQuery.trim()}"'),
                ])
              else ...[
                if (matchedProducts.isNotEmpty) ...[
                  div(classes: 'px-2 py-1 fs-8 fw-bold text-uppercase text-muted border-bottom mb-1', [Component.text('Produk Katalog')]),
                  for (var p in matchedProducts)
                    Link(
                      to: AdminRouteCrypto.pathFor('products'),
                      child: a(
                        classes: 'dropdown-item py-1.5 px-2 rounded-2 d-flex align-items-center justify-content-between fs-7 text-dark',
                        href: AdminRouteCrypto.pathFor('products'),
                        events: {'click': (e) => setState(() => headerSearchQuery = '')},
                        [
                          div(classes: 'd-flex align-items-center gap-2', [
                            i(classes: 'bi bi-box-seam text-warning', []),
                            span(classes: 'fw-semibold text-truncate max-w-200px', [Component.text(p.name)]),
                          ]),
                          span(classes: 'fw-bold text-danger fs-8', [Component.text('Rp ${p.price.toInt()}')]),
                        ],
                      ),
                    ),
                ],
                if (matchedOrders.isNotEmpty) ...[
                  div(classes: 'px-2 py-1 fs-8 fw-bold text-uppercase text-muted border-bottom mt-2 mb-1', [Component.text('Pesanan & Invoice')]),
                  for (var o in matchedOrders)
                    Link(
                      to: AdminRouteCrypto.pathFor('orders'),
                      child: a(
                        classes: 'dropdown-item py-1.5 px-2 rounded-2 d-flex align-items-center justify-content-between fs-7 text-dark',
                        href: AdminRouteCrypto.pathFor('orders'),
                        events: {'click': (e) => setState(() => headerSearchQuery = '')},
                        [
                          div(classes: 'd-flex align-items-center gap-2', [
                            i(classes: 'bi bi-receipt text-primary', []),
                            span(classes: 'fw-semibold', [Component.text(o.orderNo)]),
                          ]),
                          span(classes: 'badge bg-primary-subtle text-primary fs-8', [Component.text(o.customerName)]),
                        ],
                      ),
                    ),
                ],
                if (matchedCustomers.isNotEmpty) ...[
                  div(classes: 'px-2 py-1 fs-8 fw-bold text-uppercase text-muted border-bottom mt-2 mb-1', [Component.text('Pelanggan CRM')]),
                  for (var c in matchedCustomers)
                    Link(
                      to: AdminRouteCrypto.pathFor('customers'),
                      child: a(
                        classes: 'dropdown-item py-1.5 px-2 rounded-2 d-flex align-items-center justify-content-between fs-7 text-dark',
                        href: AdminRouteCrypto.pathFor('customers'),
                        events: {'click': (e) => setState(() => headerSearchQuery = '')},
                        [
                          div(classes: 'd-flex align-items-center gap-2', [
                            i(classes: 'bi bi-person text-success', []),
                            span(classes: 'fw-semibold', [Component.text(c.name)]),
                          ]),
                          small(classes: 'text-muted fs-8', [Component.text(c.phone)]),
                        ],
                      ),
                    ),
                ],
              ],
            ]),
        ]),

        // Right Navbar Icons
        ul(classes: 'navbar-nav ms-auto align-items-center gap-1', [

          // Sound Alert Notification Toggle Button
          li(classes: 'nav-item me-1', [
            button(
              type: ButtonType.button,
              classes: 'nav-link btn btn-link border-0 p-1 me-1 ${store.soundAlertEnabled ? 'text-primary' : 'text-muted'}',
              attributes: {
                'title': store.soundAlertEnabled ? 'Notifikasi Suara Pesanan: AKTIF' : 'Notifikasi Suara Pesanan: MATI'
              },
              events: {
                'click': (e) {
                  setState(() {
                    store.soundAlertEnabled = !store.soundAlertEnabled;
                    if (store.soundAlertEnabled) store.playNotificationChime();
                  });
                }
              },
              [
                i(classes: 'bi ${store.soundAlertEnabled ? 'bi-volume-up-fill fs-5' : 'bi-volume-mute-fill fs-5'}', []),
              ],
            ),
          ]),

          // Theme Toggle Switcher
          li(classes: 'nav-item dropdown me-1', [
            a(classes: 'nav-link dropdown-toggle d-flex align-items-center gap-1', href: '#', id: 'bd-theme', attributes: {'data-bs-toggle': 'dropdown'}, [
              i(classes: 'bi bi-sun-fill text-warning fs-5', []),
            ]),
            ul(classes: 'dropdown-menu dropdown-menu-end shadow-sm', [
              li([
                button(type: ButtonType.button, classes: 'dropdown-item d-flex align-items-center gap-2', attributes: {'data-bs-theme-value': 'light'}, [
                  i(classes: 'bi bi-sun-fill text-warning', []),
                  Component.text('Light Mode'),
                ]),
              ]),
              li([
                button(type: ButtonType.button, classes: 'dropdown-item d-flex align-items-center gap-2', attributes: {'data-bs-theme-value': 'dark'}, [
                  i(classes: 'bi bi-moon-fill text-primary', []),
                  Component.text('Dark Mode'),
                ]),
              ]),
            ]),
          ]),

          // Direct Chat Customer Support Sidebar Trigger
          li(classes: 'nav-item me-2', [
            button(
              type: ButtonType.button,
              classes: 'nav-link btn btn-link text-body position-relative border-0 p-1 me-1',
              attributes: {
                'data-bs-toggle': 'offcanvas',
                'data-bs-target': '#chatSidebar',
                'aria-controls': 'chatSidebar',
                'title': 'Buka Direct Chat Customer Support Sidebar',
              },
              [
                i(classes: 'bi bi-chat-dots-fill fs-5 text-primary', []),
                if (unreadChats > 0)
                  span(
                    classes: 'position-absolute badge rounded-circle bg-danger border border-light p-0 d-flex align-items-center justify-content-center',
                    styles: Styles(
                      position: Position.absolute(top: 2.px, right: 0.px),
                      width: 18.px,
                      height: 18.px,
                      fontSize: 10.px,
                    ),
                    [Component.text(unreadChats.toString())],
                  ),
              ],
            ),
          ]),

          // System Notifications
          li(classes: 'nav-item dropdown me-2', [
            a(classes: 'nav-link position-relative p-1 me-1', href: '#', attributes: {'data-bs-toggle': 'dropdown'}, [
              i(classes: 'bi bi-bell fs-5', []),
              span(
                classes: 'position-absolute badge rounded-circle bg-warning text-dark border border-light p-0 d-flex align-items-center justify-content-center',
                styles: Styles(
                  position: Position.absolute(top: 2.px, right: 0.px),
                  width: 18.px,
                  height: 18.px,
                  fontSize: 10.px,
                ),
                [Component.text('5')],
              ),
            ]),
            ul(classes: 'dropdown-menu dropdown-menu-lg dropdown-menu-end shadow p-0', [
              li(classes: 'dropdown-header bg-light fw-bold text-dark py-2 px-3 border-bottom', [
                Component.text('Notifikasi Aktivitas Toko'),
              ]),
              li([
                Link(
                  to: AdminRouteCrypto.pathFor('orders'),
                  child: a(classes: 'dropdown-item py-2 px-3 border-bottom d-flex align-items-center justify-content-between', href: AdminRouteCrypto.pathFor('orders'), [
                    div(classes: 'd-flex align-items-center gap-2', [
                      i(classes: 'bi bi-cart-check text-primary fs-5', []),
                      span(classes: 'fs-7 text-dark fw-medium', [Component.text('Pesanan Baru Masuk')]),
                    ]),
                    small(classes: 'text-muted fs-7', [Component.text('Baru saja')]),
                  ]),
                ),
              ]),
            ]),
          ]),

          // Admin Profile Menu Dropdown
          li(classes: 'nav-item dropdown user-menu', [
            a(classes: 'nav-link dropdown-toggle d-flex align-items-center gap-2', href: '#', attributes: {'data-bs-toggle': 'dropdown'}, [
              div(
                classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7',
                styles: Styles(width: 32.px, height: 32.px),
                [Component.text(initial)],
              ),
              span(classes: 'd-none d-md-inline fw-semibold', [Component.text(user?.name ?? 'Admin')]),
            ]),
            ul(classes: 'dropdown-menu dropdown-menu-lg dropdown-menu-end shadow-sm p-3', [
              li(classes: 'text-center border-bottom pb-3 mb-2', [
                div(
                  classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold mx-auto mb-2 display-6',
                  styles: Styles(width: 50.px, height: 50.px),
                  [Component.text(initial)],
                ),
                h6(classes: 'fw-bold text-dark mb-0', [Component.text(user?.name ?? 'Admin')]),
                small(classes: 'badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill mt-1', [
                  Component.text(user?.role ?? 'Super Admin'),
                ]),
              ]),
              li([
                Link(
                  to: AdminRouteCrypto.pathFor('profile'),
                  child: a(classes: 'dropdown-item py-2 d-flex align-items-center gap-2', href: AdminRouteCrypto.pathFor('profile'), [
                    i(classes: 'bi bi-person-circle text-primary', []),
                    Component.text('Lihat Profil Lengkap'),
                  ]),
                ),
              ]),
              li([
                Link(
                  to: AdminRouteCrypto.pathFor('settings'),
                  child: a(classes: 'dropdown-item py-2 d-flex align-items-center gap-2', href: AdminRouteCrypto.pathFor('settings'), [
                    i(classes: 'bi bi-gear text-secondary', []),
                    Component.text('Pengaturan Toko'),
                  ]),
                ),
              ]),
              li([hr(classes: 'dropdown-divider')]),
              li([
                button(
                  type: ButtonType.button,
                  classes: 'dropdown-item py-2 text-danger d-flex align-items-center gap-2 w-100 border-0 bg-transparent',
                  events: {'click': (e) => _handleLogout()},
                  [
                    i(classes: 'bi bi-box-arrow-right', []),
                    Component.text('Keluar / Sign Out'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildSidebar(BuildContext context) {
    final currentPath = RouteState.of(context).location;

    return aside(
      classes: 'app-sidebar bg-dark shadow',
      attributes: {'data-bs-theme': 'dark'},
      [
        // Brand Header
        div(classes: 'sidebar-brand border-bottom border-secondary', [
          Link(
            to: AdminRouteCrypto.pathFor('dashboard'),
            child: a(classes: 'brand-link d-flex align-items-center text-decoration-none px-3 py-2', href: AdminRouteCrypto.pathFor('dashboard'), [
              i(classes: 'bi bi-shop brand-image fs-3 me-2 text-warning', []),
              span(classes: 'brand-text fw-bold text-white fs-5', [Component.text('E-COMES ')]),
              span(classes: 'text-warning fs-6 ms-1', [Component.text('v4.9')]),
            ]),
          ),
        ]),

        // Sidebar Navigation Links
        div(classes: 'sidebar-wrapper px-2 py-3 overflow-y-auto', [
          _buildUserRoleHeader(AuthService().currentUser),
          nav(classes: 'mt-2', [
            ul(
              classes: 'nav nav-pills nav-sidebar flex-column gap-1',
              attributes: {'data-lte-toggle': 'treeview', 'role': 'menu'},
              [
                li(classes: 'nav-header text-uppercase text-secondary fw-bold fs-7 px-3 mt-2 mb-1', [
                  Component.text('UTAMA & OPERASIONAL'),
                ]),
                _buildNavItem(AdminRouteCrypto.pathFor('dashboard'), 'Dashboard V1', 'bi-speedometer2', AdminRouteCrypto.isPageActive(currentPath, 'dashboard')),
                _buildNavItem('/', 'Lihat Toko (Storefront)', 'bi-shop', currentPath == '/' || currentPath == '/ecomes', badgeText: 'Live', badgeClass: 'bg-success'),
                _buildNavItem(AdminRouteCrypto.pathFor('landing'), 'Manajemen Landing Page', 'bi-window-stack', AdminRouteCrypto.isPageActive(currentPath, 'landing'), badgeText: 'CMS', badgeClass: 'bg-danger'),
                _buildNavItem(AdminRouteCrypto.pathFor('products'), 'Katalog & Stok', 'bi-box-seam', AdminRouteCrypto.isPageActive(currentPath, 'products'), badgeText: 'Hot'),
                _buildNavItem(AdminRouteCrypto.pathFor('orders'), 'Pesanan Toko', 'bi-cart-check', AdminRouteCrypto.isPageActive(currentPath, 'orders'), badgeText: 'Dinamis', badgeClass: 'bg-primary'),

                li(classes: 'nav-header text-uppercase text-secondary fw-bold fs-7 px-3 mt-3 mb-1', [
                  Component.text('PELANGGAN & PEMASARAN'),
                ]),
                _buildNavItem(AdminRouteCrypto.pathFor('customers'), 'Pelanggan (CRM)', 'bi-people', AdminRouteCrypto.isPageActive(currentPath, 'customers')),
                _buildNavItem(AdminRouteCrypto.pathFor('categories'), 'Kategori & Brand', 'bi-grid-3x3-gap', AdminRouteCrypto.isPageActive(currentPath, 'categories')),
                _buildNavItem(AdminRouteCrypto.pathFor('promos'), 'Kupon & Diskon', 'bi-ticket-perforated', AdminRouteCrypto.isPageActive(currentPath, 'promos')),
                _buildNavItem(AdminRouteCrypto.pathFor('reviews'), 'Ulasan & Rating', 'bi-star-half', AdminRouteCrypto.isPageActive(currentPath, 'reviews')),

                li(classes: 'nav-header text-uppercase text-secondary fw-bold fs-7 px-3 mt-3 mb-1', [
                  Component.text('LAYANAN & LAPORAN'),
                ]),
                _buildNavItem(AdminRouteCrypto.pathFor('chat'), 'Live Chat Support', 'bi-chat-dots', AdminRouteCrypto.isPageActive(currentPath, 'chat'), badgeText: 'Live', badgeClass: 'bg-danger'),
                _buildNavItem(AdminRouteCrypto.pathFor('invoice'), 'Cetak Invoice', 'bi-receipt', AdminRouteCrypto.isPageActive(currentPath, 'invoice')),
                _buildNavItem(AdminRouteCrypto.pathFor('reports'), 'Laporan Penjualan', 'bi-bar-chart-line', AdminRouteCrypto.isPageActive(currentPath, 'reports')),

                li(classes: 'nav-header text-uppercase text-secondary fw-bold fs-7 px-3 mt-3 mb-1', [
                  Component.text('SISTEM & KONFIGURASI'),
                ]),
                _buildNavItem(AdminRouteCrypto.pathFor('settings'), 'Pengaturan Toko', 'bi-gear', AdminRouteCrypto.isPageActive(currentPath, 'settings')),
                _buildNavItem(AdminRouteCrypto.pathFor('profile'), 'Profil Admin', 'bi-person', AdminRouteCrypto.isPageActive(currentPath, 'profile')),
                _buildNavItem(AdminRouteCrypto.pathFor('about'), 'Tentang Aplikasi', 'bi-info-circle', AdminRouteCrypto.isPageActive(currentPath, 'about')),
              ],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildNavItem(String path, String label, String icon, bool isActive, {String? badgeText, String badgeClass = 'bg-danger'}) {
    return li(classes: 'nav-item', [
      Link(
        to: path,
        child: a(
          classes: 'nav-link d-flex align-items-center justify-content-between px-3 py-2 rounded-2 ${isActive ? 'active bg-primary text-white fw-bold shadow-sm' : 'text-body-emphasis'}',
          href: path,
          events: {
            'click': (e) {
              if ((html.window.innerWidth ?? 1000) < 992) {
                html.document.body?.classes.remove('sidebar-open');
                html.document.body?.classes.add('sidebar-collapse');
              }
            }
          },
          [
            div(classes: 'd-flex align-items-center gap-2', [
              i(classes: 'bi $icon fs-6 ${isActive ? 'text-white' : 'text-primary'}', []),
              span(classes: 'fs-7', [Component.text(label)]),
            ]),
            if (badgeText != null)
              span(classes: 'badge $badgeClass rounded-pill fs-8', [
                Component.text(badgeText),
              ]),
          ],
        ),
      ),
    ]);
  }

  Component _buildDirectChatRightSidebar() {
    final store = AppStore();

    return div(
      classes: 'offcanvas offcanvas-end shadow-lg border-0',
      attributes: {
        'tabindex': '-1',
        'id': 'chatSidebar',
        'aria-labelledby': 'chatSidebarLabel',
        'style': 'width: 380px; max-width: 90vw;',
        'data-bs-scroll': 'true',
        'data-bs-backdrop': 'true',
      },
      [
        div(classes: 'offcanvas-header bg-primary text-white p-3', [
          div(classes: 'd-flex align-items-center gap-2', [
            i(classes: 'bi bi-chat-dots-fill fs-4', []),
            div([
              h5(classes: 'offcanvas-title mb-0 fw-bold fs-6', id: 'chatSidebarLabel', [Component.text('Live Chat Customer Support')]),
              small(classes: 'text-white-50 fs-8', [Component.text('Percakapan langsung pembeli')]),
            ]),
          ]),
          button(
            type: ButtonType.button,
            classes: 'btn-close btn-close-white',
            attributes: {'data-bs-dismiss': 'offcanvas', 'aria-label': 'Close'},
            [],
          ),
        ]),
        div(classes: 'offcanvas-body p-3 d-flex flex-column justify-content-between bg-light', [
          div(classes: 'chat-history flex-grow-1 overflow-y-auto mb-3 pe-1', [
            if (store.chatMessages.isEmpty)
              p(classes: 'text-muted text-center py-4 fs-7', [Component.text('Belum ada riwayat pesan.')])
            else
              for (var msg in store.chatMessages)
                div(classes: 'mb-3 d-flex flex-column ${msg.isAdmin ? 'align-items-end' : 'align-items-start'}', [
                  div(classes: 'd-flex align-items-center gap-1 mb-1', [
                    span(classes: 'fw-bold fs-8 text-dark', [Component.text(msg.sender)]),
                    span(classes: 'text-muted fs-8', [Component.text('• ${msg.time}')]),
                  ]),
                  div(
                    classes: 'p-2 rounded-3 fs-7 ${msg.isAdmin ? 'bg-primary text-white' : 'bg-white text-dark shadow-sm border'}',
                    styles: Styles(maxWidth: 80.percent),
                    [Component.text(msg.text)],
                  ),
                ]),
          ]),
          div(classes: 'chat-input-box bg-white p-2 rounded-3 border shadow-sm', [
            form(
              events: {
                'submit': (e) {
                  e.preventDefault();
                  _sendQuickChat();
                }
              },
              [
                div(classes: 'input-group input-group-sm', [
                  input(
                    type: InputType.text,
                    classes: 'form-control border-0',
                    value: quickMessage,
                    attributes: {'placeholder': 'Ketik pesan balasan...'},
                    events: {
                      'input': (e) {
                        quickMessage = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                  button(type: ButtonType.submit, classes: 'btn btn-primary px-3', [
                    i(classes: 'bi bi-send-fill me-1', []),
                    Component.text('Kirim'),
                  ]),
                ]),
              ],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildFooter() {
    return footer(classes: 'app-footer bg-body border-top p-3 text-muted fs-7', [
      div(classes: 'container-fluid d-flex flex-wrap justify-content-between align-items-center gap-2', [
        div([
          strong([Component.text('Hak Cipta © 2026 ')]),
          a(href: 'https://adminlte.io', classes: 'text-primary text-decoration-none fw-semibold', [Component.text('E-Comes Admin Panel')]),
          Component.text('. Seluruh Hak Dilindungi.'),
        ]),
        div(classes: 'd-none d-sm-inline-block', [
          strong([Component.text('Versi ')]),
          Component.text('4.9.1 (Enterprise Production)'),
        ]),
      ]),
    ]);
  }

  Component _buildUserRoleHeader(UserSession? user) {
    final role = user?.role ?? 'Super Admin';
    final roleBadgeColor = role == 'Super Admin'
        ? 'bg-danger text-white'
        : role == 'Store Manager'
            ? 'bg-success text-white'
            : 'bg-info text-dark';

    return div(classes: 'px-3 py-2 mb-2 border-bottom border-secondary d-flex align-items-center gap-2 bg-dark-subtle rounded-3 mx-1', [
      div(classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7 shadow-sm', styles: Styles(width: 32.px, height: 32.px), [
        Component.text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A'),
      ]),
      div(classes: 'flex-grow-1 overflow-hidden', [
        div(classes: 'fw-bold text-white fs-7 text-truncate', [Component.text(user?.name ?? 'Admin Toko')]),
        span(classes: 'badge $roleBadgeColor fs-8 fw-bold', [Component.text(role)]),
      ]),
    ]);
  }
}

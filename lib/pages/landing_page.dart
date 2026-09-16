// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class LandingPage extends StatefulComponent {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String activeCategory = 'Semua';
  String searchQuery = '';
  String sortBy = 'terpopuler'; // 'terpopuler', 'termurah', 'termahal'
  List<Map<String, dynamic>> cartItems = [];
  bool showCartModal = false;
  bool showSuccessToast = false;
  bool isFullStoreMode = false; // Mode Storefront E-Commerce vs Landing Page

  // Product Detail Modal State
  Map<String, dynamic>? selectedProductDetail;
  bool showProductDetailModal = false;

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final existingIndex = cartItems.indexWhere((element) => element['id'] == item['id']);
      if (existingIndex >= 0) {
        cartItems[existingIndex]['qty'] += 1;
      } else {
        cartItems.add({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'image': item['image'],
          'qty': 1,
        });
      }
      showCartModal = true;
    });
  }

  void _updateCartQty(int index, int delta) {
    setState(() {
      cartItems[index]['qty'] += delta;
      if (cartItems[index]['qty'] <= 0) {
        cartItems.removeAt(index);
      }
    });
  }

  void _openProductDetail(Map<String, dynamic> item) {
    setState(() {
      selectedProductDetail = item;
      showProductDetailModal = true;
    });
  }

  void _checkoutWhatsApp() {
    if (cartItems.isEmpty) return;
    double total = 0;
    String itemSummary = '';
    List<OrderProductItem> orderItemsList = [];

    for (var item in cartItems) {
      final itemTotal = (item['price'] as int) * (item['qty'] as int);
      total += itemTotal;
      itemSummary += '- ${item['name']} x${item['qty']} (Rp ${itemTotal.toInt()})\n';

      orderItemsList.add(OrderProductItem(
        productName: item['name'].toString(),
        qty: item['qty'] as int,
        price: (item['price'] as int).toDouble(),
      ));
    }

    final now = DateTime.now();
    final orderId = 'ORD-RJT-${now.millisecondsSinceEpoch.toString().substring(6)}';
    final orderNo = 'INV/${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}/RJT/${now.millisecondsSinceEpoch.toString().substring(8)}';

    // Sync Order to Admin Panel
    final newOrder = OrderItem(
      id: orderId,
      orderNo: orderNo,
      customerName: 'Pelanggan Toko Rajutan',
      customerPhone: '081234567890',
      date: '${now.day} Sep ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      total: total,
      courier: 'JNE Reguler (Rajutan)',
      status: 'Pending',
      paymentMethod: 'WhatsApp Store',
      items: orderItemsList,
    );

    AppStore().addOrder(newOrder);

    final config = AppStore().landingConfig;
    final message = Uri.encodeComponent(
      'Halo ${config.storeName}, saya mau order pesanan rajutan berikut (No Ref: $orderNo):\n\n'
      '$itemSummary\n'
      '*Total Belanja: Rp ${total.toInt()}*\n\n'
      'Mohon diinfokan rekening pembayaran dan estimasi pengerjaan ya kak. Terima kasih! 🧶🧸',
    );

    html.window.open('https://wa.me/${config.whatsappNumber}?text=$message', '_blank');

    setState(() {
      cartItems.clear();
      showCartModal = false;
      showSuccessToast = true;
    });
  }

  void _orderDirectWhatsApp(Map<String, dynamic> item) {
    final now = DateTime.now();
    final orderId = 'ORD-RJT-${now.millisecondsSinceEpoch.toString().substring(6)}';
    final orderNo = 'INV/${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}/RJT/${now.millisecondsSinceEpoch.toString().substring(8)}';

    // Sync Single Order to Admin Panel
    final newOrder = OrderItem(
      id: orderId,
      orderNo: orderNo,
      customerName: 'Pelanggan Toko Rajutan',
      customerPhone: '081234567890',
      date: '${now.day} Sep ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      total: (item['price'] as int).toDouble(),
      courier: 'JNE Reguler (Rajutan)',
      status: 'Pending',
      paymentMethod: 'WhatsApp Store',
      items: [
        OrderProductItem(
          productName: item['name'].toString(),
          qty: 1,
          price: (item['price'] as int).toDouble(),
        ),
      ],
    );

    AppStore().addOrder(newOrder);

    final config = AppStore().landingConfig;
    final message = Uri.encodeComponent(
      'Halo Kak, saya berminat memesan *${item['name']}* (Harga: Rp ${item['price']}). No Ref: $orderNo. Apakah stok/slot pengerjaan ready kak? 🧶🧸',
    );
    html.window.open('https://wa.me/${config.whatsappNumber}?text=$message', '_blank');

    setState(() {
      showSuccessToast = true;
    });
  }

  @override
  Component build(BuildContext context) {
    final storeProducts = AppStore().products;
    final landingProductsList = storeProducts.map((prod) => {
      'id': prod.id,
      'name': prod.name,
      'category': prod.category,
      'price': prod.price.toInt(),
      'rating': 5,
      'sold': 120,
      'image': prod.image,
      'description': prod.description,
      'badge': prod.status == 'Aktif' ? 'Handmade 🧶' : prod.status,
    }).toList();

    // Filter by Category & Search Query
    List<Map<String, dynamic>> filteredProducts = landingProductsList.where((item) {
      final matchesCategory = activeCategory == 'Semua' || item['category'] == activeCategory;
      final matchesSearch = item['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          item['category'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Sort Products
    if (sortBy == 'termurah') {
      filteredProducts.sort((itemA, itemB) => (itemA['price'] as int).compareTo(itemB['price'] as int));
    } else if (sortBy == 'termahal') {
      filteredProducts.sort((itemA, itemB) => (itemB['price'] as int).compareTo(itemA['price'] as int));
    }

    int totalCartCount = cartItems.fold<int>(0, (sum, item) => sum + (item['qty'] as int));

    return div(classes: 'landing-page-wrapper bg-light font-sans-serif min-vh-100', [
      // 1. Storefront Top Navbar
      _buildStorefrontNavbar(totalCartCount),

      // Toast Notification for Admin Sync Feedback
      if (showSuccessToast)
        div(classes: 'container my-2', [
          div(classes: 'alert alert-success alert-dismissible fade show rounded-3 shadow-sm d-flex align-items-center gap-2 mb-0 py-2', attributes: {'role': 'alert'}, [
            i(classes: 'bi bi-check-circle-fill text-success fs-5', []),
            div(classes: 'flex-grow-1 fs-7 fw-semibold', [
              Component.text('Pesanan berhasil disimpan ke Sistem Admin Panel (Kelola Pesanan) & diteruskan ke WhatsApp!'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close py-2',
              events: {'click': (e) => setState(() => showSuccessToast = false)},
              [],
            ),
          ]),
        ]),

      // IF FULL STOREFRONT MODE IS ACTIVE:
      if (isFullStoreMode) ...[
        _buildFullStorefrontCatalog(filteredProducts),
      ] else ...[
        // NORMAL LANDING PAGE MODE (Hero + 1 Row Products Showcase + Store Button + Custom Order + Testimonials)
        _buildHeroSection(),
        _buildCategorySection(),
        _buildProductsOneRowShowcase(filteredProducts),
        _buildCustomOrderSection(),
        _buildFeaturesSection(),
        _buildTestimonialsSection(),
      ],

      // Footer Section
      _buildStorefrontFooter(),

      // Interactive Shopping Cart Modal
      if (showCartModal) _buildCartModal(),

      // Product Detail Quick View Modal
      if (showProductDetailModal && selectedProductDetail != null) _buildProductDetailModal(),
    ]);
  }

  Component _buildStorefrontNavbar(int totalCartCount) {
    final config = AppStore().landingConfig;
    return nav(classes: 'navbar navbar-light bg-white shadow-sm sticky-top py-2 border-bottom text-nowrap', [
      div(classes: 'container-fluid px-lg-4 d-flex align-items-center justify-content-between flex-nowrap gap-2 overflow-x-auto', [
        // Brand Logo
        Link(
          to: '/landing',
          child: a(classes: 'navbar-brand d-flex align-items-center gap-2 fw-bold text-dark fs-6 text-nowrap me-2', href: '/landing', [
            span(classes: 'bg-danger text-white rounded-circle d-flex align-items-center justify-content-center shadow-sm flex-shrink-0', styles: Styles(width: 32.px, height: 32.px), [
              Component.text('🧶'),
            ]),
            span(classes: 'text-primary fw-extrabold fs-6 text-nowrap', [Component.text(config.storeName)]),
            span(classes: 'badge bg-danger-subtle text-danger fs-8 fw-semibold text-nowrap d-none d-sm-inline-block', [Component.text(config.storeTagline)]),
          ]),
        ),

        // Nav Links
        ul(classes: 'navbar-nav flex-row flex-nowrap gap-2 gap-lg-3 fw-semibold fs-7 text-nowrap mb-0 mx-auto', [
          li(classes: 'nav-item', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-link nav-link ${!isFullStoreMode ? 'text-danger fw-bold' : 'text-dark'} py-1 px-2 text-decoration-none',
              events: {'click': (e) => setState(() => isFullStoreMode = false)},
              [Component.text('Beranda')],
            ),
          ]),
          li(classes: 'nav-item', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-link nav-link ${isFullStoreMode ? 'text-danger fw-bold' : 'text-dark'} py-1 px-2 text-decoration-none',
              events: {'click': (e) => setState(() => isFullStoreMode = true)},
              [
                Component.text('Katalog Store 🛒'),
              ],
            ),
          ]),
          li(classes: 'nav-item', [a(classes: 'nav-link text-dark py-1 px-2', href: '#custom', [Component.text('Custom 🎨')]),]),
          li(classes: 'nav-item', [a(classes: 'nav-link text-dark py-1 px-2', href: '#testimoni', [Component.text('Ulasan')]),]),
        ]),

        // Quick Actions
        div(classes: 'd-flex align-items-center gap-2 flex-nowrap text-nowrap flex-shrink-0', [
          button(
            type: ButtonType.button,
            classes: 'btn btn-outline-danger position-relative rounded-pill px-3 py-1 fs-7 fw-semibold shadow-sm text-nowrap d-flex align-items-center gap-1',
            events: {'click': (e) => setState(() => showCartModal = true)},
            [
              i(classes: 'bi bi-cart3 me-1', []),
              Component.text('Keranjang'),
              if (totalCartCount > 0)
                span(classes: 'badge rounded-pill bg-danger shadow-sm ms-1', [
                  Component.text(totalCartCount.toString()),
                ]),
            ],
          ),
        ]),
      ]),
    ]);
  }

  Component _buildHeroSection() {
    final config = AppStore().landingConfig;
    return div(
      classes: 'hero-section py-5 hero-gradient-bg text-dark position-relative overflow-hidden',
      [
        div(classes: 'container py-4', [
          div(classes: 'row align-items-center g-5', [
            div(classes: 'col-lg-6', [
              span(classes: 'badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3 py-2 fs-7 fw-bold mb-3 shadow-sm d-inline-flex align-items-center gap-1 badge-glow animate-pulse-subtle', [
                i(classes: 'bi bi-heart-fill me-1', []),
                Component.text(config.heroBadge),
              ]),
              h1(classes: 'display-5 fw-extrabold text-dark mb-3 lh-sm', [
                Component.text(config.heroHeadlinePrefix),
                span(classes: 'text-gradient-danger', [Component.text(config.heroHeadlineHighlight)]),
              ]),
              p(classes: 'lead text-muted mb-4 fs-6', [
                Component.text(config.heroDescription),
              ]),
              div(classes: 'd-flex flex-wrap align-items-center gap-3 mb-4', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-danger btn-lg rounded-pill px-4 py-2 fs-6 fw-bold shadow-sm d-inline-flex align-items-center gap-2 product-card-hover',
                  events: {'click': (e) => setState(() => isFullStoreMode = true)},
                  [
                    i(classes: 'bi bi-bag-heart-fill', []),
                    Component.text('Buka Toko E-Commerce 🛒'),
                  ],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-outline-success btn-lg rounded-pill px-4 py-2 fs-6 fw-bold shadow-sm d-inline-flex align-items-center gap-2',
                  events: {
                    'click': (e) {
                      html.window.open('https://wa.me/${config.whatsappNumber}?text=Halo%20${config.storeName},%20saya%20mau%20konsultasi%20order%20custom%20rajutan%20dan%20boneka', '_blank');
                    }
                  },
                  [
                    i(classes: 'bi bi-whatsapp', []),
                    Component.text('Custom Via WA'),
                  ],
                ),
              ]),
              div(classes: 'row g-3 text-dark pt-3 border-top', [
                div(classes: 'col-4', [
                  h4(classes: 'fw-bold mb-0 text-danger', [Component.text('1.2k+')]),
                  small(classes: 'text-muted fs-8', [Component.text('Boneka Terjual')]),
                ]),
                div(classes: 'col-4', [
                  h4(classes: 'fw-bold mb-0 text-danger', [Component.text('5.0 ⭐')]),
                  small(classes: 'text-muted fs-8', [Component.text('Rating Ulasan')]),
                ]),
                div(classes: 'col-4', [
                  h4(classes: 'fw-bold mb-0 text-danger', [Component.text('Free 🎁')]),
                  small(classes: 'text-muted fs-8', [Component.text('Gift Box & Card')]),
                ]),
              ]),
            ]),
            div(classes: 'col-lg-6 text-center', [
              div(classes: 'position-relative d-inline-block', [
                img(
                  src: config.heroImage,
                  classes: 'img-fluid rounded-4 shadow-lg border border-4 border-white object-fit-cover animate-float',
                  styles: Styles(maxHeight: 420.px),
                  attributes: {'alt': 'Hero Showcase'},
                ),
                div(
                  classes: 'position-absolute bottom-0 start-0 translate-middle-y bg-white p-3 rounded-4 shadow-lg border text-start d-none d-sm-flex align-items-center gap-3 ms-n3',
                  styles: Styles(maxWidth: 260.px),
                  [
                    span(classes: 'fs-1', [Component.text('🧸')]),
                    div([
                      div(classes: 'fw-bold fs-7 text-dark', [Component.text('Amigurumi Bear')]),
                      small(classes: 'text-muted fs-8', [Component.text('Super Soft & Cute')]),
                      div(classes: 'text-warning fs-8', [Component.text('★★★★★ 5.0')]),
                    ]),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildCategorySection() {
    final categories = [
      {'name': 'Semua', 'icon': 'bi-grid-fill'},
      {'name': 'Tas Rajut', 'icon': 'bi-bag-heart-fill'},
      {'name': 'Cup Holder & Sleeve', 'icon': 'bi-cup-hot-fill'},
      {'name': 'Gantungan Kunci', 'icon': 'bi-key-fill'},
      {'name': 'Pouch & Organiser', 'icon': 'bi-box-seam-fill'},
    ];

    return div(classes: 'container py-4', id: 'katalog', [
      div(classes: 'text-center mb-4', [
        h2(classes: 'fw-bold text-dark mb-1', [Component.text("Koleksi Kerajinan Rajut Abel'z Handmade")]),
        p(classes: 'text-muted fs-7', [Component.text('100% Handcrafted by Yayuk Wahyuni (@yayukwahyuni26) - Custom PO & Ready Stock')]),
      ]),
      div(classes: 'd-flex flex-wrap justify-content-center gap-2 mb-4', [
        for (var cat in categories)
          button(
            type: ButtonType.button,
            classes: 'btn rounded-pill px-4 py-2 fs-7 fw-semibold transition-all ${activeCategory == cat['name'] ? 'btn-danger text-white shadow' : 'btn-light text-dark border'}',
            events: {'click': (e) => setState(() => activeCategory = cat['name'] as String)},
            [
              i(classes: 'bi ${cat['icon']} me-2', []),
              Component.text(cat['name'] as String),
            ],
          ),
      ]),
    ]);
  }

  // Showcase ON LANDING PAGE: STRICTLY 1 ROW ONLY OF PRODUCTS + "SEE ALL" BUTTON!
  Component _buildProductsOneRowShowcase(List<Map<String, dynamic>> items) {
    // Take maximum 4 items for 1 row layout on desktop grid
    final oneRowItems = items.take(4).toList();

    return div(classes: 'container mb-5', [
      if (oneRowItems.isEmpty)
        div(classes: 'text-center py-5 bg-white rounded-4 shadow-sm border p-4', [
          i(classes: 'bi bi-search fs-1 text-muted mb-2 d-block', []),
          h5(classes: 'fw-bold text-dark', [Component.text('Produk Tidak Ditemukan')]),
          p(classes: 'text-muted fs-7 mb-0', [Component.text('Coba cari dengan kata kunci lain atau pilih kategori Semua.')]),
        ])
      else ...[
        // Single Row Grid (Col-lg-3 for 4 items per row)
        div(classes: 'row g-4 mb-4', [
          for (var item in oneRowItems)
            div(classes: 'col-sm-6 col-lg-3', [
              div(classes: 'card h-100 border-0 shadow-sm rounded-4 overflow-hidden position-relative product-card-hover bg-white', [
                // Badge
                span(classes: 'position-absolute top-0 end-0 m-2 badge bg-danger text-white rounded-pill px-2 py-1 fs-8 fw-bold shadow', [
                  Component.text(item['badge'].toString()),
                ]),
                // Product Image
                div(
                  classes: 'position-relative overflow-hidden bg-light text-center p-2 cursor-pointer',
                  events: {'click': (e) => _openProductDetail(item)},
                  [
                    img(
                      src: item['image'].toString(),
                      classes: 'img-fluid rounded-3 object-fit-cover w-100',
                      styles: Styles(height: 180.px),
                      attributes: {'alt': item['name'].toString()},
                    ),
                  ],
                ),
                // Card Body
                div(classes: 'card-body p-3 d-flex flex-column justify-content-between', [
                  div([
                    span(classes: 'badge bg-danger-subtle text-danger rounded-pill fs-8 fw-semibold mb-1', [
                      Component.text(item['category'].toString()),
                    ]),
                    h6(
                      classes: 'fw-bold text-dark fs-7 mb-1 line-clamp-2 cursor-pointer',
                      events: {'click': (e) => _openProductDetail(item)},
                      [Component.text(item['name'].toString())],
                    ),
                  ]),
                  div([
                    div(classes: 'd-flex align-items-center justify-content-between my-2', [
                      span(classes: 'fw-extrabold fs-6 text-danger', [
                        Component.text('Rp ${(item['price'] as int).toString()}'),
                      ]),
                      span(classes: 'text-warning fs-8 fw-bold', [
                        Component.text('★ 5.0'),
                      ]),
                    ]),
                    div(classes: 'row g-1', [
                      div(classes: 'col-6', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-outline-danger btn-sm w-100 rounded-pill fw-bold py-1 fs-8',
                          events: {'click': (e) => _addToCart(item)},
                          [Component.text('+ Keranjang')],
                        ),
                      ]),
                      div(classes: 'col-6', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-success btn-sm w-100 rounded-pill fw-bold py-1 fs-8',
                          events: {'click': (e) => _orderDirectWhatsApp(item)},
                          [Component.text('Beli WA')],
                        ),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]),
        ]),

        // Banner Button to Open Full E-Commerce Storefront
        div(classes: 'text-center pt-2', [
          button(
            type: ButtonType.button,
            classes: 'btn btn-danger btn-lg rounded-pill px-5 py-3 fw-extrabold shadow-lg d-inline-flex align-items-center gap-3 border border-3 border-white product-card-hover',
            events: {'click': (e) => setState(() => isFullStoreMode = true)},
            [
              i(classes: 'bi bi-grid-3x3-gap-fill fs-4', []),
              Component.text('Lihat Semua Katalog Store E-Commerce (${items.length} Produk Lengkap)'),
              i(classes: 'bi bi-arrow-right-circle-fill fs-4', []),
            ],
          ),
        ]),
      ],
    ]);
  }

  // FULL E-COMMERCE STOREFRONT VIEW PAGE
  Component _buildFullStorefrontCatalog(List<Map<String, dynamic>> items) {
    final config = AppStore().landingConfig;

    return div(classes: 'container py-4 my-2', [
      // Store Header Banner
      div(classes: 'card border-0 shadow-sm rounded-4 overflow-hidden bg-white mb-4 p-4', [
        div(classes: 'row align-items-center g-3', [
          div(classes: 'col-md-8', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-outline-secondary rounded-pill btn-sm mb-2 fw-semibold d-inline-flex align-items-center gap-1',
              events: {'click': (e) => setState(() => isFullStoreMode = false)},
              [
                i(classes: 'bi bi-arrow-left', []),
                Component.text('Kembali ke Landing Page Utama'),
              ],
            ),
            h3(classes: 'fw-extrabold text-dark mb-1 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-shop text-danger', []),
              Component.text('Toko E-Commerce ${config.storeName}'),
            ]),
            p(classes: 'text-muted fs-7 mb-0', [
              Component.text('Semua produk rajutan, boneka amigurumi, syal, dan aksesoris handmade siap dikirim.'),
            ]),
          ]),
          div(classes: 'col-md-4 text-md-end', [
            span(classes: 'badge bg-danger px-3 py-2 rounded-pill fs-7 fw-bold shadow-sm', [
              Component.text('Total ${items.length} Barang Tersedia'),
            ]),
          ]),
        ]),
      ]),

      // Search & Sorting Controls
      div(classes: 'card border-0 shadow-sm rounded-4 mb-4 p-3 bg-white', [
        div(classes: 'row g-3 align-items-center', [
          div(classes: 'col-md-6', [
            div(classes: 'input-group rounded-pill overflow-hidden border', [
              span(classes: 'input-group-text bg-white border-0 ps-3', [i(classes: 'bi bi-search text-muted', [])]),
              input(
                type: InputType.text,
                classes: 'form-control border-0 py-2 fs-7',
                value: searchQuery,
                attributes: {'placeholder': 'Cari nama produk, kategori, atau deskripsi...'},
                events: {
                  'input': (e) {
                    setState(() {
                      searchQuery = (e.target as html.InputElement).value ?? '';
                    });
                  }
                },
              ),
            ]),
          ]),
          div(classes: 'col-md-3', [
            select(
              classes: 'form-select rounded-pill fs-7 border',
              events: {'change': (e) => setState(() => activeCategory = (e.target as html.SelectElement).value ?? 'Semua')},
              [
                option(value: 'Semua', selected: activeCategory == 'Semua', [Component.text('Semua Kategori')]),
                option(value: 'Tas Rajut', selected: activeCategory == 'Tas Rajut', [Component.text('Tas Rajut')]),
                option(value: 'Cup Holder & Sleeve', selected: activeCategory == 'Cup Holder & Sleeve', [Component.text('Cup Holder & Sleeve')]),
                option(value: 'Gantungan Kunci', selected: activeCategory == 'Gantungan Kunci', [Component.text('Gantungan Kunci')]),
                option(value: 'Pouch & Organiser', selected: activeCategory == 'Pouch & Organiser', [Component.text('Pouch & Organiser')]),
              ],
            ),
          ]),
          div(classes: 'col-md-3', [
            select(
              classes: 'form-select rounded-pill fs-7 border',
              events: {'change': (e) => setState(() => sortBy = (e.target as html.SelectElement).value ?? 'terpopuler')},
              [
                option(value: 'terpopuler', selected: sortBy == 'terpopuler', [Component.text('Urutkan: Terpopuler')]),
                option(value: 'termurah', selected: sortBy == 'termurah', [Component.text('Harga: Rendah ke Tinggi')]),
                option(value: 'termahal', selected: sortBy == 'termahal', [Component.text('Harga: Tinggi ke Rendah')]),
              ],
            ),
          ]),
        ]),
      ]),

      // Full Products Grid Showcase
      if (items.isEmpty)
        div(classes: 'text-center py-5 bg-white rounded-4 shadow-sm border p-4 my-4', [
          i(classes: 'bi bi-emoji-frown fs-1 text-muted mb-2 d-block', []),
          h5(classes: 'fw-bold text-dark', [Component.text('Produk Tidak Ditemukan')]),
          p(classes: 'text-muted fs-7 mb-0', [Component.text('Coba atur ulang kata kunci pencarian atau kategori Anda.')]),
        ])
      else
        div(classes: 'row g-4 mb-5', [
          for (var item in items)
            div(classes: 'col-sm-6 col-md-4 col-lg-3', [
              div(classes: 'card h-100 border-0 shadow-sm rounded-4 overflow-hidden position-relative product-card-hover bg-white', [
                // Top Badge
                span(classes: 'position-absolute top-0 end-0 m-2 badge bg-danger text-white rounded-pill px-2 py-1 fs-8 fw-bold shadow', [
                  Component.text(item['badge'].toString()),
                ]),
                // Product Image
                div(
                  classes: 'position-relative overflow-hidden bg-light text-center p-3 cursor-pointer',
                  events: {'click': (e) => _openProductDetail(item)},
                  [
                    img(
                      src: item['image'].toString(),
                      classes: 'img-fluid rounded-3 object-fit-cover w-100',
                      styles: Styles(height: 200.px),
                      attributes: {'alt': item['name'].toString()},
                    ),
                  ],
                ),
                // Card Body
                div(classes: 'card-body p-3 d-flex flex-column justify-content-between', [
                  div([
                    span(classes: 'badge bg-danger-subtle text-danger rounded-pill fs-8 fw-semibold mb-2', [
                      Component.text(item['category'].toString()),
                    ]),
                    h6(
                      classes: 'fw-bold text-dark fs-7 mb-2 line-clamp-2 cursor-pointer',
                      events: {'click': (e) => _openProductDetail(item)},
                      [Component.text(item['name'].toString())],
                    ),
                    p(classes: 'text-muted fs-8 mb-3 line-clamp-2', [
                      Component.text(item['description'].toString()),
                    ]),
                  ]),
                  div([
                    div(classes: 'd-flex align-items-center justify-content-between mb-3', [
                      span(classes: 'fw-extrabold fs-5 text-danger', [
                        Component.text('Rp ${(item['price'] as int).toString()}'),
                      ]),
                      span(classes: 'text-warning fs-8 fw-bold d-flex align-items-center gap-1', [
                        i(classes: 'bi bi-star-fill', []),
                        Component.text('5.0'),
                      ]),
                    ]),
                    div(classes: 'row g-1', [
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-outline-secondary btn-sm w-100 rounded-pill fw-bold py-1 fs-8',
                          events: {'click': (e) => _openProductDetail(item)},
                          [Component.text('Detail')],
                        ),
                      ]),
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-outline-danger btn-sm w-100 rounded-pill fw-bold py-1 fs-8',
                          events: {'click': (e) => _addToCart(item)},
                          [Component.text('+ Cart')],
                        ),
                      ]),
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-success btn-sm w-100 rounded-pill fw-bold py-1 fs-8',
                          events: {'click': (e) => _orderDirectWhatsApp(item)},
                          [Component.text('Beli')],
                        ),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]),
        ]),
    ]);
  }

  Component _buildCustomOrderSection() {
    return div(classes: 'container mb-5', id: 'custom', [
      div(classes: 'card border-0 shadow-lg rounded-4 overflow-hidden bg-danger text-white p-4 p-md-5 position-relative', [
        div(classes: 'row align-items-center g-4', [
          div(classes: 'col-lg-8', [
            span(classes: 'badge bg-white text-danger fw-bold rounded-pill px-3 py-1 fs-7 mb-3', [
              Component.text('🎨 Layanan Custom Special Order'),
            ]),
            h2(classes: 'fw-extrabold display-6 mb-3', [
              Component.text('Punya Ide Karakter & Warna Boneka Sendiri?'),
            ]),
            p(classes: 'fs-6 opacity-90 mb-4', [
              Component.text(
                'Kami menerima pembuatan boneka amigurumi custom wisuda, bantal rajut nama, hingga gantungan kunci souvenir pernikahan sesuai keinginanmu! Konsultasikan desainmu sekarang gratis.',
              ),
            ]),
            div(classes: 'd-flex flex-wrap gap-3', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-light text-danger btn-lg rounded-pill px-4 py-2 fs-6 fw-extrabold shadow-sm',
                attributes: {'style': 'background-color: #ffffff !important; color: #dc3545 !important;'},
                events: {
                  'click': (e) {
                    final config = AppStore().landingConfig;
                    html.window.open(
                      'https://wa.me/${config.whatsappNumber}?text=Halo%20Kak%20${config.storeName},%20saya%20mau%20order%20custom%20boneka/rajutan%20dengan%20desain%20sendiri',
                      '_blank',
                    );
                  }
                },
                [
                  i(classes: 'bi bi-whatsapp me-2 text-success', []),
                  Component.text('Konsultasi Desain Custom WA'),
                ],
              ),
            ]),
          ]),
          div(classes: 'col-lg-4 text-center d-none d-lg-block', [
            img(
              src: 'images/amigurumi_bear.png',
              classes: 'img-fluid rounded-4 border border-3 border-white shadow-lg',
              styles: Styles(maxHeight: 220.px),
              attributes: {'alt': 'Custom Request Amigurumi'},
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildFeaturesSection() {
    return div(classes: 'container mb-5', id: 'keunggulan', [
      div(classes: 'text-center mb-5', [
        h2(classes: 'fw-bold text-dark mb-1', [Component.text('Mengapa Memilih Toko Kami?')]),
        p(classes: 'text-muted fs-7', [Component.text('Kualitas bahan dan pengerjaan tangan terbaik untuk kepuasanmu')]),
      ]),
      div(classes: 'row g-4', [
        _buildFeatureCard(
          '🧶',
          'Benang Milk Cotton Premium',
          'Tekstur super lembut, hypoallergenic (aman untuk bayi), dan warna awet tahan lama tidak luntur.',
        ),
        _buildFeatureCard(
          '👐',
          '100% Homemade With Love',
          'Setiap simpul rajutan dikerjakan buatan tangan dengan presisi dan ketelitian tinggi.',
        ),
        _buildFeatureCard(
          '🎁',
          'Free Gift Box & Greeting Card',
          'Gratis kemasan box kado pita cantik dan kartu ucapan kustom siap diberikan ke orang tersayang.',
        ),
        _buildFeatureCard(
          '🚀',
          'Pengiriman Cepat & Garansi',
          'Packing bubble wrap berlapis tebal dan jaminan penggantian barang jika rusak di jalan.',
        ),
      ]),
    ]);
  }

  Component _buildFeatureCard(String emoji, String title, String desc) {
    return div(classes: 'col-md-6 col-lg-3', [
      div(classes: 'card h-100 border-0 shadow-sm rounded-4 p-4 text-center bg-white hover-shadow transition-all', [
        div(classes: 'fs-1 mb-3', [Component.text(emoji)]),
        h5(classes: 'fw-bold text-dark fs-6 mb-2', [Component.text(title)]),
        p(classes: 'text-muted fs-7 mb-0', [Component.text(desc)]),
      ]),
    ]);
  }

  Component _buildTestimonialsSection() {
    final reviews = [
      {
        'name': 'Siti Rahmawati',
        'role': 'Pembeli Verified',
        'text': 'Boneka amigurumi teddy bearnya super cantik dan rapi banget! Benangnya halus nggak bikin gatal. Gift box nya juga estetik banget!',
        'rating': 5,
        'avatar': 'SR',
      },
      {
        'name': 'Budi Santoso',
        'role': 'Custom Order Wisuda',
        'text': 'Custom boneka wisuda buat pacar hasilnya mirip banget sama foto request. Pengerjaan cepat dan adminnya sangat ramah!',
        'rating': 5,
        'avatar': 'BS',
      },
      {
        'name': 'Nabila Putri',
        'role': 'Pembeli Fashion Rajut',
        'text': 'Set syal & beanie hat rajutnya hangat banget pas dipakai liburan ke Bromo. Warnanya warna pastel cantik sesuai foto produk.',
        'rating': 5,
        'avatar': 'NP',
      },
    ];

    return div(classes: 'bg-danger-subtle py-5 mb-5', id: 'testimoni', [
      div(classes: 'container py-3', [
        div(classes: 'text-center mb-5', [
          span(classes: 'badge bg-danger text-white rounded-pill px-3 py-1 fs-7 mb-2', [Component.text('⭐ 100% Real Testimoni')]),
          h2(classes: 'fw-bold text-dark mb-1', [Component.text('Apa Kata Mereka Tentang Kami?')]),
          p(classes: 'text-muted fs-7', [Component.text('Ribuan pelanggan telah merasakan kehangatan rajutan toko kami')]),
        ]),
        div(classes: 'row g-4', [
          for (var rev in reviews)
            div(classes: 'col-md-4', [
              div(classes: 'card h-100 border-0 shadow-sm rounded-4 p-4 bg-white', [
                div(classes: 'text-warning mb-3 fs-7', [
                  for (var idx = 0; idx < (rev['rating'] as int); idx++) i(classes: 'bi bi-star-fill me-1', []),
                ]),
                p(classes: 'text-muted fs-7 fst-italic mb-4 flex-grow-1', [
                  Component.text('"${rev['text']}"'),
                ]),
                div(classes: 'd-flex align-items-center gap-3 pt-3 border-top', [
                  div(classes: 'bg-danger text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7', styles: Styles(width: 40.px, height: 40.px), [
                    Component.text(rev['avatar'].toString()),
                  ]),
                  div([
                    h6(classes: 'fw-bold text-dark mb-0 fs-7', [Component.text(rev['name'].toString())]),
                    small(classes: 'text-muted fs-8', [Component.text(rev['role'].toString())]),
                  ]),
                ]),
              ]),
            ]),
        ]),
      ]),
    ]);
  }

  Component _buildStorefrontFooter() {
    final config = AppStore().landingConfig;
    return footer(classes: 'bg-dark text-white pt-5 pb-4', [
      div(classes: 'container', [
        div(classes: 'row g-4 mb-4 border-bottom border-secondary pb-4', [
          div(classes: 'col-lg-4', [
            div(classes: 'd-flex align-items-center gap-2 mb-3', [
              span(classes: 'fs-3', [Component.text('🧶')]),
              h4(classes: 'fw-bold text-white mb-0', [Component.text(config.storeName)]),
            ]),
            p(classes: 'text-secondary fs-7 mb-3', [
              Component.text(
                "Abel'z handmade oleh Yayuk Wahyuni (@yayukwahyuni26) menyajikan kerajinan rajut buatan tangan estetik. Tas rajut serut, cup holder eco-friendly, gantungan kunci Miffy doll, dan kado custom pilihan.",
              ),
            ]),
            div(classes: 'd-flex gap-2', [
              a(href: 'https://www.instagram.com/yayukwahyuni26/', target: Target.blank, classes: 'btn btn-outline-light btn-sm rounded-circle', [i(classes: 'bi bi-instagram', [])]),
              a(href: '#', classes: 'btn btn-outline-light btn-sm rounded-circle', [i(classes: 'bi bi-tiktok', [])]),
              a(href: '#', classes: 'btn btn-outline-light btn-sm rounded-circle', [i(classes: 'bi bi-whatsapp', [])]),
            ]),
          ]),
          div(classes: 'col-6 col-lg-2', [
            h6(classes: 'fw-bold text-white mb-3', [Component.text('Kategori Produk')]),
            ul(classes: 'list-unstyled fs-7 text-secondary', [
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Tas Rajut Serut')]),]),
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Cup Holder Eco-Friendly')]),]),
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Ganci Miffy & Turtle')]),]),
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Pouch & Accessories')]),]),
            ]),
          ]),
          div(classes: 'col-6 col-lg-2', [
            h6(classes: 'fw-bold text-white mb-3', [Component.text('Bantuan & Info')]),
            ul(classes: 'list-unstyled fs-7 text-secondary', [
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Cara Order Custom')]),]),
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Info Pengiriman')]),]),
              li(classes: 'mb-2', [a(href: '#', classes: 'text-secondary text-decoration-none', [Component.text('Kebijakan Garansi')]),]),
            ]),
          ]),
          div(classes: 'col-lg-4', [
            h6(classes: 'fw-bold text-white mb-3', [Component.text('Metode Pembayaran Resmi')]),
            div(classes: 'd-flex flex-wrap gap-2 mb-3', [
              span(classes: 'badge bg-secondary px-3 py-2 fs-8', [Component.text('QRIS All Payment')]),
              span(classes: 'badge bg-secondary px-3 py-2 fs-8', [Component.text('Bank BCA / Mandiri')]),
              span(classes: 'badge bg-secondary px-3 py-2 fs-8', [Component.text('GoPay / ShopeePay')]),
              span(classes: 'badge bg-secondary px-3 py-2 fs-8', [Component.text('COD Bayar Ditempat')]),
            ]),
            small(classes: 'text-secondary fs-8', [
              Component.text('📍 Workshop Studio: Jl. Kerajinan No. 45, Bandung, Jawa Barat'),
            ]),
          ]),
        ]),
        div(classes: 'd-flex flex-wrap justify-content-between align-items-center text-secondary fs-8', [
          div([Component.text('© 2026 ${config.storeName} Handmade Studio. Seluruh Hak Dilindungi.')]),
          div(classes: 'd-flex gap-3', [
            Link(to: '/', child: a(href: '/', classes: 'text-secondary text-decoration-none fw-bold', [Component.text('⚙️ Masuk Admin Panel')])),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildCartModal() {
    double total = cartItems.fold<double>(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));

    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-danger text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-bag-check-fill fs-5', []),
              Component.text('Keranjang Belanja Rajutan Saya'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showCartModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-light', [
            if (cartItems.isEmpty)
              div(classes: 'text-center py-5 text-muted', [
                i(classes: 'bi bi-cart-x fs-1 text-secondary mb-2 d-block', []),
                p(classes: 'fs-6 fw-semibold mb-1', [Component.text('Keranjang belanja Anda masih kosong.')]),
                small([Component.text('Silakan pilih produk rajutan favoritmu di katalog.')]),
              ])
            else
              ul(classes: 'list-group list-group-flush mb-3 rounded-3 shadow-sm border-0', [
                for (var i = 0; i < cartItems.length; i++)
                  li(classes: 'list-group-item p-3 d-flex align-items-center justify-content-between gap-3 bg-white', [
                    img(
                      src: cartItems[i]['image'].toString(),
                      classes: 'rounded-3 border object-fit-cover',
                      attributes: {'width': '54', 'height': '54', 'alt': cartItems[i]['name'].toString()},
                    ),
                    div(classes: 'flex-grow-1', [
                      h6(classes: 'fw-bold text-dark fs-7 mb-1', [Component.text(cartItems[i]['name'].toString())]),
                      div(classes: 'text-danger fw-bold fs-7', [
                        Component.text('Rp ${(cartItems[i]['price'] as int).toString()}'),
                      ]),
                    ]),
                    div(classes: 'd-flex align-items-center gap-2', [
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-secondary rounded-circle px-2 py-0 fw-bold',
                        events: {'click': (e) => _updateCartQty(i, -1)},
                        [Component.text('-')],
                      ),
                      span(classes: 'fw-bold px-2 fs-7', [Component.text(cartItems[i]['qty'].toString())]),
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-secondary rounded-circle px-2 py-0 fw-bold',
                        events: {'click': (e) => _updateCartQty(i, 1)},
                        [Component.text('+')],
                      ),
                    ]),
                    div(classes: 'fw-bold text-dark fs-7 text-end', styles: Styles(minWidth: 80.px), [
                      Component.text('Rp ${((cartItems[i]['price'] as int) * (cartItems[i]['qty'] as int)).toString()}'),
                    ]),
                  ]),
              ]),
            if (cartItems.isNotEmpty)
              div(classes: 'p-3 bg-white rounded-3 border d-flex justify-content-between align-items-center shadow-sm', [
                span(classes: 'fw-bold text-dark fs-6', [Component.text('Total Pembayaran:')]),
                span(classes: 'fw-extrabold text-danger fs-4', [Component.text('Rp ${total.toInt()}')]),
              ]),
          ]),
          div(classes: 'modal-footer bg-white py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary px-3 rounded-pill fw-semibold',
              events: {'click': (e) => setState(() => showCartModal = false)},
              [Component.text('Lanjut Belanja')],
            ),
            if (cartItems.isNotEmpty)
              button(
                type: ButtonType.button,
                classes: 'btn btn-success px-4 rounded-pill fw-extrabold d-flex align-items-center gap-2 shadow-sm',
                events: {'click': (e) => _checkoutWhatsApp()},
                [
                  i(classes: 'bi bi-whatsapp fs-5', []),
                  Component.text('Checkout Pesanan Via WhatsApp'),
                ],
              ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildProductDetailModal() {
    final item = selectedProductDetail!;
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-white border-bottom py-3', [
            span(classes: 'badge bg-danger-subtle text-danger rounded-pill px-3 py-1 fs-7 fw-bold', [
              Component.text(item['category'].toString()),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close',
              events: {'click': (e) => setState(() => showProductDetailModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-white', [
            div(classes: 'row g-4 align-items-center', [
              div(classes: 'col-md-6 text-center', [
                img(
                  src: item['image'].toString(),
                  classes: 'img-fluid rounded-4 border shadow-sm object-fit-cover w-100',
                  styles: Styles(maxHeight: 280.px),
                  attributes: {'alt': item['name'].toString()},
                ),
              ]),
              div(classes: 'col-md-6', [
                h4(classes: 'fw-extrabold text-dark mb-2', [Component.text(item['name'].toString())]),
                div(classes: 'd-flex align-items-center gap-2 mb-3', [
                  div(classes: 'text-warning fs-7 fw-bold', [Component.text('★★★★★ 5.0')]),
                  span(classes: 'text-muted fs-8', [Component.text('(120+ Terjual)')]),
                ]),
                h3(classes: 'fw-extrabold text-danger mb-3', [
                  Component.text('Rp ${(item['price'] as int).toString()}'),
                ]),
                p(classes: 'text-muted fs-7 mb-4', [
                  Component.text(item['description'].toString().isEmpty ? 'Produk rajutan kualitas tinggi buatan tangan dengan benang Milk Cotton super lembut.' : item['description'].toString()),
                ]),
                div(classes: 'p-3 bg-light rounded-3 border mb-4 fs-8 text-secondary', [
                  div(classes: 'd-flex align-items-center gap-2 mb-1', [
                    i(classes: 'bi bi-check-circle-fill text-success', []),
                    Component.text('100% Original Handmade Milk Cotton'),
                  ]),
                  div(classes: 'd-flex align-items-center gap-2', [
                    i(classes: 'bi bi-box-seam-fill text-primary', []),
                    Component.text('Free Gift Box & Greeting Card'),
                  ]),
                ]),
                div(classes: 'd-flex gap-2', [
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-outline-danger rounded-pill px-3 py-2 fw-bold flex-grow-1 fs-7',
                    events: {
                      'click': (e) {
                        _addToCart(item);
                        setState(() => showProductDetailModal = false);
                      }
                    },
                    [
                      i(classes: 'bi bi-cart-plus me-1', []),
                      Component.text('+ Keranjang'),
                    ],
                  ),
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-success rounded-pill px-4 py-2 fw-bold flex-grow-1 fs-7 shadow-sm',
                    events: {
                      'click': (e) {
                        _orderDirectWhatsApp(item);
                        setState(() => showProductDetailModal = false);
                      }
                    },
                    [
                      i(classes: 'bi bi-whatsapp me-1', []),
                      Component.text('Beli Langsung WA'),
                    ],
                  ),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

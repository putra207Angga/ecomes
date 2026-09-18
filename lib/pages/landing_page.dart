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

  // Product Detail & Customizer State
  Map<String, dynamic>? selectedProductDetail;
  bool showProductDetailModal = false;
  String selectedYarn = 'Benang Poliindo';
  String selectedColor = 'Pastel Pink';
  String customNotes = '';

  // Member Dashboard Tab State
  String activeMemberTab = 'history'; // 'history', 'products', 'ecard'

  // Order Tracker State
  bool showOrderTrackerModal = false;
  String orderTrackerQuery = '';
  OrderItem? searchedOrderResult;
  bool orderSearchAttempted = false;

  // Write Review State
  bool showWriteReviewModal = false;
  String reviewNameInput = '';
  String reviewProductInput = 'Tas Rajut Serut Drawstring Purse 25x25';
  int reviewRatingInput = 5;
  String reviewCommentInput = '';
  String toastMessageText = 'Pesanan berhasil disimpan ke Sistem Admin Panel (Kelola Pesanan) & diteruskan ke WhatsApp!';

  // Member Portal & Wishlist State
  bool showMemberModal = false;
  bool isRegisteringMember = false;
  String memberEmailInput = '';
  String memberPasswordInput = '';
  String memberNameInput = '';
  String memberPhoneInput = '';
  String memberErrorMsg = '';
  bool showWishlistModal = false;
  bool useMemberPointsInCart = false;

  void _addToCart(Map<String, dynamic> item, {String yarn = '', String color = '', String notes = ''}) {
    setState(() {
      final y = yarn.isNotEmpty ? yarn : selectedYarn;
      final c = color.isNotEmpty ? color : selectedColor;
      final itemKey = '${item['id']}_${y}_$c';
      final existingIndex = cartItems.indexWhere((element) => element['cartKey'] == itemKey);
      if (existingIndex >= 0) {
        cartItems[existingIndex]['qty'] += 1;
      } else {
        cartItems.add({
          'cartKey': itemKey,
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'image': item['image'],
          'yarn': y,
          'color': c,
          'notes': notes.isNotEmpty ? notes : customNotes,
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
      selectedYarn = 'Benang Poliindo';
      selectedColor = 'Pastel Pink';
      customNotes = '';
      showProductDetailModal = true;
    });
  }

  void _searchOrderTracker() {
    setState(() {
      orderSearchAttempted = true;
      searchedOrderResult = AppStore().findOrderByNumberOrPhone(orderTrackerQuery);
    });
  }

  void _submitBuyerReview() {
    if (reviewNameInput.trim().isEmpty || reviewCommentInput.trim().isEmpty) return;
    final now = DateTime.now();
    final newReview = ReviewItem(
      id: now.millisecondsSinceEpoch.toString(),
      customerName: reviewNameInput.trim(),
      productTitle: reviewProductInput.trim(),
      rating: reviewRatingInput,
      comment: reviewCommentInput.trim(),
      date: '${now.day} Sep ${now.year}',
      status: 'Perlu Balasan',
      approvalStatus: 'Menunggu Moderasi',
    );

    AppStore().addReview(newReview);

    setState(() {
      showWriteReviewModal = false;
      toastMessageText = 'Terima kasih! Ulasan Anda berhasil dikirim dan menunggu moderasi admin.';
      showSuccessToast = true;
      reviewNameInput = '';
      reviewCommentInput = '';
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
      final cColor = (item['color'] ?? '').toString();
      final cYarn = (item['yarn'] ?? '').toString();
      final customStr = (cColor.isNotEmpty || cYarn.isNotEmpty) ? ' [Warna: $cColor, Benang: $cYarn]' : '';
      itemSummary += '- ${item['name']}$customStr x${item['qty']} (Rp ${itemTotal.toInt()})\n';

      orderItemsList.add(OrderProductItem(
        productName: item['name'].toString(),
        qty: item['qty'] as int,
        price: (item['price'] as int).toDouble(),
        customColor: cColor,
        yarnType: cYarn,
        customNotes: (item['notes'] ?? '').toString(),
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

    return div(
      classes: 'landing-page-wrapper bg-pink-cream font-sans-body min-vh-100',
      styles: Styles(raw: {'background-color': '#FAF7F2 !important'}),
      [
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

      // Public Order Tracker Modal
      if (showOrderTrackerModal) _buildOrderTrackerModal(),

      // Write Review Modal
      if (showWriteReviewModal) _buildWriteReviewModal(),

      // Member Portal & E-Card Modal
      if (showMemberModal) _buildMemberModal(),

      // Wishlist Modal
      if (showWishlistModal) _buildWishlistModal(),
    ]);
  }

  Component _buildStorefrontNavbar(int totalCartCount) {
    final config = AppStore().landingConfig;
    return nav(classes: 'navbar navbar-light bg-pink-cream shadow-xs sticky-top py-3 border-bottom text-nowrap', [
      div(classes: 'container-fluid px-lg-5 d-flex align-items-center justify-content-between flex-nowrap gap-3 navbar-scroll-hide', [
        // Brand Logo
        Link(
          to: '/landing',
          child: a(classes: 'navbar-brand d-flex align-items-center gap-2 fw-bold text-espresso fs-5 text-nowrap me-3 font-serif-heading', href: '/landing', [
            span(classes: 'bg-rose-pink text-white rounded-circle d-flex align-items-center justify-content-center shadow-xs flex-shrink-0', styles: Styles(width: 34.px, height: 34.px), [
              Component.text('🧶'),
            ]),
            span(classes: 'text-espresso font-serif-heading fw-bold fs-5 text-nowrap', [Component.text(config.storeName)]),
          ]),
        ),

        // Nav Links
        ul(classes: 'navbar-nav flex-row flex-nowrap gap-3 gap-lg-4 fw-semibold fs-7 text-nowrap mb-0 mx-auto text-uppercase tracking-wider', [
          li(classes: 'nav-item', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-link nav-link ${!isFullStoreMode ? 'text-rose-pink fw-bold' : 'text-espresso'} py-1 px-2 text-decoration-none',
              events: {'click': (e) => setState(() => isFullStoreMode = false)},
              [Component.text('BERANDA')],
            ),
          ]),
          li(classes: 'nav-item', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-link nav-link ${isFullStoreMode ? 'text-rose-pink fw-bold' : 'text-espresso'} py-1 px-2 text-decoration-none',
              events: {'click': (e) => setState(() => isFullStoreMode = true)},
              [
                Component.text('TAS RAJUT'),
              ],
            ),
          ]),
          li(classes: 'nav-item', [a(classes: 'nav-link text-espresso py-1 px-2', href: '#katalog', [Component.text('HIASAN DINDING')]),]),
          li(classes: 'nav-item', [a(classes: 'nav-link text-espresso py-1 px-2', href: '#custom', [Component.text('BANTAL & TEKSTIL')]),]),
          li(classes: 'nav-item', [a(classes: 'nav-link text-espresso py-1 px-2', href: '#testimoni', [Component.text('AKSESORIS')]),]),
        ]),

        // Quick Actions Icon Buttons with Tooltips
        div(classes: 'd-flex align-items-center gap-2 flex-nowrap text-nowrap flex-shrink-0', [
          // 1. Icon Button Lacak Pesanan
          button(
            type: ButtonType.button,
            classes: 'btn btn-light rounded-circle shadow-xs border border-light text-espresso position-relative d-flex align-items-center justify-content-center p-0 hover-scale',
            styles: Styles(width: 40.px, height: 40.px),
            attributes: {'title': 'Lacak Pesanan Pembeli', 'data-bs-toggle': 'tooltip'},
            events: {'click': (e) => setState(() => showOrderTrackerModal = true)},
            [
              i(classes: 'bi bi-truck fs-5 text-terracotta', []),
            ],
          ),

          // 2. Icon Button Wishlist
          button(
            type: ButtonType.button,
            classes: 'btn btn-clay-pill rounded-circle shadow-xs border-0 position-relative d-flex align-items-center justify-content-center p-0 hover-scale',
            styles: Styles(width: 40.px, height: 40.px),
            attributes: {'title': 'Wishlist & Produk Favorit Saya', 'data-bs-toggle': 'tooltip'},
            events: {'click': (e) => setState(() => showWishlistModal = true)},
            [
              i(classes: 'bi bi-heart-fill fs-5 text-terracotta', []),
              if (AppStore().wishlistProductIds.isNotEmpty)
                span(classes: 'position-absolute top-0 start-100 translate-middle badge rounded-pill bg-terracotta text-white fs-8 shadow-xs', [
                  Component.text(AppStore().wishlistProductIds.length.toString()),
                ]),
            ],
          ),

          // 3. Icon Button Member Portal
          button(
            type: ButtonType.button,
            classes: 'btn btn-clay-pill rounded-circle shadow-xs border-0 position-relative d-flex align-items-center justify-content-center p-0 hover-scale',
            styles: Styles(width: 40.px, height: 40.px),
            attributes: {
              'title': AppStore().currentMember != null ? 'Portal Member (${AppStore().currentMember!.name})' : 'Login / Daftar Member',
              'data-bs-toggle': 'tooltip'
            },
            events: {'click': (e) => setState(() { showMemberModal = true; memberErrorMsg = ''; })},
            [
              i(classes: 'bi ${AppStore().currentMember != null ? 'bi-award-fill text-terracotta' : 'bi-person-circle text-terracotta'} fs-5', []),
              if (AppStore().currentMember != null)
                span(classes: 'position-absolute top-0 start-100 translate-middle badge rounded-pill bg-terracotta text-white fs-8 shadow-xs', [
                  Component.text('VIP'),
                ]),
            ],
          ),

          // 4. Icon Button Keranjang Belanja
          button(
            type: ButtonType.button,
            classes: 'btn btn-terracotta rounded-circle shadow-xs border-0 text-white position-relative d-flex align-items-center justify-content-center p-0 hover-scale ms-1',
            styles: Styles(width: 42.px, height: 42.px),
            attributes: {'title': 'Keranjang Belanja Saya', 'data-bs-toggle': 'tooltip'},
            events: {'click': (e) => setState(() => showCartModal = true)},
            [
              i(classes: 'bi bi-bag-heart-fill fs-5', []),
              if (totalCartCount > 0)
                span(classes: 'position-absolute top-0 start-100 translate-middle badge rounded-pill bg-white text-terracotta fw-bold shadow-xs fs-8', [
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
      classes: 'hero-section py-4 py-lg-5 bg-pink-cream text-espresso position-relative overflow-hidden',
      [
        div(classes: 'container py-3', [
          div(classes: 'card-genz bg-soft-card p-4 p-md-5 overflow-hidden border-0 position-relative', [
            div(classes: 'row align-items-center g-4 g-lg-5', [
              div(classes: 'col-lg-6', [
                span(classes: 'badge badge-blush-pink px-3 py-2 fs-7 fw-semibold mb-3 d-inline-flex align-items-center gap-1', [
                  i(classes: 'bi bi-stars me-1', []),
                  Component.text(config.heroBadge),
                ]),
                h1(classes: 'display-4 font-serif-heading fw-bold text-espresso mb-3 lh-sm', [
                  Component.text('Koleksi Rajutan '),
                  span(classes: 'text-rose-pink fst-italic', [Component.text('Tangan Elegan')]),
                ]),
                p(classes: 'lead text-espresso-muted mb-4 fs-6', [
                  Component.text('Tas rajut cantik dan hiasan hunian modern yang dibuat penuh kasih sayang oleh perajin berpengalaman.'),
                ]),
                div(classes: 'd-flex flex-wrap align-items-center gap-3 mb-4', [
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-terracotta btn-lg rounded-pill px-4 py-2.5 fs-6 fw-bold shadow-xs d-inline-flex align-items-center gap-2',
                    events: {'click': (e) => setState(() => isFullStoreMode = true)},
                    [
                      Component.text('Belanja Sekarang'),
                      i(classes: 'bi bi-arrow-right', []),
                    ],
                  ),
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-clay-pill btn-lg rounded-pill px-4 py-2.5 fs-6 fw-bold shadow-xs d-inline-flex align-items-center gap-2',
                    events: {
                      'click': (e) {
                        html.window.open('https://wa.me/${config.whatsappNumber}?text=Halo%20${config.storeName},%20saya%20mau%20konsultasi%20order%20custom%20rajutan', '_blank');
                      }
                    },
                    [
                      i(classes: 'bi bi-whatsapp', []),
                      Component.text('Custom Via WA'),
                    ],
                  ),
                ]),
                div(classes: 'row g-3 text-espresso pt-3 border-top border-light-subtle', [
                  div(classes: 'col-4', [
                    h4(classes: 'fw-bold mb-0 text-terracotta font-serif-heading', [Component.text('1.2k+')]),
                    small(classes: 'text-espresso-muted fs-8', [Component.text('Produk Terjual')]),
                  ]),
                  div(classes: 'col-4', [
                    h4(classes: 'fw-bold mb-0 text-terracotta font-serif-heading', [Component.text('5.0 ⭐')]),
                    small(classes: 'text-espresso-muted fs-8', [Component.text('Rating Ulasan')]),
                  ]),
                  div(classes: 'col-4', [
                    h4(classes: 'fw-bold mb-0 text-terracotta font-serif-heading', [Component.text('Handmade')]),
                    small(classes: 'text-espresso-muted fs-8', [Component.text('Benang Milk Cotton')]),
                  ]),
                ]),
              ]),
              div(classes: 'col-lg-6 text-center', [
                div(classes: 'position-relative d-inline-block w-100 text-center', [
                  img(
                    src: config.heroImage,
                    classes: 'img-fluid rounded-4 shadow-sm object-fit-cover w-100 animate-float',
                    styles: Styles(maxHeight: 460.px),
                    attributes: {'alt': 'Hero Showcase'},
                  ),
                  // Floating Tag Badge Anya Tote Bag
                  div(
                    classes: 'position-absolute bottom-0 end-0 m-3 bg-white px-3 py-2 rounded-pill shadow-sm text-espresso d-flex align-items-center gap-2 border border-light',
                    [
                      span(classes: 'fs-7 fw-bold font-serif-heading text-espresso', [Component.text('Anya Tote Bag ✨')]),
                    ],
                  ),
                ]),
              ]),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildCategorySection() {
    final categories = [
      {'name': 'Tas Rajut', 'label': 'Tas Rajut', 'image': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400'},
      {'name': 'Cup Holder & Sleeve', 'label': 'Hiasan Dinding', 'image': 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400'},
      {'name': 'Pouch & Organiser', 'label': 'Bantal & Tekstil', 'image': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400'},
      {'name': 'Gantungan Kunci', 'label': 'Aksesoris', 'image': 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=400'},
    ];

    return div(classes: 'container py-4 my-3', id: 'katalog', [
      div(classes: 'row g-4 justify-content-center text-center', [
        for (var cat in categories)
          div(classes: 'col-6 col-md-3', [
            div(classes: 'd-flex flex-column align-items-center cursor-pointer', events: {'click': (e) => setState(() => activeCategory = cat['name'] as String)}, [
              div(
                classes: 'rounded-circle overflow-hidden mb-3 border border-4 border-white shadow-xs transition-all hover-scale position-relative',
                styles: Styles(width: 140.px, height: 140.px),
                [
                  img(
                    src: cat['image'] as String,
                    classes: 'w-100 h-100 object-fit-cover',
                    attributes: {'alt': cat['label'] as String},
                  ),
                ],
              ),
              h6(classes: 'font-serif-heading fw-bold text-espresso fs-6 mb-2', [Component.text(cat['label'] as String)]),
              button(
                type: ButtonType.button,
                classes: 'btn btn-clay-pill rounded-pill px-3 py-1 fs-8 fw-semibold',
                events: {'click': (e) => setState(() => activeCategory = cat['name'] as String)},
                [Component.text('Lihat Semua')],
              ),
            ]),
          ]),
      ]),
    ]);
  }

  // Showcase ON LANDING PAGE: STRICTLY 1 ROW ONLY OF PRODUCTS MATCHING REFERENCE IMAGE!
  Component _buildProductsOneRowShowcase(List<Map<String, dynamic>> items) {
    final oneRowItems = items.take(4).toList();

    return div(classes: 'container mb-5 py-3', [
      div(classes: 'd-flex align-items-center justify-content-between mb-4', [
        h3(classes: 'font-serif-heading fw-bold text-espresso mb-0 fs-3', [Component.text('Produk Terbaru')]),
        button(
          type: ButtonType.button,
          classes: 'btn btn-link text-terracotta fw-bold text-decoration-none fs-7 p-0',
          events: {'click': (e) => setState(() => isFullStoreMode = true)},
          [
            Component.text('Lihat Semua Katalog →'),
          ],
        ),
      ]),

      if (oneRowItems.isEmpty)
        div(classes: 'text-center py-5 bg-white rounded-4 shadow-xs border border-light p-4', [
          i(classes: 'bi bi-search fs-1 text-espresso-muted mb-2 d-block', []),
          h5(classes: 'font-serif-heading fw-bold text-espresso', [Component.text('Produk Tidak Ditemukan')]),
          p(classes: 'text-espresso-muted fs-7 mb-0', [Component.text('Coba cari dengan kata kunci lain atau pilih kategori Semua.')]),
        ])
      else ...[
        div(classes: 'row g-4 mb-4', [
          for (var item in oneRowItems)
            div(classes: 'col-sm-6 col-lg-3', [
              div(classes: 'card-genz h-100 border-0 rounded-4 overflow-hidden position-relative bg-white p-2 d-flex flex-column justify-content-between', [
                div([
                  // Product Image Container
                  div(
                    classes: 'position-relative overflow-hidden rounded-4 text-center cursor-pointer mb-3',
                    events: {'click': (e) => _openProductDetail(item)},
                    [
                      img(
                        src: item['image'].toString(),
                        classes: 'img-fluid rounded-4 object-fit-cover w-100',
                        styles: Styles(height: 220.px),
                        attributes: {'alt': item['name'].toString()},
                      ),
                      // Wishlist Heart Overlay Icon Button
                      button(
                        type: ButtonType.button,
                        classes: 'position-absolute top-0 end-0 m-2 btn btn-light rounded-circle p-1.5 shadow-xs border-0 text-terracotta d-flex align-items-center justify-content-center',
                        styles: Styles(width: 34.px, height: 34.px),
                        events: {
                          'click': (e) {
                            AppStore().toggleWishlist(item['id'].toString());
                            setState(() {});
                          }
                        },
                        [
                          i(classes: 'bi ${AppStore().isWishlisted(item['id'].toString()) ? 'bi-heart-fill text-terracotta' : 'bi-heart'} fs-6', []),
                        ],
                      ),
                    ],
                  ),
                  // Product Title & Price
                  h6(
                    classes: 'font-sans-body fw-bold text-espresso fs-7 mb-1 text-truncate cursor-pointer px-1',
                    events: {'click': (e) => _openProductDetail(item)},
                    [Component.text(item['name'].toString())],
                  ),
                  div(classes: 'fw-bold fs-6 text-espresso px-1 mb-3', [
                    Component.text('Rp ${(item['price'] as int).toString()}'),
                  ]),
                ]),
                // Sage Green Pill Action Button
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-sage btn-sm w-100 rounded-pill py-2 fs-7 fw-bold shadow-xs',
                  events: {'click': (e) => _addToCart(item)},
                  [Component.text('Tambah ke Keranjang')],
                ),
              ]),
            ]),
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

  // Artisan Craft Showcase Banner matching reference image middle block
  Component _buildCustomOrderSection() {
    return div(classes: 'container mb-5 py-2', id: 'custom', [
      div(classes: 'card-genz bg-soft-card p-4 p-md-5 border-0 overflow-hidden rounded-4', [
        div(classes: 'row align-items-center g-4 g-lg-5', [
          div(classes: 'col-lg-6', [
            img(
              src: 'images/abelz_craft_artisan.png',
              classes: 'img-fluid rounded-4 shadow-xs object-fit-cover w-100',
              styles: Styles(maxHeight: 380.px),
              attributes: {'alt': 'Karya Artisan Kami'},
            ),
          ]),
          div(classes: 'col-lg-6', [
            span(classes: 'badge badge-blush-pink px-3 py-1.5 fs-7 fw-semibold mb-3 d-inline-block', [
              Component.text('Karya Artisan Kami ✨'),
            ]),
            h2(classes: 'font-serif-heading display-6 fw-bold text-espresso mb-3', [
              Component.text('Kecantikan dalam setiap simpul.'),
            ]),
            p(classes: 'text-espresso-muted fs-6 mb-4 lh-base', [
              Component.text(
                'Produk kami didesain elegan, tahan lama, dan ramah lingkungan. Setiap benang dirajut secara handmade dengan ketelitian tinggi oleh perajin berpengalaman @yayukwahyuni26.',
              ),
            ]),
            div(classes: 'd-flex flex-wrap gap-3', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-rose-pink btn-lg rounded-pill px-4 py-2.5 fs-6 fw-bold shadow-xs',
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
                  i(classes: 'bi bi-whatsapp me-2', []),
                  Component.text('Konsultasi Custom WA'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildFeaturesSection() {
    return div(classes: 'container mb-5 py-2', id: 'keunggulan', [
      div(classes: 'row g-4', [
        _buildFeatureCard(
          '🧶',
          'Benang Milk Cotton Premium',
          'Tekstur super lembut, hypoallergenic, dan warna pastel awet.',
        ),
        _buildFeatureCard(
          '👐',
          '100% Homemade With Love',
          'Setiap simpul rajutan dikerjakan buatan tangan presisi.',
        ),
        _buildFeatureCard(
          '🎁',
          'Free Gift Box & Card',
          'Gratis kemasan box pita cantik siap kado tersayang.',
        ),
        _buildFeatureCard(
          '🚀',
          'Pengiriman Cepat & Garansi',
          'Packing tebal berlapis dan jaminan aman sampai tujuan.',
        ),
      ]),
    ]);
  }

  Component _buildFeatureCard(String emoji, String title, String desc) {
    return div(classes: 'col-md-6 col-lg-3', [
      div(classes: 'card-genz h-100 p-4 text-center bg-white border-0 rounded-4', [
        div(classes: 'fs-1 mb-2', [Component.text(emoji)]),
        h6(classes: 'font-serif-heading fw-bold text-espresso fs-6 mb-2', [Component.text(title)]),
        p(classes: 'text-espresso-muted fs-7 mb-0', [Component.text(desc)]),
      ]),
    ]);
  }

  Component _buildTestimonialsSection() {
    final reviews = [
      {
        'name': 'Siti Rahmawati',
        'role': 'RajutanCantik Verified',
        'text': 'Tas rajut serutnya super cantik dan rapi banget! Benangnya halus warna pastelnya soft.',
        'rating': 5,
        'avatar': 'SR',
      },
      {
        'name': 'Budi Santoso',
        'role': 'Custom Order Wisuda',
        'text': 'Custom boneka wisuda buat pacar hasilnya mirip banget sama foto request.',
        'rating': 5,
        'avatar': 'BS',
      },
      {
        'name': 'Nabila Putri',
        'role': 'Pembeli Fashion Rajut',
        'text': 'Macrame wall hangingnya estetik banget pas dipasang di kamar estetik!',
        'rating': 5,
        'avatar': 'NP',
      },
    ];

    return div(classes: 'bg-soft-card py-5 mb-5 border-top border-bottom border-light-subtle', id: 'testimoni', [
      div(classes: 'container py-3', [
        div(classes: 'text-center mb-5', [
          h2(classes: 'font-serif-heading fw-bold text-espresso mb-2 fs-2', [Component.text('Inspirasi Ruang & Ulasan')]),
          p(classes: 'text-espresso-muted fs-7 mb-3', [Component.text('Kehangatan karya rajut buatan tangan pelanggan kami')]),
          button(
            type: ButtonType.button,
            classes: 'btn btn-blush-pink btn-sm rounded-pill px-4 py-2 fs-7 fw-bold shadow-xs',
            events: {'click': (e) => setState(() => showWriteReviewModal = true)},
            [
              i(classes: 'bi bi-pencil-square me-1', []),
              Component.text('Tulis Ulasan Anda ✍️'),
            ],
          ),
        ]),
        div(classes: 'row g-4 mb-5', [
          for (var rev in reviews)
            div(classes: 'col-md-4', [
              div(classes: 'card-genz h-100 p-4 bg-white border-0 rounded-4', [
                div(classes: 'text-warning mb-2 fs-7', [
                  for (var idx = 0; idx < (rev['rating'] as int); idx++) i(classes: 'bi bi-star-fill me-1', []),
                ]),
                p(classes: 'text-espresso-muted fs-7 fst-italic mb-4 flex-grow-1', [
                  Component.text('"${rev['text']}"'),
                ]),
                div(classes: 'd-flex align-items-center gap-3 pt-3 border-top border-light-subtle', [
                  div(classes: 'bg-rose-pink text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7', styles: Styles(width: 38.px, height: 38.px), [
                    Component.text(rev['avatar'].toString()),
                  ]),
                  div([
                    h6(classes: 'font-sans-body fw-bold text-espresso mb-0 fs-7', [Component.text(rev['name'].toString())]),
                    small(classes: 'text-rose-pink fs-8 fw-semibold', [Component.text(rev['role'].toString())]),
                  ]),
                ]),
              ]),
            ]),
        ]),

        // Instagram Grid Section @RajutanCantik
        div(classes: 'text-center pt-3', [
          h4(classes: 'font-serif-heading fw-bold text-espresso mb-4 fs-4', [Component.text('@RajutanCantik / @AbelzHandmade')]),
          div(classes: 'row g-3 justify-content-center', [
            for (var imgUrl in [
              'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400',
              'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400',
              'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400',
              'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=400',
              'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?w=400',
            ])
              div(classes: 'col-6 col-sm-4 col-md-2', [
                div(classes: 'rounded-4 overflow-hidden border border-2 border-white shadow-xs cursor-pointer hover-scale', styles: Styles(height: 140.px), [
                  img(src: imgUrl, classes: 'w-100 h-100 object-fit-cover', attributes: {'alt': 'Instagram Feed'}),
                ]),
              ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildStorefrontFooter() {
    final config = AppStore().landingConfig;
    return footer(classes: 'bg-pink-cream text-espresso pt-5 pb-4 border-top border-light-subtle', [
      div(classes: 'container', [
        div(classes: 'row g-4 mb-4 border-bottom border-light-subtle pb-4', [
          div(classes: 'col-lg-4', [
            div(classes: 'd-flex align-items-center gap-2 mb-3', [
              span(classes: 'fs-3', [Component.text('🧶')]),
              h4(classes: 'font-serif-heading fw-bold text-espresso mb-0', [Component.text(config.storeName)]),
            ]),
            p(classes: 'text-espresso-muted fs-7 mb-3', [
              Component.text(
                "Abel'z handmade menyajikan kerajinan rajut buatan tangan estetik. Tas rajut serut, cup holder eco-friendly, gantungan kunci Miffy doll, dan kado custom pilihan.",
              ),
            ]),
            div(classes: 'd-flex gap-2', [
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
    final colors = [
      {'name': 'Pastel Pink 🌸', 'code': 'Pastel Pink'},
      {'name': 'Cream Estetik 🍦', 'code': 'Cream Estetik'},
      {'name': 'Sage Green 🌿', 'code': 'Sage Green'},
      {'name': 'Navy Blue ⚓', 'code': 'Navy Blue'},
      {'name': 'Butter Yellow 💛', 'code': 'Butter Yellow'},
      {'name': 'Lilac Soft 🪻', 'code': 'Lilac Soft'},
    ];

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
            div(classes: 'row g-4', [
              div(classes: 'col-md-5 text-center', [
                img(
                  src: item['image'].toString(),
                  classes: 'img-fluid rounded-4 border shadow-sm object-fit-cover w-100 mb-3',
                  styles: Styles(maxHeight: 260.px),
                  attributes: {'alt': item['name'].toString()},
                ),
                div(classes: 'p-3 bg-light rounded-3 border fs-8 text-secondary text-start', [
                  div(classes: 'd-flex align-items-center gap-2 mb-1', [
                    i(classes: 'bi bi-check-circle-fill text-success', []),
                    Component.text('100% Handcrafted by Abel\'z Handmade'),
                  ]),
                  div(classes: 'd-flex align-items-center gap-2', [
                    i(classes: 'bi bi-box-seam-fill text-primary', []),
                    Component.text('Free Gift Box & Greeting Card'),
                  ]),
                ]),
              ]),
              div(classes: 'col-md-7', [
                h4(classes: 'fw-extrabold text-dark mb-1', [Component.text(item['name'].toString())]),
                div(classes: 'd-flex align-items-center gap-2 mb-2', [
                  div(classes: 'text-warning fs-7 fw-bold', [Component.text('★★★★★ 5.0')]),
                  span(classes: 'text-muted fs-8', [Component.text('(120+ Terjual)')]),
                ]),
                h3(classes: 'fw-extrabold text-danger mb-3', [
                  Component.text('Rp ${(item['price'] as int).toString()}'),
                ]),
                p(classes: 'text-muted fs-7 mb-3', [
                  Component.text(item['description'].toString().isEmpty ? 'Produk rajutan kualitas tinggi buatan tangan dengan pilihan benang terbaik.' : item['description'].toString()),
                ]),

                // Custom Crochet Options Selector
                div(classes: 'card border-danger border-opacity-25 bg-danger-subtle bg-opacity-10 p-3 rounded-3 mb-3', [
                  h6(classes: 'fw-bold text-dark fs-7 mb-2 d-flex align-items-center gap-1', [
                    i(classes: 'bi bi-palette-fill text-danger me-1', []),
                    Component.text('Kustomisasi Warna & Bahan Rajutan:'),
                  ]),

                  // 1. Yarn Choice
                  div(classes: 'mb-2', [
                    small(classes: 'fw-bold text-muted fs-8 d-block mb-1', [Component.text('Pilih Jenis Benang:')]),
                    div(classes: 'd-flex gap-2', [
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm rounded-pill ${selectedYarn == 'Benang Poliindo' ? 'btn-danger text-white fw-bold' : 'btn-outline-secondary'} fs-8',
                        events: {'click': (e) => setState(() => selectedYarn = 'Benang Poliindo')},
                        [Component.text('Benang Poliindo (Kuat & Awet)')],
                      ),
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm rounded-pill ${selectedYarn == 'Milk Cotton Yarn' ? 'btn-danger text-white fw-bold' : 'btn-outline-secondary'} fs-8',
                        events: {'click': (e) => setState(() => selectedYarn = 'Milk Cotton Yarn')},
                        [Component.text('Milk Cotton (Super Soft)')],
                      ),
                    ]),
                  ]),

                  // 2. Color Chips
                  div(classes: 'mb-2', [
                    small(classes: 'fw-bold text-muted fs-8 d-block mb-1', [Component.text('Pilih Warna Main Custom:')]),
                    div(classes: 'd-flex flex-wrap gap-1', [
                      for (var c in colors)
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm rounded-pill ${selectedColor == c['code'] ? 'btn-dark text-white fw-bold' : 'btn-light text-dark border'} fs-8',
                          events: {'click': (e) => setState(() => selectedColor = c['code']!)},
                          [Component.text(c['name']!)],
                        ),
                    ]),
                  ]),

                  // 3. Custom Notes Input
                  div([
                    small(classes: 'fw-bold text-muted fs-8 d-block mb-1', [Component.text('Catatan / Inisial Custom (Opsional):')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control form-control-sm fs-8 bg-white',
                      value: customNotes,
                      attributes: {'placeholder': 'Contoh: Tambah inisial nama "Y" pada gantungan'},
                      events: {
                        'input': (e) {
                          setState(() {
                            customNotes = (e.target as html.InputElement).value ?? '';
                          });
                        }
                      },
                    ),
                  ]),
                ]),

                div(classes: 'd-flex gap-2', [
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-outline-danger rounded-pill px-3 py-2 fw-bold flex-grow-1 fs-7',
                    events: {
                      'click': (e) {
                        _addToCart(item, yarn: selectedYarn, color: selectedColor, notes: customNotes);
                        setState(() => showProductDetailModal = false);
                      }
                    },
                    [
                      i(classes: 'bi bi-cart-plus me-1', []),
                      Component.text('+ Keranjang Custom'),
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

  Component _buildOrderTrackerModal() {
    final result = searchedOrderResult;
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-dark text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-geo-alt-fill text-danger fs-5', []),
              Component.text('Lacak Status Pesanan (Public Order Tracker)'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showOrderTrackerModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-light', [
            div(classes: 'card border-0 shadow-sm rounded-3 p-3 bg-white mb-4', [
              label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Masukkan Nomor Invoice / Referensi Order / No HP:'),]),
              div(classes: 'input-group input-group-lg', [
                span(classes: 'input-group-text bg-light', [i(classes: 'bi bi-search text-danger', []),]),
                input(
                  type: InputType.text,
                  classes: 'form-control fs-6',
                  value: orderTrackerQuery,
                  attributes: {'placeholder': 'Contoh: INV/20260915/RJT/001 atau 081234567890'},
                  events: {
                    'input': (e) {
                      setState(() {
                        orderTrackerQuery = (e.target as html.InputElement).value ?? '';
                      });
                    },
                    'keyup': (e) {
                      if ((e as html.KeyboardEvent).keyCode == 13) {
                        _searchOrderTracker();
                      }
                    }
                  },
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-danger px-4 fw-bold fs-7',
                  events: {'click': (e) => _searchOrderTracker()},
                  [Component.text('Cari Status')],
                ),
              ]),
              small(classes: 'text-muted mt-2 fs-8', [
                Component.text('Tips: Nomor Invoice tertera pada rincian pesan WhatsApp saat Anda melakukan checkout.'),
              ]),
            ]),

            if (orderSearchAttempted) ...[
              if (result == null)
                div(classes: 'alert alert-warning rounded-3 border-warning shadow-sm p-4 text-center', [
                  i(classes: 'bi bi-exclamation-circle-fill fs-2 text-warning mb-2 d-block', []),
                  h6(classes: 'fw-bold text-dark mb-1', [Component.text('Pesanan Tidak Ditemukan')]),
                  p(classes: 'text-muted fs-7 mb-0', [
                    Component.text('Pastikan Nomor Invoice atau Nomor HP yang dimasukkan sudah benar dan sesuai dengan data transaksi Anda.'),
                  ]),
                ])
              else ...[
                div(classes: 'card border-0 shadow-sm rounded-4 bg-white p-4', [
                  div(classes: 'd-flex align-items-center justify-content-between border-bottom pb-3 mb-3 flex-wrap gap-2', [
                    div([
                      span(classes: 'badge bg-secondary-subtle text-dark me-2 fs-8 fw-bold', [Component.text(result.orderNo)]),
                      h5(classes: 'fw-extrabold text-dark mb-0 d-inline', [Component.text(result.customerName)]),
                    ]),
                    span(classes: 'badge ${result.status == 'Selesai' ? 'bg-success' : result.status == 'Dikirim' ? 'bg-primary' : result.status == 'Diproses' ? 'bg-info text-dark' : result.status == 'Dibatalkan' ? 'bg-danger' : 'bg-warning text-dark'} rounded-pill px-3 py-2 fs-7 fw-bold', [
                      Component.text('Status: ${result.status}'),
                    ]),
                  ]),

                  // Timeline Tracker
                  div(classes: 'mb-4', [
                    h6(classes: 'fw-bold text-muted fs-8 text-uppercase mb-3', [Component.text('Timeline Progress Pengemasan & Pengiriman')]),
                    div(classes: 'd-flex justify-content-between align-items-center position-relative px-2', [
                      _buildTimelineStep('Pending', 'Pesanan Masuk', result.status),
                      _buildTimelineStep('Diproses', 'Dalam Rajutan', result.status),
                      _buildTimelineStep('Dikirim', 'Ekspedisi Kirim', result.status),
                      _buildTimelineStep('Selesai', 'Diterima', result.status),
                    ]),
                  ]),

                  if (result.trackingNo.isNotEmpty)
                    div(classes: 'alert alert-info rounded-3 p-3 d-flex align-items-center justify-content-between mb-3', [
                      div([
                        small(classes: 'text-muted d-block fs-8', [Component.text('Nomor Resi / No. Tracking Kurir (${result.courier}):')]),
                        span(classes: 'fw-bold fs-6 text-primary', [Component.text(result.trackingNo)]),
                      ]),
                      span(classes: 'badge bg-info text-dark rounded-pill', [Component.text('Resi Aktif')]),
                    ]),

                  h6(classes: 'fw-bold text-dark fs-7 mb-2', [Component.text('Rincian Item Pesanan:')]),
                  ul(classes: 'list-group list-group-flush mb-3 border rounded-3', [
                    for (var item in result.items)
                      li(classes: 'list-group-item d-flex justify-content-between align-items-center fs-7', [
                        div([
                          span(classes: 'fw-semibold text-dark', [Component.text(item.productName)]),
                          if (item.customColor.isNotEmpty || item.yarnType.isNotEmpty)
                            span(classes: 'badge bg-danger-subtle text-danger ms-2 fs-8', [
                              Component.text('${item.yarnType} • ${item.customColor}'),
                            ]),
                          if (item.customNotes.isNotEmpty)
                            small(classes: 'text-muted d-block fs-8 fst-italic', [Component.text('Notes: ${item.customNotes}')]),
                        ]),
                        span(classes: 'fw-bold text-dark', [Component.text('${item.qty}x Rp ${item.price.toInt()}')]),
                      ]),
                  ]),

                  div(classes: 'd-flex justify-content-between align-items-center pt-2 border-top fw-bold', [
                    span(classes: 'text-dark fs-6', [Component.text('Total Tagihan:')]),
                    span(classes: 'text-danger fs-5 fw-extrabold', [Component.text('Rp ${result.total.toInt()}')]),
                  ]),
                ]),
              ],
            ],
          ]),
          div(classes: 'modal-footer bg-white py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary rounded-pill px-4 fw-semibold',
              events: {'click': (e) => setState(() => showOrderTrackerModal = false)},
              [Component.text('Tutup')],
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildTimelineStep(String stepKey, String label, String currentStatus) {
    final statusOrder = ['Pending', 'Diproses', 'Dikirim', 'Selesai'];
    final currentIdx = statusOrder.indexOf(currentStatus);
    final stepIdx = statusOrder.indexOf(stepKey);
    final isDone = currentIdx >= stepIdx;

    return div(classes: 'text-center z-1', [
      div(classes: 'rounded-circle d-flex align-items-center justify-content-center mx-auto mb-1 ${isDone ? 'bg-danger text-white shadow-sm' : 'bg-secondary-subtle text-muted'}', styles: Styles(width: 36.px, height: 36.px), [
        i(classes: 'bi ${isDone ? 'bi-check-lg' : 'bi-circle'} fs-6', []),
      ]),
      small(classes: 'd-block fw-bold fs-8 ${isDone ? 'text-dark' : 'text-muted'}', [Component.text(label)]),
    ]);
  }

  Component _buildWriteReviewModal() {
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-danger text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-pencil-square fs-5', []),
              Component.text('Tulis Ulasan & Rating Pembeli'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showWriteReviewModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-white', [
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Nama Lengkap Anda:'),]),
              input(
                type: InputType.text,
                classes: 'form-control fs-7',
                value: reviewNameInput,
                attributes: {'placeholder': 'Contoh: Siti Rahmawati'},
                events: {
                  'input': (e) {
                    setState(() {
                      reviewNameInput = (e.target as html.InputElement).value ?? '';
                    });
                  }
                },
              ),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Produk Yang Dibeli:'),]),
              select(
                classes: 'form-select fs-7',
                events: {
                  'change': (e) {
                    setState(() {
                      reviewProductInput = (e.target as html.SelectElement).value ?? '';
                    });
                  }
                },
                [
                  for (var p in AppStore().products)
                    option(value: p.name, selected: reviewProductInput == p.name, [Component.text(p.name)]),
                ],
              ),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Beri Rating Bintang (1-5):'),]),
              div(classes: 'd-flex gap-2 text-warning fs-4 cursor-pointer', [
                for (var star = 1; star <= 5; star++)
                  i(
                    classes: 'bi ${star <= reviewRatingInput ? 'bi-star-fill text-warning' : 'bi-star text-muted'}',
                    events: {'click': (e) => setState(() => reviewRatingInput = star)},
                    [],
                  ),
              ]),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Ulasan / Pengalaman Pembelian:'),]),
              textarea(
                classes: 'form-control fs-7',
                attributes: {'rows': '3', 'placeholder': 'Tulis ulasan Anda mengenai kehalusan rajutan, kerapian, dan kepuasan pelayanan...'},
                events: {
                  'input': (e) {
                    setState(() {
                      reviewCommentInput = (e.target as html.TextAreaElement).value ?? '';
                    });
                  }
                },
                [Component.text(reviewCommentInput)],
              ),
            ]),
          ]),
          div(classes: 'modal-footer bg-light py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary rounded-pill px-4 fw-semibold',
              events: {'click': (e) => setState(() => showWriteReviewModal = false)},
              [Component.text('Batal')],
            ),
            button(
              type: ButtonType.button,
              classes: 'btn btn-danger rounded-pill px-4 fw-bold shadow-sm',
              events: {'click': (e) => _submitBuyerReview()},
              [Component.text('Kirim Ulasan')],
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildWishlistModal() {
    final store = AppStore();
    final wishlistedProducts = store.products.where((item) => store.wishlistProductIds.contains(item.id)).toList();

    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-danger text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-heart-fill fs-5', []),
              Component.text('Wishlist & Favorit Saya'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showWishlistModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-light', [
            if (wishlistedProducts.isEmpty)
              div(classes: 'text-center py-5 text-muted', [
                i(classes: 'bi bi-heartbreak fs-1 text-secondary mb-2 d-block', []),
                p(classes: 'fs-6 fw-semibold mb-1', [Component.text('Belum ada produk favorit di wishlist Anda.')]),
                small([Component.text('Klik ikon hati pada produk di katalog untuk menyimpannya di sini.')]),
              ])
            else
              div(classes: 'row g-3', [
                for (var item in wishlistedProducts)
                  div(classes: 'col-md-6', [
                    div(classes: 'card border-0 shadow-sm rounded-3 p-3 bg-white d-flex flex-row align-items-center gap-3', [
                      img(
                        src: item.image,
                        classes: 'rounded-3 border object-fit-cover',
                        attributes: {'width': '70', 'height': '70', 'alt': item.name},
                      ),
                      div(classes: 'flex-grow-1', [
                        h6(classes: 'fw-bold text-dark fs-7 mb-1 text-truncate max-w-180px', [Component.text(item.name)]),
                        div(classes: 'text-danger fw-extrabold fs-7 mb-2', [Component.text('Rp ${item.price.toInt()}')]),
                        div(classes: 'd-flex gap-2', [
                          button(
                            type: ButtonType.button,
                            classes: 'btn btn-danger btn-sm rounded-pill fs-8 fw-semibold px-2',
                            events: {
                              'click': (e) {
                                _addToCart({'id': item.id, 'name': item.name, 'price': item.price.toInt(), 'image': item.image});
                              }
                            },
                            [
                              i(classes: 'bi bi-cart-plus me-1', []),
                              Component.text('+ Keranjang'),
                            ],
                          ),
                          button(
                            type: ButtonType.button,
                            classes: 'btn btn-outline-secondary btn-sm rounded-circle p-1 me-1',
                            events: {
                              'click': (e) {
                                setState(() {
                                  store.toggleWishlist(item.id);
                                });
                              }
                            },
                            [i(classes: 'bi bi-trash text-danger fs-7', [])],
                          ),
                        ]),
                      ]),
                    ]),
                  ]),
              ]),
          ]),
          div(classes: 'modal-footer bg-white py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary rounded-pill px-4 fw-semibold',
              events: {'click': (e) => setState(() => showWishlistModal = false)},
              [Component.text('Tutup Wishlist')],
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildMemberModal() {
    final store = AppStore();
    final member = store.currentMember;

    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-primary text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-person-badge-fill fs-5', []),
              Component.text('Portal Member & E-Card Digital Abel\'z Handmade'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showMemberModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-pink-cream', [
            if (member != null) ...[
              // Member Dashboard Tabs Header
              div(classes: 'nav nav-pills nav-fill mb-4 bg-white p-1.5 rounded-pill border border-light-subtle shadow-xs', [
                button(
                  type: ButtonType.button,
                  classes: 'nav-link rounded-pill ${activeMemberTab == 'history' ? 'active bg-terracotta text-white fw-bold' : 'text-espresso'} fs-7',
                  events: {'click': (e) => setState(() => activeMemberTab = 'history')},
                  [
                    i(classes: 'bi bi-clock-history me-1', []),
                    Component.text('Histori Transaksi & Lacak'),
                  ],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'nav-link rounded-pill ${activeMemberTab == 'products' ? 'active bg-terracotta text-white fw-bold' : 'text-espresso'} fs-7',
                  events: {'click': (e) => setState(() => activeMemberTab = 'products')},
                  [
                    i(classes: 'bi bi-bag-heart-fill me-1', []),
                    Component.text('Produk Saya'),
                  ],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'nav-link rounded-pill ${activeMemberTab == 'ecard' ? 'active bg-terracotta text-white fw-bold' : 'text-espresso'} fs-7',
                  events: {'click': (e) => setState(() => activeMemberTab = 'ecard')},
                  [
                    i(classes: 'bi bi-person-vcard-fill me-1', []),
                    Component.text('E-Card Member'),
                  ],
                ),
              ]),

              // TAB 1: HISTORI TRANSAKSI & LACAK PRODUK
              if (activeMemberTab == 'history') ...[
                div(classes: 'card-genz border-0 p-3 bg-white mb-3', [
                  h6(classes: 'font-serif-heading fw-bold text-espresso fs-6 mb-3 d-flex align-items-center justify-content-between', [
                    span([
                      i(classes: 'bi bi-receipt me-2 text-terracotta', []),
                      Component.text('Daftar Transaksi & Riwayat Pesanan Saya'),
                    ]),
                    span(classes: 'badge bg-terracotta text-white rounded-pill fs-8', [Component.text('${store.orders.length} Transaksi')]),
                  ]),
                  if (store.orders.isEmpty)
                    div(classes: 'text-center py-4 text-espresso-muted', [
                      i(classes: 'bi bi-inbox fs-1 text-muted mb-2 d-block', []),
                      p(classes: 'fs-7 mb-0', [Component.text('Belum ada riwayat transaksi.')]),
                    ])
                  else
                    div(classes: 'd-flex flex-column gap-3', [
                      for (var order in store.orders)
                        div(classes: 'card border border-light-subtle rounded-3 p-3 bg-soft-card shadow-xs', [
                          div(classes: 'd-flex flex-wrap justify-content-between align-items-center border-bottom pb-2 mb-2', [
                            div([
                              span(classes: 'fw-bold text-espresso fs-7 me-2', [Component.text(order.orderNo)]),
                              small(classes: 'text-espresso-muted fs-8', [Component.text(order.date)]),
                            ]),
                            span(classes: 'badge ${order.status == 'Selesai' ? 'bg-success' : order.status == 'Dikirim' ? 'bg-info' : 'bg-warning text-dark'} rounded-pill px-3 py-1 fs-8', [
                              Component.text(order.status),
                            ]),
                          ]),
                          div(classes: 'row align-items-center g-2 fs-7', [
                            div(classes: 'col-md-7', [
                              div(classes: 'fw-semibold text-espresso', [
                                Component.text('${order.items.length} Barang: ${order.items.map((e) => e.productName).join(', ')}'),
                              ]),
                              small(classes: 'text-espresso-muted', [
                                Component.text('Kurir: ${order.courier} • Payment: ${order.paymentMethod}'),
                              ]),
                            ]),
                            div(classes: 'col-md-5 text-md-end', [
                              div(classes: 'fw-extrabold text-terracotta fs-6 mb-2', [
                                Component.text('Rp ${order.total.toInt()}'),
                              ]),
                              button(
                                type: ButtonType.button,
                                classes: 'btn btn-terracotta btn-sm rounded-pill px-3 py-1 fs-8 fw-bold d-inline-flex align-items-center gap-1',
                                events: {
                                  'click': (e) {
                                    setState(() {
                                      showMemberModal = false;
                                      orderTrackerQuery = order.orderNo;
                                      _searchOrderTracker();
                                      showOrderTrackerModal = true;
                                    });
                                  }
                                },
                                [
                                  i(classes: 'bi bi-geo-alt-fill me-1', []),
                                  Component.text('Lacak Produk 🚚'),
                                ],
                              ),
                            ]),
                          ]),
                        ]),
                    ]),
                ]),
              ]
              // TAB 2: PRODUK SAYA & FAVORIT
              else if (activeMemberTab == 'products') ...[
                div(classes: 'card-genz border-0 p-3 bg-white mb-3', [
                  h6(classes: 'font-serif-heading fw-bold text-espresso fs-6 mb-3 d-flex align-items-center justify-content-between', [
                    span([
                      i(classes: 'bi bi-heart-fill me-2 text-rose-pink', []),
                      Component.text('Katalog & Wishlist Produk Favorit Saya'),
                    ]),
                    span(classes: 'badge bg-rose-pink text-white rounded-pill fs-8', [Component.text('${store.wishlistProductIds.length} Produk Saved')]),
                  ]),
                  if (store.wishlistProductIds.isEmpty)
                    div(classes: 'text-center py-4 text-espresso-muted', [
                      i(classes: 'bi bi-heartbreak fs-1 text-muted mb-2 d-block', []),
                      p(classes: 'fs-7 mb-0', [Component.text('Belum ada produk favorit disukai.')]),
                    ])
                  else
                    div(classes: 'row g-3', [
                      for (var prod in store.products.where((p) => store.wishlistProductIds.contains(p.id)))
                        div(classes: 'col-md-6', [
                          div(classes: 'card border border-light-subtle rounded-3 p-2 bg-soft-card d-flex flex-row align-items-center gap-3', [
                            img(src: prod.image, classes: 'rounded-3 object-fit-cover', attributes: {'width': '70', 'height': '70', 'alt': prod.name}),
                            div(classes: 'flex-grow-1', [
                              h6(classes: 'fw-bold text-espresso fs-7 mb-1 text-truncate', [Component.text(prod.name)]),
                              div(classes: 'fw-bold text-terracotta fs-7 mb-2', [Component.text('Rp ${prod.price.toInt()}')]),
                              button(
                                type: ButtonType.button,
                                classes: 'btn btn-sage btn-sm rounded-pill fs-8 fw-semibold px-3 py-1',
                                events: {
                                  'click': (e) {
                                    _addToCart({'id': prod.id, 'name': prod.name, 'price': prod.price.toInt(), 'image': prod.image});
                                  }
                                },
                                [
                                  i(classes: 'bi bi-cart-plus me-1', []),
                                  Component.text('+ Keranjang'),
                                ],
                              ),
                            ]),
                          ]),
                        ]),
                    ]),
                ]),
              ]
              // TAB 3: DIGITAL E-CARD MEMBER & BENEFIT
              else ...[
                // Digital E-Card Member Card
                div(
                  classes: 'card border-0 shadow-lg rounded-4 p-4 text-white mb-4 position-relative overflow-hidden',
                  attributes: {'style': 'background: linear-gradient(135deg, #2D2424 0%, #C87D55 60%, #94AFA0 100%);'},
                  [
                    div(classes: 'd-flex justify-content-between align-items-start mb-3', [
                      div([
                        span(classes: 'badge bg-white text-dark rounded-pill px-3 py-1 fs-8 fw-extrabold mb-1 shadow-xs', [
                          Component.text('🧶 MEMBER E-CARD OFFICIAL'),
                        ]),
                        h4(classes: 'fw-extrabold mb-0 text-white tracking-wide font-serif-heading', [Component.text(member.name)]),
                        small(classes: 'text-white-50 fs-8', [Component.text('ID: ${member.id} • Terdaftar sejak ${member.registeredDate}')]),
                      ]),
                      span(classes: 'badge bg-warning text-dark border border-warning rounded-pill px-3 py-2 fs-7 fw-extrabold shadow-sm', [
                        i(classes: 'bi bi-star-fill me-1', []),
                        Component.text(member.level),
                      ]),
                    ]),
                    div(classes: 'row g-3 align-items-center border-top border-white border-opacity-25 pt-3 mt-1', [
                      div(classes: 'col-6', [
                        small(classes: 'text-white-50 d-block fs-8 text-uppercase fw-bold', [Component.text('Saldo Poin Belanja:')]),
                        span(classes: 'fs-3 fw-extrabold text-warning', [Component.text('${member.points} Poin ⭐')]),
                      ]),
                      div(classes: 'col-6 text-end', [
                        small(classes: 'text-white-50 d-block fs-8 text-uppercase fw-bold', [Component.text('Benefit Diskon Member:')]),
                        span(classes: 'fs-4 fw-bold text-white', [Component.text('${member.discountPercent.toInt()}% Off All Products')]),
                      ]),
                    ]),
                  ],
                ),

                // Benefits Summary Card
                div(classes: 'card-genz border-0 p-3 bg-white mb-4', [
                  h6(classes: 'fw-bold text-espresso fs-7 mb-2 font-serif-heading', [Component.text('Keuntungan Eksklusif Keanggotaan Anda:')]),
                  div(classes: 'row g-2 fs-7 text-espresso-muted', [
                    div(classes: 'col-md-6 d-flex align-items-center gap-2', [
                      i(classes: 'bi bi-patch-check-fill text-success', []),
                      span([Component.text('Diskon Otomatis ${member.discountPercent.toInt()}% di setiap keranjang')]),
                    ]),
                    div(classes: 'col-md-6 d-flex align-items-center gap-2', [
                      i(classes: 'bi bi-star-fill text-warning', []),
                      span([Component.text('Kumpul Poin: Rp 10.000 = 1 Poin Belanja')]),
                    ]),
                    div(classes: 'col-md-6 d-flex align-items-center gap-2 mt-2', [
                      i(classes: 'bi bi-lightning-charge-fill text-danger', []),
                      span([Component.text('Prioritas Antrean PO Rajutan Custom')]),
                    ]),
                    div(classes: 'col-md-6 d-flex align-items-center gap-2 mt-2', [
                      i(classes: 'bi bi-gift-fill text-primary', []),
                      span([Component.text('Bonus Poin Ulang Tahun & Flash Sale')]),
                    ]),
                  ]),
                ]),

                // Logout Button
                div(classes: 'text-end', [
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-outline-danger rounded-pill px-4 fw-semibold fs-7',
                    events: {
                      'click': (e) {
                        setState(() {
                          store.logoutMember();
                        });
                      }
                    },
                    [
                      i(classes: 'bi bi-box-arrow-right me-1', []),
                      Component.text('Keluar dari Akun Member'),
                    ],
                  ),
                ]),
              ],
            ] else ...[
              // LOGIN / REGISTER FORM FOR GUEST
              div(classes: 'nav nav-pills nav-fill mb-3 bg-white p-1 rounded-pill border shadow-xs', [
                button(
                  type: ButtonType.button,
                  classes: 'nav-link rounded-pill ${!isRegisteringMember ? 'active bg-primary text-white fw-bold' : 'text-dark'} fs-7',
                  events: {'click': (e) => setState(() => isRegisteringMember = false)},
                  [Component.text('Login Member')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'nav-link rounded-pill ${isRegisteringMember ? 'active bg-primary text-white fw-bold' : 'text-dark'} fs-7',
                  events: {'click': (e) => setState(() => isRegisteringMember = true)},
                  [Component.text('Daftar Member Baru (+100 Poin)')],
                ),
              ]),

              if (memberErrorMsg.isNotEmpty)
                div(classes: 'alert alert-danger rounded-3 py-2 px-3 fs-7 mb-3', [
                  i(classes: 'bi bi-exclamation-triangle-fill me-1', []),
                  Component.text(memberErrorMsg),
                ]),

              if (!isRegisteringMember) ...[
                // LOGIN FORM
                div(classes: 'card border-0 shadow-sm rounded-4 p-4 bg-white', [
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Email atau No. Telepon Member:')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control fs-7',
                      value: memberEmailInput,
                      attributes: {'placeholder': 'Contoh: siti@gmail.com / 081234567890'},
                      events: {'input': (e) => memberEmailInput = (e.target as html.InputElement).value ?? ''},
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Password Member:')]),
                    input(
                      type: InputType.password,
                      classes: 'form-control fs-7',
                      value: memberPasswordInput,
                      attributes: {'placeholder': 'Masukkan password (default: 123456)'},
                      events: {'input': (e) => memberPasswordInput = (e.target as html.InputElement).value ?? ''},
                    ),
                  ]),
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-primary rounded-pill w-100 py-2 fw-bold fs-6 shadow-sm',
                    events: {
                      'click': (e) {
                        final success = store.loginMember(emailOrPhone: memberEmailInput, password: memberPasswordInput);
                        setState(() {
                          if (success) {
                            memberErrorMsg = '';
                          } else {
                            memberErrorMsg = 'Email/No HP atau password salah. Coba: siti@gmail.com / 123456';
                          }
                        });
                      }
                    },
                    [
                      i(classes: 'bi bi-box-arrow-in-right me-1', []),
                      Component.text('Masuk ke Dashboard Member'),
                    ],
                  ),
                  small(classes: 'text-muted text-center d-block mt-3 fs-8', [
                    Component.text('Demo Akun Member: Email siti@gmail.com / Password: 123456'),
                  ]),
                ]),
              ] else ...[
                // REGISTER FORM
                div(classes: 'card border-0 shadow-sm rounded-4 p-4 bg-white', [
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Nama Lengkap:')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control fs-7',
                      value: memberNameInput,
                      attributes: {'placeholder': 'Nama Lengkap Pembeli'},
                      events: {'input': (e) => memberNameInput = (e.target as html.InputElement).value ?? ''},
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Email:')]),
                    input(
                      type: InputType.email,
                      classes: 'form-control fs-7',
                      value: memberEmailInput,
                      attributes: {'placeholder': 'email@example.com'},
                      events: {'input': (e) => memberEmailInput = (e.target as html.InputElement).value ?? ''},
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('No. WhatsApp / Telepon:')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control fs-7',
                      value: memberPhoneInput,
                      attributes: {'placeholder': '081234567890'},
                      events: {'input': (e) => memberPhoneInput = (e.target as html.InputElement).value ?? ''},
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-bold text-dark fs-7', [Component.text('Password:')]),
                    input(
                      type: InputType.password,
                      classes: 'form-control fs-7',
                      value: memberPasswordInput,
                      attributes: {'placeholder': 'Buat password'},
                      events: {'input': (e) => memberPasswordInput = (e.target as html.InputElement).value ?? ''},
                    ),
                  ]),
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-success rounded-pill w-100 py-2 fw-bold fs-6 shadow-sm',
                    events: {
                      'click': (e) {
                        if (memberNameInput.trim().isEmpty || memberEmailInput.trim().isEmpty || memberPhoneInput.trim().isEmpty) {
                          setState(() => memberErrorMsg = 'Mohon lengkapi semua data pendaftaran.');
                          return;
                        }
                        store.registerMember(
                          name: memberNameInput,
                          email: memberEmailInput,
                          phone: memberPhoneInput,
                          password: memberPasswordInput.isEmpty ? '123456' : memberPasswordInput,
                        );
                        setState(() {
                          memberErrorMsg = '';
                          toastMessageText = 'Selamat! Pendaftaran Member berhasil. Anda mendapatkan 100 Poin Bonus & Diskon Member!';
                          showSuccessToast = true;
                        });
                      }
                    },
                    [
                      i(classes: 'bi bi-gift-fill me-1', []),
                      Component.text('Daftar Member & Klaim 100 Poin'),
                    ],
                  ),
                ]),
              ],
            ],
          ]),
          div(classes: 'modal-footer bg-white py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary rounded-pill px-4 fw-semibold',
              events: {'click': (e) => setState(() => showMemberModal = false)},
              [Component.text('Tutup')],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}

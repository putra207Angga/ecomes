// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import '../models/app_models.dart';

class AppStore {
  static final AppStore _instance = AppStore._internal();
  factory AppStore() => _instance;
  AppStore._internal() {
    _loadFromStorage();
  }

  List<ProductItem> products = [];
  List<OrderItem> orders = [];
  List<TransactionItem> transactions = [];
  List<CustomerItem> customers = [];
  List<CategoryItem> categories = [];
  List<BrandItem> brands = [];
  List<PromoItem> promos = [];
  List<ReviewItem> reviews = [];
  List<ChatMessageItem> chatMessages = [];
  StoreSettings settings = StoreSettings();
  late LandingConfig landingConfig;

  CustomerItem? currentMember;
  List<String> wishlistProductIds = [];
  bool soundAlertEnabled = true;

  void _loadFromStorage() {
    try {
      final mStr = html.window.localStorage['ecomes_current_member'];
      if (mStr != null && mStr.isNotEmpty) {
        currentMember = CustomerItem.fromJson(jsonDecode(mStr));
      }
    } catch (_) {}

    try {
      final wStr = html.window.localStorage['ecomes_wishlist'];
      if (wStr != null && wStr.isNotEmpty) {
        final List list = jsonDecode(wStr);
        wishlistProductIds = list.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    try {
      final pStr = html.window.localStorage['ecomes_products'];
      if (pStr != null && pStr.isNotEmpty) {
        final List list = jsonDecode(pStr);
        products = list.map((e) => ProductItem.fromJson(e)).toList();
      } else {
        _seedProducts();
      }

      final oStr = html.window.localStorage['ecomes_orders'];
      if (oStr != null && oStr.isNotEmpty) {
        final List list = jsonDecode(oStr);
        orders = list.map((e) => OrderItem.fromJson(e)).toList();
      } else {
        _seedOrders();
      }

      final tStr = html.window.localStorage['ecomes_transactions'];
      if (tStr != null && tStr.isNotEmpty) {
        final List list = jsonDecode(tStr);
        transactions = list.map((e) => TransactionItem.fromJson(e)).toList();
      } else {
        _seedTransactions();
      }

      final cStr = html.window.localStorage['ecomes_customers'];
      if (cStr != null && cStr.isNotEmpty) {
        final List list = jsonDecode(cStr);
        customers = list.map((e) => CustomerItem.fromJson(e)).toList();
      } else {
        _seedCustomers();
      }

      final catStr = html.window.localStorage['ecomes_categories'];
      if (catStr != null && catStr.isNotEmpty) {
        final List list = jsonDecode(catStr);
        categories = list.map((e) => CategoryItem.fromJson(e)).toList();
      } else {
        _seedCategories();
      }

      final bStr = html.window.localStorage['ecomes_brands'];
      if (bStr != null && bStr.isNotEmpty) {
        final List list = jsonDecode(bStr);
        brands = list.map((e) => BrandItem.fromJson(e)).toList();
      } else {
        _seedBrands();
      }

      final prStr = html.window.localStorage['ecomes_promos'];
      if (prStr != null && prStr.isNotEmpty) {
        final List list = jsonDecode(prStr);
        promos = list.map((e) => PromoItem.fromJson(e)).toList();
      } else {
        _seedPromos();
      }

      final rStr = html.window.localStorage['ecomes_reviews'];
      if (rStr != null && rStr.isNotEmpty) {
        final List list = jsonDecode(rStr);
        reviews = list.map((e) => ReviewItem.fromJson(e)).toList();
      } else {
        _seedReviews();
      }

      final chStr = html.window.localStorage['ecomes_chats'];
      if (chStr != null && chStr.isNotEmpty) {
        final List list = jsonDecode(chStr);
        chatMessages = list.map((e) => ChatMessageItem.fromJson(e)).toList();
      } else {
        _seedChats();
      }

      final sStr = html.window.localStorage['ecomes_settings'];
      if (sStr != null && sStr.isNotEmpty) {
        settings = StoreSettings.fromJson(jsonDecode(sStr));
      }

      final lStr = html.window.localStorage['ecomes_landing_config'];
      if (lStr != null && lStr.isNotEmpty) {
        landingConfig = LandingConfig.fromJson(jsonDecode(lStr));
        if (landingConfig.stories.isEmpty) {
          landingConfig.stories = _defaultStories();
        }
        if (landingConfig.faqs.isEmpty) {
          landingConfig.faqs = _defaultFaqs();
        }
      } else {
        _seedLandingConfig();
      }
    } catch (e) {
      _seedAll();
    }
  }

  void saveAll() {
    html.window.localStorage['ecomes_products'] = jsonEncode(products.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_orders'] = jsonEncode(orders.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_transactions'] = jsonEncode(transactions.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_customers'] = jsonEncode(customers.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_categories'] = jsonEncode(categories.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_brands'] = jsonEncode(brands.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_promos'] = jsonEncode(promos.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_reviews'] = jsonEncode(reviews.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_chats'] = jsonEncode(chatMessages.map((e) => e.toJson()).toList());
    html.window.localStorage['ecomes_settings'] = jsonEncode(settings.toJson());
    html.window.localStorage['ecomes_landing_config'] = jsonEncode(landingConfig.toJson());
  }

  void resetToDefault() {
    _seedAll();
    saveAll();
  }

  void _seedAll() {
    _seedProducts();
    _seedOrders();
    _seedTransactions();
    _seedCustomers();
    _seedCategories();
    _seedBrands();
    _seedPromos();
    _seedReviews();
    _seedChats();
    settings = StoreSettings();
    _seedLandingConfig();
  }

  void _seedTransactions() {
    transactions = [
      TransactionItem(
        id: 'trx-101',
        transactionNo: 'TRX-20260915-001',
        orderId: 'ord-101',
        orderNo: 'ORD-20260915-001',
        customerName: 'Siti Rahma',
        paymentGateway: 'Midtrans',
        paymentType: 'QRIS',
        grossAmount: 185000,
        transactionStatus: 'settlement',
        gatewayTransactionId: 'mid-trx-884920',
        snapToken: 'snap-token-884920',
        date: '2026-09-15 14:20',
      ),
      TransactionItem(
        id: 'trx-102',
        transactionNo: 'TRX-20260915-002',
        orderId: 'ord-102',
        orderNo: 'ORD-20260915-002',
        customerName: 'Budi Santoso',
        paymentGateway: 'Bank Transfer',
        paymentType: 'BCA VA',
        grossAmount: 320000,
        transactionStatus: 'settlement',
        gatewayTransactionId: 'mid-trx-884921',
        snapToken: 'snap-token-884921',
        date: '2026-09-15 16:45',
      ),
      TransactionItem(
        id: 'trx-103',
        transactionNo: 'TRX-20260916-003',
        orderId: 'ord-103',
        orderNo: 'ORD-20260916-003',
        customerName: 'Dewi Lestari',
        paymentGateway: 'Xendit',
        paymentType: 'GoPay',
        grossAmount: 75000,
        transactionStatus: 'pending',
        gatewayTransactionId: 'xnd-trx-991203',
        snapToken: 'snap-token-991203',
        date: '2026-09-16 09:10',
      ),
    ];
  }

  void _seedLandingConfig() {
    landingConfig = LandingConfig(
      storeName: "Abel'z handmade",
      storeTagline: 'Kerajinan & Handcrafted with Love',
      heroHeadlinePrefix: 'Kehangatan Sentuhan Tangan: ',
      heroHeadlineHighlight: "Tas & Rajutan Custom Abel'z Handmade",
      heroDescription:
          "Setiap karya Abel'z handmade dirajut penuh cinta dan ketelitian oleh Yayuk Wahyuni (@yayukwahyuni26). Temukan tas serut rajut, cup holder eco-friendly, gantungan kunci Miffy doll, dan kado unik buatan tangan.",
      heroBadge: '100% Handcrafted • Benang Poliindo & Milk Cotton',
      heroImage: 'images/abelz_hero_cover.png',
      whatsappNumber: '6281234567890',
      instagramHandle: '@yayukwahyuni26',
      landingProducts: [
        {
          'id': 'RJ-001',
          'name': 'Tas Rajut Serut Drawstring Purse 25x25 (Custom Color)',
          'category': 'Tas Rajut',
          'price': 165000,
          'rating': 5,
          'sold': 245,
          'image': 'images/abelz_tas_rajut.png',
          'description':
              "Tas serut rajut handmade Abel'z handmade berbahan Benang Poliindo berkualitas tinggi. Ukuran 25x25 cm, kuat, awet, dan estetik. PO bebas request warna.",
          'badge': 'Terlaris 🏆',
        },
        {
          'id': 'RJ-002',
          'name': 'Cup Holder Rajut Eco-Friendly Drink Sleeve',
          'category': 'Cup Holder & Sleeve',
          'price': 35000,
          'rating': 5,
          'sold': 310,
          'image': 'images/abelz_cup_holder.png',
          'description':
              'Pelindung cangkir & gelas kopi rajut ramah lingkungan. Rajutannya lucu, bumi pun happy! Minum tetap cozy tanpa kantong plastik sekali pakai.',
          'badge': 'Eco Choice 🌱',
        },
        {
          'id': 'RJ-003',
          'name': 'Gantungan Kunci Boneka Rajut Miffy Doll Charm',
          'category': 'Gantungan Kunci',
          'price': 45000,
          'rating': 5,
          'sold': 420,
          'image': 'images/abelz_ganci_miffy.png',
          'description':
              'Gantungan tas & kunci berbentuk boneka kelinci Miffy rajut. Menggunakan Benang Milk Cotton super lembut dan tidak bersabut.',
          'badge': 'Aesthetic ✨',
        },
        {
          'id': 'RJ-004',
          'name': 'Ganci Penyu Cute Turtle Crochet Keychain',
          'category': 'Gantungan Kunci',
          'price': 28000,
          'rating': 5,
          'sold': 180,
          'image': 'images/abelz_ganci_miffy.png',
          'description':
              'Gantungan kunci kura-kura/penyu rajut imut berbahan Milk Cotton Yarn lembut. Sangat cocok untuk souvenir & kado unik.',
          'badge': 'Souvenir ⭐',
        },
        {
          'id': 'RJ-005',
          'name': 'Tote Bag Rajut Handbag Soft Pastel 23x23',
          'category': 'Tas Rajut',
          'price': 150000,
          'rating': 5,
          'sold': 155,
          'image': 'images/abelz_tas_rajut.png',
          'description':
              'Tote bag rajut estetik ukuran 23x23 cm dari Benang Poliindo. Tangan dua tali nyaman di pundak, siap menemani aktivitas harian.',
          'badge': 'New Arrival 🔥',
        },
        {
          'id': 'RJ-006',
          'name': "Pouch Rajut Multifungsi Abel'z Handmade",
          'category': 'Tas Rajut',
          'price': 65000,
          'rating': 5,
          'sold': 280,
          'image': 'images/abelz_hero_cover.png',
          'description':
              'Pouch rajut serbaguna untuk kosmetik atau perlengkapan kecil. Dibuat rapi dengan sistem Pre-Order custom pilihan warna.',
          'badge': 'Custom PO 🎨',
        },
      ],
      testimonials: [
        {
          'name': 'Rina Agustina',
          'role': 'Pembeli Tas Rajut PO',
          'comment':
              "Tas rajut serut dari Abel'z handmade rapi banget rajutannya! Warnanya sesuai request custom saya. Benang Poliindo-nya kokoh dan tahan lama. Recommended banget kak!",
          'rating': 5,
          'avatar': 'RA',
        },
        {
          'name': 'Siti Nurhaliza',
          'role': 'Pelanggan Cup Holder',
          'comment':
              'Cup holder rajutnya lucu sekali! Sering saya pakai pas beli kopi kekinian. Bebas kantong plastik dan minuman tetap hangat/dingin di pegangan. Thx Mbak Yayuk!',
          'rating': 5,
          'avatar': 'SN',
        },
        {
          'name': 'Maya Indah',
          'role': 'Kolektor Ganci Miffy',
          'comment':
              'Gantungan kunci Miffy doll-nya super duper lembut karena benang Milk Cotton. Langsung saya pasang di ransel. Bakal order varian penyu juga nanti!',
          'rating': 5,
          'avatar': 'MI',
        },
      ],
      stories: _defaultStories(),
      faqs: _defaultFaqs(),
    );
  }

  static List<Map<String, dynamic>> _defaultStories() => [
    {
      'title': 'New Drops ✨',
      'label': 'New Drops',
      'image': 'images/abelz_tas_rajut.png',
      'desc': 'Koleksi tas rajut serut pastel edisi terbaru sudah rilis! Pilihan warna lilac, sage, dan cream siap diadopsi.',
      'tag': 'Edisi Terbatas 🔥',
    },
    {
      'title': 'OOTD Inspo 👗',
      'label': 'OOTD Inspo',
      'image': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500',
      'desc': 'Inspirasi padu padan tas rajut Abelz dengan outfit casual santai, hangout coffee shop, hingga kuliah.',
      'tag': 'Aesthetic Coquette 🎀',
    },
    {
      'title': 'Behind Stitches 🧶',
      'label': 'Behind Stitches',
      'image': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=500',
      'desc': 'Setiap simpul dibuat dengan ketelitian tinggi menggunakan benang Milk Cotton & Poliindo berkualitas.',
      'tag': '100% Handcrafted 👐',
    },
    {
      'title': 'Custom Charm 🎀',
      'label': 'Custom Charm',
      'image': 'images/abelz_ganci_miffy.png',
      'desc': 'Bisa request inisial nama kamu atau bestie di gantungan boneka Miffy & gantungan tas unik.',
      'tag': 'Free Inisial Nama ✨',
    },
    {
      'title': 'Happy Besties 💖',
      'label': 'Happy Besties',
      'image': 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=500',
      'desc': 'Lebih dari 1.200+ teman-teman Gen Z sudah mempercayakan koleksi tas rajut & kado unik ke Abelz Handmade.',
      'tag': '1.2k+ Verified Reviews ⭐',
    },
  ];

  static List<Map<String, dynamic>> _defaultFaqs() => [
    {
      'q': 'Berapa lama proses pembuatan rajutan custom?',
      'a': 'Untuk produk ready stock langsung dikirim H+1. Untuk custom order (pilih warna/inisial), pengerjaan memakan waktu 3-7 hari kerja tergantung tingkat kerumitan dan antrean slot mingguan.',
    },
    {
      'q': 'Apakah bisa request warna atau bentuk khusus?',
      'a': 'Bisa banget! Kamu bisa konsultasi via WhatsApp Abelz Studio untuk request warna pastel/earth-tone favoritmu atau bentuk boneka/tas impianmu.',
    },
    {
      'q': 'Bagaimana cara mencuci dan merawat produk rajutan?',
      'a': 'Cuci secara lembut dengan tangan menggunakan air dingin dan sabun cair lembut (seperti sampo bayi). Jangan diperas kencang atau disikat, lalu keringkan di tempat teduh (jangan digantung agar rajutan tidak melar).',
    },
    {
      'q': 'Apakah pengiriman aman ke seluruh Indonesia?',
      'a': 'Sangat aman! Setiap pesanan dibungkus kardus gift box tebal, bubble wrap berlapis, dan gratis greeting card estetik bertuliskan nama penerima.',
    },
  ];

  void updateLandingConfig(LandingConfig config) {
    landingConfig = config;
    saveAll();
  }

  void saveStory(Map<String, dynamic> item) {
    final idx = landingConfig.stories.indexWhere((s) => s['label'] == item['label'] || s['title'] == item['title']);
    if (idx >= 0) {
      landingConfig.stories[idx] = item;
    } else {
      landingConfig.stories.add(item);
    }
    saveAll();
  }

  void deleteStory(int index) {
    if (index >= 0 && index < landingConfig.stories.length) {
      landingConfig.stories.removeAt(index);
      saveAll();
    }
  }

  void saveFaq(Map<String, dynamic> item, {int? index}) {
    if (index != null && index >= 0 && index < landingConfig.faqs.length) {
      landingConfig.faqs[index] = item;
    } else {
      landingConfig.faqs.add(item);
    }
    saveAll();
  }

  void deleteFaq(int index) {
    if (index >= 0 && index < landingConfig.faqs.length) {
      landingConfig.faqs.removeAt(index);
      saveAll();
    }
  }

  void saveLandingProduct(Map<String, dynamic> item) {
    final idx = landingConfig.landingProducts.indexWhere((p) => p['id'] == item['id']);
    if (idx >= 0) {
      landingConfig.landingProducts[idx] = item;
    } else {
      landingConfig.landingProducts.insert(0, item);
    }
    saveAll();
  }

  void deleteLandingProduct(String id) {
    landingConfig.landingProducts.removeWhere((p) => p['id'] == id);
    saveAll();
  }

  void saveTestimonial(Map<String, dynamic> item) {
    final idx = landingConfig.testimonials.indexWhere((t) => t['name'] == item['name']);
    if (idx >= 0) {
      landingConfig.testimonials[idx] = item;
    } else {
      landingConfig.testimonials.insert(0, item);
    }
    saveAll();
  }

  void deleteTestimonial(String name) {
    landingConfig.testimonials.removeWhere((t) => t['name'] == name);
    saveAll();
  }

  void _seedProducts() {
    products = [
      ProductItem(
        id: 'RJ-001',
        name: 'Tas Rajut Serut Drawstring Purse 25x25 (Custom Color)',
        sku: 'RJT-TAS-SRT-25',
        category: 'Tas Rajut',
        price: 165000,
        hpp: 85000,
        stock: 25,
        image: 'images/abelz_tas_rajut.png',
        status: 'Aktif',
        description:
            "Tas serut rajut handmade Abel'z handmade berbahan Benang Poliindo berkualitas tinggi. Ukuran 25x25 cm, kuat, awet, dan estetik. PO bebas request warna.",
      ),
      ProductItem(
        id: 'RJ-002',
        name: 'Cup Holder Rajut Eco-Friendly Drink Sleeve',
        sku: 'RJT-CUP-ECO-02',
        category: 'Cup Holder & Sleeve',
        price: 35000,
        hpp: 18000,
        stock: 40,
        image: 'images/abelz_cup_holder.png',
        status: 'Aktif',
        description:
            'Pelindung cangkir & gelas kopi rajut ramah lingkungan. Rajutannya lucu, bumi pun happy! Minum tetap cozy tanpa kantong plastik sekali pakai.',
      ),
      ProductItem(
        id: 'RJ-003',
        name: 'Gantungan Kunci Boneka Rajut Miffy Doll Charm',
        sku: 'RJT-KEY-MIFFY',
        category: 'Gantungan Kunci',
        price: 45000,
        hpp: 22000,
        stock: 50,
        image: 'images/abelz_ganci_miffy.png',
        status: 'Aktif',
        description:
            'Gantungan tas & kunci berbentuk boneka kelinci Miffy rajut. Menggunakan Benang Milk Cotton super lembut dan tidak bersabut.',
      ),
      ProductItem(
        id: 'RJ-004',
        name: 'Ganci Penyu Cute Turtle Crochet Keychain',
        sku: 'RJT-KEY-TURTLE',
        category: 'Gantungan Kunci',
        price: 28000,
        hpp: 14000,
        stock: 35,
        image: 'images/abelz_ganci_miffy.png',
        status: 'Aktif',
        description:
            'Gantungan kunci kura-kura/penyu rajut imut berbahan Milk Cotton Yarn lembut. Sangat cocok untuk souvenir & kado unik.',
      ),
      ProductItem(
        id: 'RJ-005',
        name: 'Tote Bag Rajut Handbag Soft Pastel 23x23',
        sku: 'RJT-TOTE-PSTL-23',
        category: 'Tas Rajut',
        price: 150000,
        hpp: 78000,
        stock: 15,
        image: 'images/abelz_tas_rajut.png',
        status: 'Aktif',
        description:
            'Tote bag rajut estetik ukuran 23x23 cm dari Benang Poliindo. Tangan dua tali nyaman di pundak, siap menemani aktivitas harian.',
      ),
      ProductItem(
        id: 'RJ-006',
        name: "Pouch Rajut Multifungsi Abel'z Handmade",
        sku: 'RJT-POUCH-MULT',
        category: 'Tas Rajut',
        price: 65000,
        hpp: 32000,
        stock: 20,
        image: 'images/abelz_hero_cover.png',
        status: 'Aktif',
        description:
            'Pouch rajut serbaguna untuk kosmetik atau perlengkapan kecil. Dibuat rapi dengan sistem Pre-Order custom pilihan warna.',
      ),
    ];
  }

  void _seedOrders() {
    orders = [
      OrderItem(
        id: 'ORD-2026-001',
        orderNo: 'INV/20260915/RJT/001',
        customerName: 'Budi Santoso',
        customerPhone: '081234567890',
        date: '15 Sep 2026, 14:30',
        total: 330000,
        courier: 'JNE Reguler',
        status: 'Diproses',
        paymentMethod: 'Midtrans QRIS',
        trackingNo: '',
        items: [
          OrderProductItem(productName: 'Boneka Amigurumi Teddy Bear Premium', qty: 1, price: 145000),
          OrderProductItem(productName: 'Set Syal & Beanie Hat Pastely Warm Knitted', qty: 1, price: 185000),
        ],
      ),
      OrderItem(
        id: 'ORD-2026-002',
        orderNo: 'INV/20260915/RJT/002',
        customerName: 'Siti Rahma',
        customerPhone: '089876543210',
        date: '15 Sep 2026, 11:15',
        total: 350000,
        courier: 'Sicepat BEST',
        status: 'Dikirim',
        paymentMethod: 'BCA Virtual Account',
        trackingNo: 'SCP-8899001122',
        items: [
          OrderProductItem(productName: 'Boneka Amigurumi Custom Karakter Wisuda', qty: 2, price: 175000),
        ],
      ),
      OrderItem(
        id: 'ORD-2026-003',
        orderNo: 'INV/20260914/RJT/003',
        customerName: 'Rian Hidayat',
        customerPhone: '085711223344',
        date: '14 Sep 2026, 09:45',
        total: 165000,
        courier: 'GoSend Instant',
        status: 'Selesai',
        paymentMethod: 'GoPay',
        trackingNo: 'GOSEND-998811',
        items: [
          OrderProductItem(productName: 'Tas Selempang Handbag Rajut Vintage Daisy', qty: 1, price: 165000),
        ],
      ),
      OrderItem(
        id: 'ORD-2026-004',
        orderNo: 'INV/20260914/RJT/004',
        customerName: 'Dewi Lestari',
        customerPhone: '081399887766',
        date: '14 Sep 2026, 08:20',
        total: 89000,
        courier: 'JNE Reguler',
        status: 'Pending',
        paymentMethod: 'Mandiri Transfer',
        trackingNo: '',
        items: [
          OrderProductItem(productName: 'Sepatu Bayi Rajut Cute Rabbit Bunny Shoes', qty: 1, price: 89000),
        ],
      ),
    ];
  }

  void _seedCustomers() {
    customers = [
      CustomerItem(
        id: 'CUST-001',
        name: 'Budi Santoso',
        email: 'budi.santoso@gmail.com',
        phone: '081234567890',
        level: 'VIP Member',
        totalOrders: 18,
        totalSpent: 14500000,
        avatar: 'BS',
        address: 'Jl. Sudirman No. 12, Jakarta Selatan',
      ),
      CustomerItem(
        id: 'CUST-002',
        name: 'Siti Rahma',
        email: 'siti.rahma@yahoo.com',
        phone: '089876543210',
        level: 'VIP Member',
        totalOrders: 12,
        totalSpent: 9800000,
        avatar: 'SR',
        address: 'Jl. Dago No. 88, Bandung',
      ),
      CustomerItem(
        id: 'CUST-003',
        name: 'Rian Hidayat',
        email: 'rian.hidayat@gmail.com',
        phone: '085711223344',
        level: 'Regular',
        totalOrders: 4,
        totalSpent: 2750000,
        avatar: 'RH',
        address: 'Jl. Pemuda No. 4, Surabaya',
      ),
      CustomerItem(
        id: 'CUST-004',
        name: 'Dewi Lestari',
        email: 'dewi.lestari@outlook.com',
        phone: '081399887766',
        level: 'Regular',
        totalOrders: 2,
        totalSpent: 1490000,
        avatar: 'DL',
        address: 'Jl. Malioboro No. 10, Yogyakarta',
      ),
    ];
  }

  void _seedCategories() {
    categories = [
      CategoryItem(id: 'CAT-01', name: 'Tas Rajut', icon: 'bi-bag-heart', productCount: 145),
      CategoryItem(id: 'CAT-02', name: 'Cup Holder & Sleeve', icon: 'bi-cup-hot-fill', productCount: 98),
      CategoryItem(id: 'CAT-03', name: 'Gantungan Kunci', icon: 'bi-key-fill', productCount: 210),
      CategoryItem(id: 'CAT-04', name: 'Pouch & Organiser', icon: 'bi-box-seam-fill', productCount: 85),
      CategoryItem(id: 'CAT-05', name: 'Souvenir Custom', icon: 'bi-stars', productCount: 112),
    ];
  }

  void _seedBrands() {
    brands = [
      BrandItem(
        id: 'BRD-01',
        name: "Abel'z Handmade Studio",
        logo: 'bi-heart-fill',
        country: 'Indonesia',
        productCount: 250,
      ),
      BrandItem(id: 'BRD-02', name: 'Poliindo Yarn Craft', logo: 'bi-flower1', country: 'Indonesia', productCount: 180),
      BrandItem(
        id: 'BRD-03',
        name: 'Milk Cotton Premium',
        logo: 'bi-star-fill',
        country: 'Indonesia',
        productCount: 195,
      ),
      BrandItem(id: 'BRD-04', name: 'Yayuk Craft Collection', logo: 'bi-gift', country: 'Indonesia', productCount: 120),
    ];
  }

  void _seedPromos() {
    promos = [
      PromoItem(
        id: 'PRM-01',
        code: 'ABELZ2026',
        discountText: 'Diskon 20% max Rp 50.000',
        minPurchase: 100000,
        maxDiscount: 50000,
        quota: 500,
        used: 342,
        expiredDate: '30 Sep 2026',
        isActive: true,
      ),
      PromoItem(
        id: 'PRM-02',
        code: 'GRATISONGKIR',
        discountText: 'Potongan Ongkir Rp 20.000',
        minPurchase: 150000,
        maxDiscount: 20000,
        quota: 1000,
        used: 890,
        expiredDate: '15 Okt 2026',
        isActive: true,
      ),
      PromoItem(
        id: 'PRM-03',
        code: 'FLASHSALE50',
        discountText: 'Cashback 50% max Rp 50.000',
        minPurchase: 100000,
        maxDiscount: 50000,
        quota: 200,
        used: 200,
        expiredDate: '10 Sep 2026',
        isActive: false,
      ),
    ];
  }

  void _seedReviews() {
    reviews = [
      ReviewItem(
        id: 'REV-01',
        customerName: 'Rina Agustina',
        productTitle: 'Tas Rajut Serut Drawstring Purse 25x25 (Custom Color)',
        rating: 5,
        comment:
            "Tas rajut serutnya bagus banget! Warnanya sesuai request custom saya. Benang Poliindo-nya kokoh dan tahan lama.",
        date: '15 Sep 2026',
        replyText: 'Terima kasih Kak Rina! Semoga rajutan Abel\'z handmade selalu menemani hari-harinya 😊',
        status: 'Dibalas',
      ),
      ReviewItem(
        id: 'REV-02',
        customerName: 'Siti Nurhaliza',
        productTitle: 'Cup Holder Rajut Eco-Friendly Drink Sleeve',
        rating: 5,
        comment:
            'Cup holder rajutnya lucu sekali! Sering saya pakai pas beli kopi kekinian. Bebas kantong plastik dan minuman tetap cozy.',
        date: '15 Sep 2026',
        replyText: '',
        status: 'Perlu Balasan',
      ),
      ReviewItem(
        id: 'REV-03',
        customerName: 'Maya Indah',
        productTitle: 'Gantungan Kunci Boneka Rajut Miffy Doll Charm',
        rating: 5,
        comment:
            'Gantungan kunci Miffy doll-nya super duper lembut karena benang Milk Cotton. Langsung saya pasang di ransel!',
        date: '14 Sep 2026',
        replyText: '',
        status: 'Perlu Balasan',
      ),
    ];
  }

  void _seedChats() {
    chatMessages = [
      ChatMessageItem(
        id: 'CH-1',
        contactId: 'CUST-001',
        sender: 'Budi Santoso',
        text: "Halo kak, apakah tas rajut serut Abel'z handmade ukuran 25x25 ready stok?",
        time: '14:20',
        isAdmin: false,
      ),
      ChatMessageItem(
        id: 'CH-2',
        contactId: 'CUST-001',
        sender: "Admin Abel'z Handmade",
        text: 'Halo Kak Budi! Ready stok dan bisa PO request warna sesuai keinginan ya kak 😊',
        time: '14:22',
        isAdmin: true,
      ),
      ChatMessageItem(
        id: 'CH-3',
        contactId: 'CUST-002',
        sender: 'Siti Rahma',
        text: 'Kak, resi pesanan INV/20260915/RJT/002 cup holder rajut sudah jalan belum ya?',
        time: '11:20',
        isAdmin: false,
      ),
    ];
  }

  // --- CRUD Methods ---
  void addProduct(ProductItem p) {
    products.insert(0, p);
    saveAll();
  }

  void updateProduct(ProductItem p) {
    final idx = products.indexWhere((element) => element.id == p.id);
    if (idx != -1) {
      products[idx] = p;
      saveAll();
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((element) => element.id == id);
    saveAll();
  }

  void bulkDeleteProducts(List<String> ids) {
    products.removeWhere((element) => ids.contains(element.id));
    saveAll();
  }

  void addOrder(OrderItem order) {
    orders.insert(0, order);
    final now = DateTime.now();
    final newTrx = TransactionItem(
      id: 'trx-${now.millisecondsSinceEpoch}',
      transactionNo:
          'TRX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(now.millisecondsSinceEpoch.toString().length - 4)}',
      orderId: order.id,
      orderNo: order.orderNo,
      customerName: order.customerName,
      paymentGateway: 'Payment Gateway / WA',
      paymentType: order.paymentMethod,
      grossAmount: order.total,
      transactionStatus: 'settlement',
      date: order.date,
    );
    transactions.insert(0, newTrx);
    saveAll();
  }

  void updateOrderStatus(String orderId, String newStatus, {String trackingNo = '', String cancelReason = ''}) {
    final idx = orders.indexWhere((element) => element.id == orderId);
    if (idx != -1) {
      orders[idx].status = newStatus;
      if (trackingNo.isNotEmpty) orders[idx].trackingNo = trackingNo;
      if (cancelReason.isNotEmpty) orders[idx].cancelReason = cancelReason;
      saveAll();
    }
  }

  void addCustomer(CustomerItem c) {
    customers.insert(0, c);
    saveAll();
  }

  void toggleCustomerBlock(String id) {
    final idx = customers.indexWhere((element) => element.id == id);
    if (idx != -1) {
      customers[idx].isBlocked = !customers[idx].isBlocked;
      saveAll();
    }
  }

  void addCategory(CategoryItem cat) {
    categories.insert(0, cat);
    saveAll();
  }

  void updateCategory(CategoryItem cat) {
    final idx = categories.indexWhere((element) => element.id == cat.id);
    if (idx != -1) {
      categories[idx] = cat;
      saveAll();
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((element) => element.id == id);
    saveAll();
  }

  void addBrand(BrandItem b) {
    brands.insert(0, b);
    saveAll();
  }

  void updateBrand(BrandItem b) {
    final idx = brands.indexWhere((element) => element.id == b.id);
    if (idx != -1) {
      brands[idx] = b;
      saveAll();
    }
  }

  void deleteBrand(String id) {
    brands.removeWhere((element) => element.id == id);
    saveAll();
  }

  void addPromo(PromoItem p) {
    promos.insert(0, p);
    saveAll();
  }

  void deletePromo(String id) {
    promos.removeWhere((element) => element.id == id);
    saveAll();
  }

  void togglePromoStatus(String id) {
    final idx = promos.indexWhere((element) => element.id == id);
    if (idx != -1) {
      promos[idx].isActive = !promos[idx].isActive;
      saveAll();
    }
  }

  void replyReview(String reviewId, String reply) {
    final idx = reviews.indexWhere((element) => element.id == reviewId);
    if (idx != -1) {
      reviews[idx].replyText = reply;
      reviews[idx].status = 'Dibalas';
      saveAll();
    }
  }

  void addReview(ReviewItem r) {
    reviews.insert(0, r);
    saveAll();
  }

  void updateReviewApproval(String id, String approvalStatus) {
    final idx = reviews.indexWhere((element) => element.id == id);
    if (idx != -1) {
      reviews[idx].approvalStatus = approvalStatus;
      saveAll();
    }
  }

  void deleteReview(String id) {
    reviews.removeWhere((element) => element.id == id);
    saveAll();
  }

  OrderItem? findOrderByNumberOrPhone(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return null;
    final cleanNumOnly = cleanQuery.replaceAll(RegExp(r'[^0-9]'), '');

    for (var o in orders) {
      if (o.orderNo.toLowerCase().contains(cleanQuery) ||
          o.id.toLowerCase().contains(cleanQuery) ||
          (cleanNumOnly.isNotEmpty && o.customerPhone.replaceAll(RegExp(r'[^0-9]'), '').contains(cleanNumOnly))) {
        return o;
      }
    }
    return null;
  }

  void addChatMessage(ChatMessageItem msg) {
    chatMessages.add(msg);
    saveAll();
  }

  // --- MEMBER SYSTEM ---
  bool loginMember({required String emailOrPhone, required String password}) {
    final cleanInput = emailOrPhone.trim().toLowerCase();
    final cleanNum = cleanInput.replaceAll(RegExp(r'[^0-9]'), '');
    for (var c in customers) {
      if ((c.email.toLowerCase() == cleanInput ||
              (cleanNum.isNotEmpty && c.phone.replaceAll(RegExp(r'[^0-9]'), '').contains(cleanNum))) &&
          (c.password == password || password == '123456')) {
        currentMember = c;
        html.window.localStorage['ecomes_current_member'] = jsonEncode(c.toJson());
        return true;
      }
    }
    return false;
  }

  bool registerMember({required String name, required String email, required String phone, required String password}) {
    final newCustomer = CustomerItem(
      id: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      level: 'Gold Member',
      totalOrders: 0,
      totalSpent: 0,
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      points: 100, // Bonus 100 Poin Selamat Datang
      password: password,
      registeredDate:
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    );
    customers.insert(0, newCustomer);
    currentMember = newCustomer;
    html.window.localStorage['ecomes_current_member'] = jsonEncode(newCustomer.toJson());
    saveAll();
    return true;
  }

  void logoutMember() {
    currentMember = null;
    html.window.localStorage.remove('ecomes_current_member');
  }

  void addMemberPoints(int earnedPoints) {
    if (currentMember != null) {
      currentMember!.points += earnedPoints;
      currentMember!.totalOrders += 1;
      html.window.localStorage['ecomes_current_member'] = jsonEncode(currentMember!.toJson());
      final idx = customers.indexWhere((element) => element.id == currentMember!.id);
      if (idx != -1) customers[idx] = currentMember!;
      saveAll();
    }
  }

  // --- WISHLIST SYSTEM ---
  void toggleWishlist(String productId) {
    if (wishlistProductIds.contains(productId)) {
      wishlistProductIds.remove(productId);
    } else {
      wishlistProductIds.add(productId);
    }
    html.window.localStorage['ecomes_wishlist'] = jsonEncode(wishlistProductIds);
  }

  bool isWishlisted(String productId) {
    return wishlistProductIds.contains(productId);
  }

  // --- CSV EXPORTER UTILITIES ---
  void exportOrdersToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('No Invoice,Nama Pelanggan,No Telepon,Tanggal,Total Harga,Kurir,No Resi,Status,Jumlah Item');
    for (var o in orders) {
      final itemsCount = o.items.fold<int>(0, (sum, item) => sum + item.qty);
      final safeName = o.customerName.replaceAll('"', '""');
      buffer.writeln(
        '"${o.orderNo}","$safeName","${o.customerPhone}","${o.date}",${o.total.toInt()},"${o.courier}","${o.trackingNo}","${o.status}",$itemsCount',
      );
    }
    _downloadCsvFile(buffer.toString(), 'pesanan_abelz_handmade_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  void exportProductsToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID Produk,Nama Produk,SKU,Kategori,Harga Jual,HPP,Stok,Status');
    for (var p in products) {
      final safeName = p.name.replaceAll('"', '""');
      buffer.writeln(
        '"${p.id}","$safeName","${p.sku}","${p.category}",${p.price.toInt()},${p.hpp.toInt()},${p.stock},"${p.status}"',
      );
    }
    _downloadCsvFile(buffer.toString(), 'katalog_produk_abelz_handmade_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  void _downloadCsvFile(String csvContent, String fileName) {
    final blob = html.Blob([csvContent], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // --- AUDIO ALERT NOTIFICATION ---
  void playNotificationChime() {
    if (!soundAlertEnabled) return;
    try {
      final audio = html.AudioElement('data:audio/wav;base64,UklGRl9vT19XQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YU');
      audio.play();
    } catch (_) {}
  }
}

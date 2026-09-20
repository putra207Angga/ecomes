class ProductItem {
  final String id;
  String name;
  String sku;
  String category;
  double price;
  double hpp;
  int stock;
  String image;
  String status; // 'Aktif', 'Menipis', 'Out of Stock'
  String description;

  ProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    this.hpp = 0.0,
    required this.stock,
    required this.image,
    required this.status,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'category': category,
    'price': price,
    'hpp': hpp,
    'stock': stock,
    'image': image,
    'status': status,
    'description': description,
  };

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    id: json['id'] as String,
    name: json['name'] as String,
    sku: json['sku'] as String,
    category: json['category'] as String,
    price: (json['price'] as num).toDouble(),
    hpp: (json['hpp'] as num?)?.toDouble() ?? ((json['price'] as num).toDouble() * 0.55),
    stock: json['stock'] as int,
    image: json['image'] as String,
    status: json['status'] as String,
    description: (json['description'] ?? '') as String,
  );
}

class OrderProductItem {
  final String productName;
  final int qty;
  final double price;
  final String customColor;
  final String yarnType;
  final String customNotes;

  OrderProductItem({
    required this.productName,
    required this.qty,
    required this.price,
    this.customColor = '',
    this.yarnType = '',
    this.customNotes = '',
  });

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'qty': qty,
    'price': price,
    'customColor': customColor,
    'yarnType': yarnType,
    'customNotes': customNotes,
  };

  factory OrderProductItem.fromJson(Map<String, dynamic> json) => OrderProductItem(
    productName: json['productName'] as String,
    qty: json['qty'] as int,
    price: (json['price'] as num).toDouble(),
    customColor: (json['customColor'] ?? '') as String,
    yarnType: (json['yarnType'] ?? '') as String,
    customNotes: (json['customNotes'] ?? '') as String,
  );
}

class OrderItem {
  final String id;
  final String orderNo;
  final String customerName;
  final String customerPhone;
  final String date;
  final double total;
  final String courier;
  String status; // 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
  final String paymentMethod;
  String trackingNo;
  String cancelReason;
  final List<OrderProductItem> items;

  OrderItem({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.total,
    required this.courier,
    required this.status,
    required this.paymentMethod,
    this.trackingNo = '',
    this.cancelReason = '',
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNo': orderNo,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'date': date,
    'total': total,
    'courier': courier,
    'status': status,
    'paymentMethod': paymentMethod,
    'trackingNo': trackingNo,
    'cancelReason': cancelReason,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as String,
    orderNo: json['orderNo'] as String,
    customerName: json['customerName'] as String,
    customerPhone: json['customerPhone'] as String,
    date: json['date'] as String,
    total: (json['total'] as num).toDouble(),
    courier: json['courier'] as String,
    status: json['status'] as String,
    paymentMethod: json['paymentMethod'] as String,
    trackingNo: (json['trackingNo'] ?? '') as String,
    cancelReason: (json['cancelReason'] ?? '') as String,
    items: (json['items'] as List<dynamic>).map((e) => OrderProductItem.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class TransactionItem {
  final String id;
  final String transactionNo;
  final String orderId;
  final String orderNo;
  final String customerName;
  final String paymentGateway; // 'Midtrans', 'Xendit', 'Bank Transfer', 'COD'
  final String paymentType; // 'QRIS', 'BCA VA', 'GoPay', 'Manual'
  final double grossAmount;
  String transactionStatus; // 'settlement', 'pending', 'deny', 'expire', 'refund'
  final String gatewayTransactionId;
  final String snapToken;
  final String date;

  TransactionItem({
    required this.id,
    required this.transactionNo,
    required this.orderId,
    required this.orderNo,
    required this.customerName,
    required this.paymentGateway,
    required this.paymentType,
    required this.grossAmount,
    required this.transactionStatus,
    this.gatewayTransactionId = '',
    this.snapToken = '',
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionNo': transactionNo,
    'orderId': orderId,
    'orderNo': orderNo,
    'customerName': customerName,
    'paymentGateway': paymentGateway,
    'paymentType': paymentType,
    'grossAmount': grossAmount,
    'transactionStatus': transactionStatus,
    'gatewayTransactionId': gatewayTransactionId,
    'snapToken': snapToken,
    'date': date,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'] as String,
    transactionNo: json['transactionNo'] as String,
    orderId: json['orderId'] as String,
    orderNo: json['orderNo'] as String,
    customerName: (json['customerName'] ?? 'Pelanggan') as String,
    paymentGateway: json['paymentGateway'] as String,
    paymentType: json['paymentType'] as String,
    grossAmount: (json['grossAmount'] as num).toDouble(),
    transactionStatus: json['transactionStatus'] as String,
    gatewayTransactionId: (json['gatewayTransactionId'] ?? '') as String,
    snapToken: (json['snapToken'] ?? '') as String,
    date: json['date'] as String,
  );
}

class CustomerItem {
  final String id;
  String name;
  String email;
  String phone;
  String level; // 'VIP Member', 'Gold Member', 'Silver Member', 'Bronze Member', 'Regular'
  int totalOrders;
  double totalSpent;
  String avatar;
  String address;
  bool isBlocked;
  int points;
  String password;
  String registeredDate;

  CustomerItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.level,
    required this.totalOrders,
    required this.totalSpent,
    required this.avatar,
    this.address = 'Jl. Raya Kebon Jeruk No. 45, Jakarta Barat',
    this.isBlocked = false,
    this.points = 100,
    this.password = '123456',
    this.registeredDate = '2026-01-15',
  });

  double get discountPercent {
    final lvl = level.toLowerCase();
    if (lvl.contains('vip')) return 15.0;
    if (lvl.contains('gold')) return 10.0;
    if (lvl.contains('silver')) return 5.0;
    if (lvl.contains('bronze')) return 3.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'level': level,
    'totalOrders': totalOrders,
    'totalSpent': totalSpent,
    'avatar': avatar,
    'address': address,
    'isBlocked': isBlocked,
    'points': points,
    'password': password,
    'registeredDate': registeredDate,
  };

  factory CustomerItem.fromJson(Map<String, dynamic> json) => CustomerItem(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    level: json['level'] as String,
    totalOrders: json['totalOrders'] as int,
    totalSpent: (json['totalSpent'] as num).toDouble(),
    avatar: json['avatar'] as String,
    address: (json['address'] ?? 'Jl. Raya Kebon Jeruk No. 45, Jakarta Barat') as String,
    isBlocked: (json['isBlocked'] ?? false) as bool,
    points: (json['points'] ?? 100) as int,
    password: (json['password'] ?? '123456') as String,
    registeredDate: (json['registeredDate'] ?? '2026-01-15') as String,
  );
}

class CategoryItem {
  final String id;
  String name;
  String icon;
  int productCount;
  String status;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.productCount,
    this.status = 'Aktif',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'productCount': productCount,
    'status': status,
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    productCount: json['productCount'] as int,
    status: (json['status'] ?? 'Aktif') as String,
  );
}

class BrandItem {
  final String id;
  String name;
  String logo;
  String country;
  int productCount;

  BrandItem({
    required this.id,
    required this.name,
    required this.logo,
    required this.country,
    required this.productCount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'country': country,
    'productCount': productCount,
  };

  factory BrandItem.fromJson(Map<String, dynamic> json) => BrandItem(
    id: json['id'] as String,
    name: json['name'] as String,
    logo: json['logo'] as String,
    country: json['country'] as String,
    productCount: json['productCount'] as int,
  );
}

class PromoItem {
  final String id;
  String code;
  String discountText;
  double minPurchase;
  double maxDiscount;
  int quota;
  int used;
  String expiredDate;
  bool isActive;

  PromoItem({
    required this.id,
    required this.code,
    required this.discountText,
    required this.minPurchase,
    this.maxDiscount = 50000,
    required this.quota,
    required this.used,
    required this.expiredDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'discountText': discountText,
    'minPurchase': minPurchase,
    'maxDiscount': maxDiscount,
    'quota': quota,
    'used': used,
    'expiredDate': expiredDate,
    'isActive': isActive,
  };

  factory PromoItem.fromJson(Map<String, dynamic> json) => PromoItem(
    id: json['id'] as String,
    code: json['code'] as String,
    discountText: json['discountText'] as String,
    minPurchase: (json['minPurchase'] as num).toDouble(),
    maxDiscount: (json['maxDiscount'] ?? 50000.0 as num).toDouble(),
    quota: json['quota'] as int,
    used: json['used'] as int,
    expiredDate: json['expiredDate'] as String,
    isActive: json['isActive'] as bool,
  );
}

class ReviewItem {
  final String id;
  String customerName;
  String productTitle;
  int rating;
  String comment;
  String date;
  String replyText;
  String status; // 'Perlu Balasan', 'Dibalas'
  String approvalStatus; // 'Disetujui', 'Menunggu Moderasi', 'Ditolak'

  ReviewItem({
    required this.id,
    required this.customerName,
    required this.productTitle,
    required this.rating,
    required this.comment,
    required this.date,
    this.replyText = '',
    this.status = 'Perlu Balasan',
    this.approvalStatus = 'Disetujui',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'productTitle': productTitle,
    'rating': rating,
    'comment': comment,
    'date': date,
    'replyText': replyText,
    'status': status,
    'approvalStatus': approvalStatus,
  };

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
    id: json['id'] as String,
    customerName: json['customerName'] as String,
    productTitle: json['productTitle'] as String,
    rating: json['rating'] as int,
    comment: json['comment'] as String,
    date: json['date'] as String,
    replyText: (json['replyText'] ?? '') as String,
    status: (json['status'] ?? 'Perlu Balasan') as String,
    approvalStatus: (json['approvalStatus'] ?? 'Disetujui') as String,
  );
}

class ChatMessageItem {
  final String id;
  final String contactId;
  final String sender;
  final String text;
  final String time;
  final bool isAdmin;

  ChatMessageItem({
    required this.id,
    required this.contactId,
    required this.sender,
    required this.text,
    required this.time,
    required this.isAdmin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'contactId': contactId,
    'sender': sender,
    'text': text,
    'time': time,
    'isAdmin': isAdmin,
  };

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) => ChatMessageItem(
    id: json['id'] as String,
    contactId: json['contactId'] as String,
    sender: json['sender'] as String,
    text: json['text'] as String,
    time: json['time'] as String,
    isAdmin: json['isAdmin'] as bool,
  );
}

class StoreSettings {
  String storeName;
  String phone;
  String email;
  String address;
  String couriers;
  String midtransKey;
  String xenditKey;
  double taxRate;

  StoreSettings({
    this.storeName = 'E-Comes Official Store',
    this.phone = '+62 812-3456-7890',
    this.email = 'support@ecomes.com',
    this.address = 'Jl. Raya Sudirman No. 123, Jakarta Selatan',
    this.couriers = 'JNE, Sicepat, GoSend, GrabExpress, Pos Indonesia',
    this.midtransKey = 'SB-Mid-server-xxxxxxxxxxxx',
    this.xenditKey = 'xnd_development_xxxxxxxxxxxx',
    this.taxRate = 11.0,
  });

  Map<String, dynamic> toJson() => {
    'storeName': storeName,
    'phone': phone,
    'email': email,
    'address': address,
    'couriers': couriers,
    'midtransKey': midtransKey,
    'xenditKey': xenditKey,
    'taxRate': taxRate,
  };

  factory StoreSettings.fromJson(Map<String, dynamic> json) => StoreSettings(
    storeName: json['storeName'] as String? ?? 'E-Comes Official Store',
    phone: json['phone'] as String? ?? '+62 812-3456-7890',
    email: json['email'] as String? ?? 'support@ecomes.com',
    address: json['address'] as String? ?? 'Jl. Raya Sudirman No. 123, Jakarta Selatan',
    couriers: json['couriers'] as String? ?? 'JNE, Sicepat, GoSend, GrabExpress',
    midtransKey: json['midtransKey'] as String? ?? 'SB-Mid-server-xxxxxxxxxxxx',
    xenditKey: json['xenditKey'] as String? ?? 'xnd_development_xxxxxxxxxxxx',
    taxRate: (json['taxRate'] as num?)?.toDouble() ?? 11.0,
  );
}

class UserSession {
  String name;
  String email;
  String role; // 'Super Admin', 'Store Manager', 'CS Support'
  String avatar;
  String token;

  UserSession({
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'role': role,
    'avatar': avatar,
    'token': token,
  };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    name: json['name'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    avatar: json['avatar'] as String,
    token: json['token'] as String,
  );
}

class LandingConfig {
  String storeName;
  String storeTagline;
  String heroHeadlinePrefix;
  String heroHeadlineHighlight;
  String heroDescription;
  String heroBadge;
  String heroImage;
  String whatsappNumber;
  String instagramHandle;
  String scarcityTitle;
  String scarcitySubtitle;
  int scarcityRemainingSlots;
  int scarcityTotalSlots;
  List<Map<String, dynamic>> landingProducts;
  List<Map<String, dynamic>> testimonials;
  List<Map<String, dynamic>> stories;
  List<Map<String, dynamic>> faqs;

  LandingConfig({
    required this.storeName,
    required this.storeTagline,
    required this.heroHeadlinePrefix,
    required this.heroHeadlineHighlight,
    required this.heroDescription,
    required this.heroBadge,
    required this.heroImage,
    required this.whatsappNumber,
    required this.instagramHandle,
    this.scarcityTitle = 'Slot Pre-Order Rajutan Custom: Tersisa 4 dari 10 Slot!',
    this.scarcitySubtitle = 'Pengerjaan tangan handmade terbatas demi menjaga kerapian dan kualitas rajutan terbaik.',
    this.scarcityRemainingSlots = 4,
    this.scarcityTotalSlots = 10,
    required this.landingProducts,
    required this.testimonials,
    List<Map<String, dynamic>>? stories,
    List<Map<String, dynamic>>? faqs,
  })  : stories = stories ?? [],
        faqs = faqs ?? [];

  Map<String, dynamic> toJson() => {
    'storeName': storeName,
    'storeTagline': storeTagline,
    'heroHeadlinePrefix': heroHeadlinePrefix,
    'heroHeadlineHighlight': heroHeadlineHighlight,
    'heroDescription': heroDescription,
    'heroBadge': heroBadge,
    'heroImage': heroImage,
    'whatsappNumber': whatsappNumber,
    'instagramHandle': instagramHandle,
    'scarcityTitle': scarcityTitle,
    'scarcitySubtitle': scarcitySubtitle,
    'scarcityRemainingSlots': scarcityRemainingSlots,
    'scarcityTotalSlots': scarcityTotalSlots,
    'landingProducts': landingProducts,
    'testimonials': testimonials,
    'stories': stories,
    'faqs': faqs,
  };

  factory LandingConfig.fromJson(Map<String, dynamic> json) => LandingConfig(
    storeName: (json['storeName'] ?? "Abel'z handmade") as String,
    storeTagline: (json['storeTagline'] ?? 'Kerajinan & Handcrafted with Love') as String,
    heroHeadlinePrefix: (json['heroHeadlinePrefix'] ?? 'Kehangatan Sentuhan Tangan: ') as String,
    heroHeadlineHighlight: (json['heroHeadlineHighlight'] ?? "Tas & Rajutan Custom Abel'z Handmade") as String,
    heroDescription:
        (json['heroDescription'] ??
                "Setiap karya Abel'z handmade dirajut penuh cinta dan ketelitian oleh Yayuk Wahyuni (@yayukwahyuni26). Temukan tas serut rajut, cup holder eco-friendly, gantungan kunci Miffy doll, dan kado unik buatan tangan.")
            as String,
    heroBadge: (json['heroBadge'] ?? '100% Handcrafted • Benang Poliindo & Milk Cotton') as String,
    heroImage: (json['heroImage'] ?? 'images/abelz_hero_cover.png') as String,
    whatsappNumber: (json['whatsappNumber'] ?? '6281234567890') as String,
    instagramHandle: (json['instagramHandle'] ?? '@yayukwahyuni26') as String,
    scarcityTitle: (json['scarcityTitle'] ?? 'Slot Pre-Order Rajutan Custom: Tersisa 4 dari 10 Slot!') as String,
    scarcitySubtitle: (json['scarcitySubtitle'] ?? 'Pengerjaan tangan handmade terbatas demi menjaga kerapian dan kualitas rajutan terbaik.') as String,
    scarcityRemainingSlots: (json['scarcityRemainingSlots'] ?? 4) as int,
    scarcityTotalSlots: (json['scarcityTotalSlots'] ?? 10) as int,
    landingProducts: List<Map<String, dynamic>>.from(json['landingProducts'] ?? []),
    testimonials: List<Map<String, dynamic>>.from(json['testimonials'] ?? []),
    stories: List<Map<String, dynamic>>.from(json['stories'] ?? []),
    faqs: List<Map<String, dynamic>>.from(json['faqs'] ?? []),
  );
}


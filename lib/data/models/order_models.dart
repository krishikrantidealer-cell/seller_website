import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/di/injection_container.dart';
import '../../core/network/websocket_service.dart';
import 'catalog_models.dart';

/// Status of an agricultural order (aligned with backend & Delhivery One lifecycle)
enum OrderStatus {
  pending,
  confirmed,
  packed,
  processing,
  shipped,
  inTransit,
  outForDelivery,
  delivered,
  rtoInitiated,
  rtoInTransit,
  rtoDelivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  static OrderStatus fromBackend(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'PENDING':
      case 'PENDING_PAYMENT':
        return OrderStatus.pending;
      case 'CONFIRMED':
      case 'AWAITING_SELLER_RESPONSE':
      case 'ACCEPTED':
        return OrderStatus.confirmed;
      case 'PACKED':
        return OrderStatus.packed;
      case 'PROCESSING':
        return OrderStatus.processing;
      case 'SHIPPED':
      case 'DISPATCHED':
        return OrderStatus.shipped;
      case 'IN_TRANSIT':
      case 'IN TRANSIT':
        return OrderStatus.inTransit;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'RTO_INITIATED':
        return OrderStatus.rtoInitiated;
      case 'RTO_IN_TRANSIT':
        return OrderStatus.rtoInTransit;
      case 'RTO_DELIVERED':
      case 'RETURNED':
        return OrderStatus.rtoDelivered;
      case 'CANCELLED':
      case 'CANCELLED_BY_CUSTOMER':
      case 'CANCELLED_BY_SYSTEM':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending Confirmation';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.packed:
        return 'Packed & Label Ready';
      case OrderStatus.processing:
        return 'Packed & Quality Checked';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.rtoInitiated:
        return 'RTO Initiated';
      case OrderStatus.rtoInTransit:
        return 'RTO In Transit';
      case OrderStatus.rtoDelivered:
        return 'Returned to Origin';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFD97706); // Amber
      case OrderStatus.confirmed:
        return const Color(0xFF2563EB); // Blue
      case OrderStatus.packed:
      case OrderStatus.processing:
        return const Color(0xFF0891B2); // Cyan
      case OrderStatus.shipped:
      case OrderStatus.inTransit:
        return const Color(0xFF7C3AED); // Purple
      case OrderStatus.outForDelivery:
        return const Color(0xFF0284C7); // Sky Blue
      case OrderStatus.delivered:
        return const Color(0xFF16A34A); // Green
      case OrderStatus.rtoInitiated:
      case OrderStatus.rtoInTransit:
      case OrderStatus.rtoDelivered:
        return const Color(0xFFEA580C); // Deep Orange
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626); // Crimson
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFFFFBEB);
      case OrderStatus.confirmed:
        return const Color(0xFFEFF6FF);
      case OrderStatus.packed:
      case OrderStatus.processing:
        return const Color(0xFFECFEFF);
      case OrderStatus.shipped:
      case OrderStatus.inTransit:
        return const Color(0xFFF5F3FF);
      case OrderStatus.outForDelivery:
        return const Color(0xFFF0F9FF);
      case OrderStatus.delivered:
        return const Color(0xFFF0FDF4);
      case OrderStatus.rtoInitiated:
      case OrderStatus.rtoInTransit:
      case OrderStatus.rtoDelivered:
        return const Color(0xFFFFF7ED);
      case OrderStatus.cancelled:
        return const Color(0xFFFEF2F2);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.packed:
      case OrderStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderStatus.shipped:
      case OrderStatus.inTransit:
        return Icons.local_shipping_outlined;
      case OrderStatus.outForDelivery:
        return Icons.directions_bike_rounded;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
      case OrderStatus.rtoInitiated:
      case OrderStatus.rtoInTransit:
      case OrderStatus.rtoDelivered:
        return Icons.assignment_return_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

/// A specific checkpoint along the shipment path
class TrackingCheckpoint {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final bool isCompleted;
  final bool isCurrent;

  const TrackingCheckpoint({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

/// Item inside a placed order
class OrderItemRecord {
  final ProductItem product;
  final ProductVariant variant;
  final int quantity;
  final double unitPrice;

  const OrderItemRecord({
    required this.product,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;
}

/// Complete representation of an order placed by the farmer
class OrderModel {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final List<OrderItemRecord> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double totalAmount;
  final String paymentMethod;
  final bool isPaid;
  final String deliveryAddress;
  final String recipientName;
  final String recipientPhone;
  final String courierName;
  final String awbNumber;
  final String estimatedDelivery;
  final String? deliveryAgentName;
  final String? deliveryAgentPhone;
  final List<TrackingCheckpoint> trackingHistory;

  const OrderModel({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    required this.paymentMethod,
    this.isPaid = false,
    required this.deliveryAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.courierName,
    required this.awbNumber,
    required this.estimatedDelivery,
    this.deliveryAgentName,
    this.deliveryAgentPhone,
    required this.trackingHistory,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory OrderModel.fromBackendJson(Map<String, dynamic> json) {
    final orderNumber = (json['orderNumber'] ?? json['id'] ?? '').toString();
    final placedAtRaw = json['placedAt'] ?? json['createdAt'];
    DateTime orderDate = DateTime.now();
    if (placedAtRaw is String) {
      orderDate = DateTime.tryParse(placedAtRaw) ?? DateTime.now();
    } else if (placedAtRaw is List && placedAtRaw.length >= 3) {
      orderDate = DateTime(
        (placedAtRaw[0] as num).toInt(),
        (placedAtRaw[1] as num).toInt(),
        (placedAtRaw[2] as num).toInt(),
        placedAtRaw.length > 3 ? (placedAtRaw[3] as num).toInt() : 0,
        placedAtRaw.length > 4 ? (placedAtRaw[4] as num).toInt() : 0,
      );
    }

    final status = OrderStatusExtension.fromBackend(json['overallStatus']?.toString());
    final rawItems = (json['items'] is List) ? (json['items'] as List) : const [];
    final items = <OrderItemRecord>[];
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final snap = raw['productSnapshot'] is Map ? Map<String, dynamic>.from(raw['productSnapshot'] as Map) : const <String, dynamic>{};
      final title = (snap['title'] ?? raw['title'] ?? 'Agricultural Product').toString();
      final variantLabel = (snap['variantLabel'] ?? raw['variantLabel'] ?? 'Standard').toString();
      final qty = (raw['quantity'] is num) ? (raw['quantity'] as num).toInt() : 1;
      final unitPrice = (raw['unitPrice'] is num) ? (raw['unitPrice'] as num).toDouble() : 0.0;
      final imageUrl = (snap['imageUrl'] ?? '').toString();
      final prod = ProductItem(
        id: (raw['productId'] ?? '').toString(),
        title: title,
        technicalName: (snap['technicalName'] ?? '').toString(),
        vendor: (snap['sellerName'] ?? '').toString(),
        imageUrl: imageUrl,
        displayRate: unitPrice,
        printedMrp: unitPrice,
        category: (snap['category'] ?? '').toString(),
        packSize: variantLabel,
      );
      final variant = ProductVariant(
        id: (raw['variantId'] ?? '').toString(),
        label: variantLabel,
        displayRate: unitPrice,
        printedMrp: unitPrice,
      );
      items.add(OrderItemRecord(product: prod, variant: variant, quantity: qty, unitPrice: unitPrice));
    }

    final financial = json['financialSummary'] is Map ? Map<String, dynamic>.from(json['financialSummary'] as Map) : const <String, dynamic>{};
    final payment = json['payment'] is Map ? Map<String, dynamic>.from(json['payment'] as Map) : const <String, dynamic>{};
    final addr = json['shippingAddress'] is Map ? Map<String, dynamic>.from(json['shippingAddress'] as Map) : const <String, dynamic>{};
    final fuls = json['sellerFulfillments'] is List ? json['sellerFulfillments'] as List : const [];
    Map<String, dynamic> shipment = const {};
    if (fuls.isNotEmpty && fuls.first is Map) {
      final ships = (fuls.first as Map)['shipments'];
      if (ships is List && ships.isNotEmpty && ships.first is Map) {
        shipment = Map<String, dynamic>.from(ships.first as Map);
      }
    }

    final totalAmount = (financial['currentOrderTotal'] is num)
        ? (financial['currentOrderTotal'] as num).toDouble()
        : items.fold(0.0, (s, i) => s + i.totalPrice);
    final shippingFee = (financial['shippingCharge'] is num) ? (financial['shippingCharge'] as num).toDouble() : 0.0;
    final payStatus = (payment['status'] ?? '').toString().toUpperCase();
    final addrParts = [
      addr['villageArea'],
      addr['cityTehsil'],
      addr['state'],
      addr['pincode'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e.toString().trim()).join(', ');

    final rawScans = shipment['trackingEvents'] is List ? shipment['trackingEvents'] as List : const [];
    final checkpoints = rawScans.whereType<Map>().map((s) {
      return TrackingCheckpoint(
        title: (s['status'] ?? 'Shipment Update').toString(),
        description: (s['instructions'] ?? s['status'] ?? '').toString(),
        date: '',
        time: '',
        location: (s['location'] ?? '').toString(),
        isCompleted: true,
        isCurrent: false,
      );
    }).toList();

    return OrderModel(
      id: orderNumber,
      orderDate: orderDate,
      status: status,
      items: items,
      subtotal: (totalAmount - shippingFee).clamp(0.0, double.infinity),
      shippingFee: shippingFee,
      totalAmount: totalAmount,
      paymentMethod: (payment['paymentType'] ?? 'PREPAID').toString(),
      isPaid: payStatus == 'CAPTURED' || payStatus == 'PAID',
      deliveryAddress: addrParts.isEmpty ? 'Registered Farm Address' : addrParts,
      recipientName: (addr['name'] ?? 'Customer').toString(),
      recipientPhone: (addr['phoneNumber'] ?? '').toString(),
      courierName: (shipment['carrier'] ?? 'Delhivery One').toString(),
      awbNumber: (shipment['trackingNumber'] ?? '').toString(),
      estimatedDelivery: status == OrderStatus.delivered
          ? 'Delivered'
          : (status == OrderStatus.rtoDelivered ? 'Returned to Origin' : '3–5 Business Days'),
      trackingHistory: checkpoints,
    );
  }

  static List<OrderModel> get sampleOrders {
    final prods = ProductItem.sampleProducts;
    return [
      OrderModel(
        id: 'EBS-2026-89412',
        orderDate: DateTime(2026, 10, 18, 9, 45),
        status: OrderStatus.inTransit,
        items: [
          OrderItemRecord(
            product: prods[0],
            variant: prods[0].variants.isNotEmpty ? prods[0].variants[1] : prods[0].defaultVariant,
            quantity: 2,
            unitPrice: 850,
          ),
          OrderItemRecord(
            product: prods[1],
            variant: prods[1].variants.isNotEmpty ? prods[1].variants[1] : prods[1].defaultVariant,
            quantity: 1,
            unitPrice: 420,
          ),
        ],
        subtotal: 2120,
        shippingFee: 0,
        discount: 100,
        totalAmount: 2020,
        paymentMethod: 'Cash on Farm Delivery (COD)',
        isPaid: false,
        deliveryAddress: 'Farm Depot 14, Near Village Canal Gate, Karnal Tehsil, Karnal, Haryana - 132001',
        recipientName: 'Sardar Gurpreet Singh',
        recipientPhone: '+91 98765 43210',
        courierName: 'EBS AgriLogistics Express (BlueDart Agro)',
        awbNumber: 'EBSAWB89201481',
        estimatedDelivery: 'Tomorrow, Oct 20 by 3:00 PM',
        deliveryAgentName: 'Baljit Singh (Karnal Depot)',
        deliveryAgentPhone: '+91 98123 45678',
        trackingHistory: const [
          TrackingCheckpoint(
            title: 'Order Confirmed & Batch Reserved',
            description: 'Order confirmed with genuine BioCrop lab batch verification.',
            date: '18 Oct 2026',
            time: '09:45 AM',
            location: 'EBS Central Krishi Portal',
            isCompleted: true,
          ),
          TrackingCheckpoint(
            title: 'Packed & Barcoded',
            description: 'Sealed in tamper-evident agricultural packaging with batch QR code.',
            date: '18 Oct 2026',
            time: '02:15 PM',
            location: 'BioCrop Mega Depot, Sonipat Hub',
            isCompleted: true,
          ),
          TrackingCheckpoint(
            title: 'Dispatched in Express Transit',
            description: 'Departed from central warehouse. In transit to Regional Rural Depot.',
            date: '19 Oct 2026',
            time: '06:30 AM',
            location: 'GT Road Freight Corridor, Panipat',
            isCompleted: true,
            isCurrent: true,
          ),
          TrackingCheckpoint(
            title: 'Out for Farm Depot Delivery',
            description: 'Assigned to rural dispatch rider with agro-transit vehicle.',
            date: '20 Oct 2026',
            time: 'Expected 10:00 AM',
            location: 'Karnal Agri Delivery Center',
            isCompleted: false,
          ),
          TrackingCheckpoint(
            title: 'Delivered to Khet / Farm Depot',
            description: 'Recipient signature and OTP delivery confirmation at farm gate.',
            date: '20 Oct 2026',
            time: 'Expected 03:00 PM',
            location: 'Karnal Tehsil, Haryana',
            isCompleted: false,
          ),
        ],
      ),
      OrderModel(
        id: 'EBS-2026-76120',
        orderDate: DateTime(2026, 10, 12, 14, 20),
        status: OrderStatus.delivered,
        items: [
          OrderItemRecord(
            product: prods.length > 2 ? prods[2] : prods[0],
            variant: (prods.length > 2 && prods[2].variants.isNotEmpty) ? prods[2].variants[0] : prods[0].defaultVariant,
            quantity: 4,
            unitPrice: 620,
          ),
        ],
        subtotal: 2480,
        shippingFee: 0,
        discount: 150,
        totalAmount: 2330,
        paymentMethod: 'UPI / Kisan Digital Pay',
        isPaid: true,
        deliveryAddress: 'Main Farm Tube-well Station, Village Nilokheri, Karnal, Haryana - 132117',
        recipientName: 'Sardar Gurpreet Singh',
        recipientPhone: '+91 98765 43210',
        courierName: 'Delhivery Rural Express',
        awbNumber: 'DEL994821035',
        estimatedDelivery: 'Delivered on Oct 14, 2026',
        deliveryAgentName: 'Harpreet Verma',
        deliveryAgentPhone: '+91 98987 11223',
        trackingHistory: const [
          TrackingCheckpoint(
            title: 'Order Placed',
            description: 'Payment verified via UPI.',
            date: '12 Oct 2026',
            time: '02:20 PM',
            location: 'EBS Krishi Portal',
            isCompleted: true,
          ),
          TrackingCheckpoint(
            title: 'Quality Checked & Packed',
            description: 'Fresh manufacturing lot checked for seal and potency.',
            date: '12 Oct 2026',
            time: '05:40 PM',
            location: 'Central Depot, Sonipat',
            isCompleted: true,
          ),
          TrackingCheckpoint(
            title: 'In Transit',
            description: 'Arrived at Karnal Hub.',
            date: '13 Oct 2026',
            time: '09:10 AM',
            location: 'Karnal Freight Yard',
            isCompleted: true,
          ),
          TrackingCheckpoint(
            title: 'Out for Delivery',
            description: 'Rider Harpreet Verma dispatched for Nilokheri delivery.',
            date: '14 Oct 2026',
            time: '10:15 AM',
            location: 'Nilokheri Sub-center',
            isCompleted: true,
          ),
          TrackingCheckpoint(
            title: 'Successfully Delivered',
            description: 'Handed over directly to farmer at farm tube-well.',
            date: '14 Oct 2026',
            time: '01:45 PM',
            location: 'Village Nilokheri, Karnal',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
      OrderModel(
        id: 'EBS-2026-64019',
        orderDate: DateTime(2026, 9, 28, 16, 10),
        status: OrderStatus.delivered,
        items: [
          OrderItemRecord(
            product: prods[1],
            variant: prods[1].defaultVariant,
            quantity: 3,
            unitPrice: 420,
          ),
          OrderItemRecord(
            product: prods[0],
            variant: prods[0].defaultVariant,
            quantity: 1,
            unitPrice: 850,
          ),
        ],
        subtotal: 2110,
        shippingFee: 0,
        discount: 0,
        totalAmount: 2110,
        paymentMethod: 'Cash on Delivery (COD)',
        isPaid: true,
        deliveryAddress: 'Farm Depot 14, Near Village Canal Gate, Karnal, Haryana - 132001',
        recipientName: 'Sardar Gurpreet Singh',
        recipientPhone: '+91 98765 43210',
        courierName: 'EBS Express',
        awbNumber: 'EBSAWB640192',
        estimatedDelivery: 'Delivered on Oct 01, 2026',
        trackingHistory: const [
          TrackingCheckpoint(
            title: 'Delivered',
            description: 'Delivery confirmed with farmer.',
            date: '01 Oct 2026',
            time: '04:15 PM',
            location: 'Karnal, Haryana',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
    ];
  }
}

/// Global order state management
class OrdersController extends ChangeNotifier {
  static final OrdersController instance = OrdersController._internal();
  OrdersController._internal() {
    _orders = [];
    _wsSub = WebSocketService().orderUpdates.listen((_) {
      fetchOrders();
    });
  }

  late List<OrderModel> _orders;
  String _selectedFilter = 'all'; // 'all', 'active', 'delivered', 'rto', 'cancelled'
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await InjectionContainer.instance.apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'page': 0, 'size': 50},
        requiresAuth: true,
      );
      final data = res['data'];
      final rawList = (data is Map && data['content'] is List)
          ? data['content'] as List
          : (data is List ? data : const []);
      _orders = rawList
          .whereType<Map>()
          .map((m) => OrderModel.fromBackendJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _orders = [];
    _errorMessage = null;
    notifyListeners();
  }

  void resetForTest() {
    _orders = OrderModel.sampleOrders;
    _selectedFilter = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  List<OrderModel> get allOrders => _orders;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  int get totalOrderCount => _orders.length;
  int get activeOrderCount => _orders.where((o) =>
      o.status == OrderStatus.pending ||
      o.status == OrderStatus.confirmed ||
      o.status == OrderStatus.packed ||
      o.status == OrderStatus.processing ||
      o.status == OrderStatus.shipped ||
      o.status == OrderStatus.inTransit ||
      o.status == OrderStatus.outForDelivery).length;
  int get deliveredOrderCount => _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get rtoOrderCount => _orders.where((o) =>
      o.status == OrderStatus.rtoInitiated ||
      o.status == OrderStatus.rtoInTransit ||
      o.status == OrderStatus.rtoDelivered).length;
  int get cancelledOrderCount => _orders.where((o) => o.status == OrderStatus.cancelled).length;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q.trim();
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    return _orders.where((order) {
      if (_selectedFilter == 'active') {
        if (order.status != OrderStatus.pending &&
            order.status != OrderStatus.confirmed &&
            order.status != OrderStatus.packed &&
            order.status != OrderStatus.processing &&
            order.status != OrderStatus.shipped &&
            order.status != OrderStatus.inTransit &&
            order.status != OrderStatus.outForDelivery) {
          return false;
        }
      } else if (_selectedFilter == 'delivered') {
        if (order.status != OrderStatus.delivered) return false;
      } else if (_selectedFilter == 'rto') {
        if (order.status != OrderStatus.rtoInitiated &&
            order.status != OrderStatus.rtoInTransit &&
            order.status != OrderStatus.rtoDelivered) {
          return false;
        }
      } else if (_selectedFilter == 'cancelled') {
        if (order.status != OrderStatus.cancelled) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesId = order.id.toLowerCase().contains(query);
        final matchesAwb = order.awbNumber.toLowerCase().contains(query);
        final matchesProduct = order.items.any((item) =>
            item.product.title.toLowerCase().contains(query) ||
            item.product.technicalName.toLowerCase().contains(query));
        if (!matchesId && !matchesAwb && !matchesProduct) return false;
      }

      return true;
    }).toList();
  }

  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}

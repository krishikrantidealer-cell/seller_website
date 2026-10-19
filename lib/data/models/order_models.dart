import 'package:flutter/material.dart';
import 'catalog_models.dart';

/// Status of an agricultural order
enum OrderStatus {
  confirmed,
  processing,
  inTransit,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Packed & Quality Checked';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFF2563EB); // Blue
      case OrderStatus.processing:
        return const Color(0xFFD97706); // Amber
      case OrderStatus.inTransit:
        return const Color(0xFF7C3AED); // Purple
      case OrderStatus.outForDelivery:
        return const Color(0xFF0284C7); // Sky Blue
      case OrderStatus.delivered:
        return const Color(0xFF16A34A); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626); // Crimson
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFFEFF6FF);
      case OrderStatus.processing:
        return const Color(0xFFFFFBEB);
      case OrderStatus.inTransit:
        return const Color(0xFFF5F3FF);
      case OrderStatus.outForDelivery:
        return const Color(0xFFF0F9FF);
      case OrderStatus.delivered:
        return const Color(0xFFF0FDF4);
      case OrderStatus.cancelled:
        return const Color(0xFFFEF2F2);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderStatus.inTransit:
        return Icons.local_shipping_outlined;
      case OrderStatus.outForDelivery:
        return Icons.directions_bike_rounded;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
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
    _orders = OrderModel.sampleOrders;
  }

  late List<OrderModel> _orders;
  String _selectedFilter = 'all'; // 'all', 'active', 'delivered', 'cancelled'
  String _searchQuery = '';

  void resetForTest() {
    _orders = OrderModel.sampleOrders;
    _selectedFilter = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  List<OrderModel> get allOrders => _orders;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  int get totalOrderCount => _orders.length;
  int get activeOrderCount => _orders.where((o) =>
      o.status == OrderStatus.confirmed ||
      o.status == OrderStatus.processing ||
      o.status == OrderStatus.inTransit ||
      o.status == OrderStatus.outForDelivery).length;
  int get deliveredOrderCount => _orders.where((o) => o.status == OrderStatus.delivered).length;

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
        if (order.status != OrderStatus.confirmed &&
            order.status != OrderStatus.processing &&
            order.status != OrderStatus.inTransit &&
            order.status != OrderStatus.outForDelivery) {
          return false;
        }
      } else if (_selectedFilter == 'delivered') {
        if (order.status != OrderStatus.delivered) return false;
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

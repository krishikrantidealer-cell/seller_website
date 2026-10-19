import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/order_models.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/web_footer.dart';

/// Screen displaying farmer's placed orders, live courier shipment tracking,
/// tax invoices, and quick re-ordering.
class MyOrdersView extends StatefulWidget {
  final String? initialOrderId;

  const MyOrdersView({
    super.key,
    this.initialOrderId,
  });

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _searchController;
  final Set<String> _expandedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: OrdersController.instance.searchQuery);

    // Expand initial order if provided or expand the first in-transit order by default
    if (widget.initialOrderId != null) {
      _expandedOrderIds.add(widget.initialOrderId!);
    } else {
      final active = OrdersController.instance.allOrders.where(
        (o) => o.status == OrderStatus.inTransit || o.status == OrderStatus.outForDelivery,
      );
      if (active.isNotEmpty) {
        _expandedOrderIds.add(active.first.id);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTracking(String orderId) {
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
      } else {
        _expandedOrderIds.add(orderId);
      }
    });
  }

  void _repeatOrder(OrderModel order) {
    for (final item in order.items) {
      CartController.instance.addItem(item.product, item.variant, item.quantity);
    }
    _scaffoldKey.currentState?.openEndDrawer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${order.items.length} item(s) from Order #${order.id} to your cart!',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context, OrderModel order) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 18 : 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'EBS BioCrop Science',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tax Invoice & Farm Delivery Receipt',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 14),

                // Order Meta
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice No:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                          Text('INV-${order.id}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date of Order:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                          Text(
                            '${order.orderDate.day} Oct ${order.orderDate.year}',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Mode:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                          Text(order.paymentMethod, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Farmer & Depot Address
                Text(
                  'Delivered To Farm Depot:',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  order.recipientName,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  order.recipientPhone,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600),
                ),
                Text(
                  order.deliveryAddress,
                  style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Items Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Product Description',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Items list
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Pack: ${item.variant.label}',
                                style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '₹${item.totalPrice.toStringAsFixed(0)}',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 10),

                // Calculation Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    Text('₹${order.subtotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                if (order.discount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kisan Subsidy / Discount:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryGreen)),
                      Text('-₹${order.discount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Farm Shipping & Logistics:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    Text('FREE', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFCBD5E1), height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount Payable:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800)),
                    Text('₹${order.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'EBS Invoice INV-${order.id} | Amount: ₹${order.totalAmount.toStringAsFixed(0)}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice details copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text('Copy Details', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice downloaded successfully (PDF saved).'),
                              backgroundColor: AppColors.primaryDarkGreen,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text('Download PDF', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpModal(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Help with Order #${order.id}?',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Direct Kisan Logistics Desk Support',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'For parcel delivery rescheduling, farm depot landmark guidance, or urgent crop input advice, our team is available 7 AM - 9 PM.',
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF0FDF4),
                child: Icon(Icons.phone_rounded, color: AppColors.primaryGreen),
              ),
              title: Text('Call Toll-Free Kisan Helpline', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: Text(AppConstants.helplineNumber, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
              trailing: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Call Now'),
              ),
            ),
            if (order.deliveryAgentPhone != null) ...[
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.two_wheeler_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text('Assigned Rural Delivery Rider', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: Text('${order.deliveryAgentName ?? "Rider"} • ${order.deliveryAgentPhone}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                trailing: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Call Rider'),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: OrdersController.instance,
      builder: (context, _) {
        final ordersCtrl = OrdersController.instance;
        final orders = ordersCtrl.filteredOrders;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          endDrawer: const QuickCartDrawer(),
          body: Column(
            children: [
              // Sticky Nav Header
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopInfoBar(),
                    MainNavHeader(
                      onCartTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                ),
              ),

              // Scrollable Orders Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 900;

                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24,
                              vertical: isMobile ? 12 : 24,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1400),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Breadcrumb Bar
                                    _buildBreadcrumb(context),
                                    const SizedBox(height: 14),

                                    // Hero Dashboard Banner
                                    _buildHeroBanner(ordersCtrl, isMobile),
                                    const SizedBox(height: 20),

                                    // Filter Tabs & Search Controls
                                    _buildFilterAndSearchBar(ordersCtrl, isMobile),
                                    const SizedBox(height: 20),

                                    // Orders List or Empty State
                                    if (orders.isEmpty)
                                      _buildEmptyState(context, ordersCtrl)
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: orders.length,
                                        separatorBuilder: (_, _) => const SizedBox(height: 18),
                                        itemBuilder: (context, index) {
                                          final order = orders[index];
                                          final isExpanded = _expandedOrderIds.contains(order.id);
                                          return _buildOrderCard(context, order, isExpanded, isMobile);
                                        },
                                      ),

                                    const SizedBox(height: 48),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Footer
                      const WebFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('/', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Home',
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Text('/', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            'My Orders & Shipment Tracking',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(OrdersController ctrl, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Orders & Farm Deliveries',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track live express courier shipments, download GST tax bills, and repeat previous orders.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: isMobile ? 11.5 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x33FFFFFF), height: 1),
          const SizedBox(height: 14),

          // Stat Pills
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildStatPill('📦 Total Placed', '${ctrl.totalOrderCount} Orders', Colors.white),
              _buildStatPill('🚚 In Transit', '${ctrl.activeOrderCount} Active', const Color(0xFFFEF08A)),
              _buildStatPill('✓ Delivered', '${ctrl.deliveredOrderCount} Completed', const Color(0xFFBBF7D0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 2,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.9), fontSize: 11.5),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(color: textColor, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar(OrdersController ctrl, bool isMobile) {
    final searchField = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => ctrl.setSearchQuery(val),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by Order ID (e.g. EBS-2026), AWB, or product name...',
          hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    ctrl.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );

    final filterChips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(ctrl, 'all', 'All Orders (${ctrl.totalOrderCount})'),
          const SizedBox(width: 8),
          _buildFilterChip(ctrl, 'active', 'In Transit & Active (${ctrl.activeOrderCount})'),
          const SizedBox(width: 8),
          _buildFilterChip(ctrl, 'delivered', 'Delivered (${ctrl.deliveredOrderCount})'),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField,
          const SizedBox(height: 12),
          filterChips,
        ],
      );
    }

    return Row(
      children: [
        filterChips,
        const SizedBox(width: 20),
        Expanded(child: searchField),
      ],
    );
  }

  Widget _buildFilterChip(OrdersController ctrl, String id, String label) {
    final isSelected = ctrl.selectedFilter == id;
    return InkWell(
      onTap: () => ctrl.setFilter(id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, bool isExpanded, bool isMobile) {
    final statusColor = order.status.color;
    final statusBg = order.status.backgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Card Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            order.id,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '• Placed on ${order.orderDate.day} Oct ${order.orderDate.year}',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(order.status.icon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        order.status.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Estimated Delivery & Courier Strip
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
            color: const Color(0xFFF0FDF4),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primaryDarkGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: order.status == OrderStatus.delivered ? 'Status: ' : 'Delivery Expected: ',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        TextSpan(
                          text: order.estimatedDelivery,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                        if (order.awbNumber.isNotEmpty) ...[
                          TextSpan(
                            text: ' • via ${order.courierName} (AWB: ${order.awbNumber})',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Order Items List
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Thumbnail
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            item.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFE2E8F0),
                              alignment: Alignment.center,
                              child: const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.product.technicalName} • ${item.product.vendor}',
                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Pack: ${item.variant.label}',
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Item Total
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(color: Color(0xFFE2E8F0), height: 20),

                // Farm Delivery Address & Payment Summary
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 650;
                    final addressBlock = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryGreen),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Delivery Farm Depot:',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.recipientName} (${order.recipientPhone})',
                          style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          order.deliveryAddress,
                          style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textMuted, height: 1.35),
                        ),
                      ],
                    );

                    final paymentBlock = Column(
                      crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Payment: ${order.paymentMethod}',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Paid: ',
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                            ),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          addressBlock,
                          const SizedBox(height: 12),
                          paymentBlock,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: addressBlock),
                        const SizedBox(width: 20),
                        paymentBlock,
                      ],
                    );
                  },
                ),

                // Collapsible Live Tracking Timeline Stepper
                if (isExpanded) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.alt_route_rounded, size: 18, color: AppColors.primaryGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Live Courier Transit Progress',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Stepper Checkpoints
                        ...order.trackingHistory.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final cp = entry.value;
                          final isLast = idx == order.trackingHistory.length - 1;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline Bullet & Line
                              Column(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cp.isCompleted
                                          ? AppColors.primaryGreen
                                          : (cp.isCurrent ? const Color(0xFF3B82F6) : Colors.white),
                                      border: Border.all(
                                        color: cp.isCompleted || cp.isCurrent
                                            ? Colors.transparent
                                            : const Color(0xFFCBD5E1),
                                        width: 2,
                                      ),
                                    ),
                                    child: cp.isCompleted
                                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                                        : null,
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 38,
                                      color: cp.isCompleted
                                          ? AppColors.primaryGreen
                                          : const Color(0xFFE2E8F0),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Checkpoint Information
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            cp.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.5,
                                              fontWeight: cp.isCurrent ? FontWeight.w800 : FontWeight.w600,
                                              color: cp.isCurrent ? const Color(0xFF1E40AF) : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${cp.date} • ${cp.time}',
                                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cp.description,
                                        style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                                      ),
                                      if (cp.location.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.pin_drop_outlined, size: 12, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                cp.location,
                                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        // Rider Contact strip if assigned
                        if (order.deliveryAgentPhone != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.two_wheeler_rounded, size: 18, color: Color(0xFF2563EB)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Delivery Rider: ${order.deliveryAgentName} (${order.deliveryAgentPhone})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E40AF),
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showHelpModal(context, order),
                                  icon: const Icon(Icons.phone, size: 14, color: Color(0xFF2563EB)),
                                  label: Text(
                                    'Contact',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB)),
                                  ),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 12),

                // Action Bar
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // Toggle Live Tracking
                    OutlinedButton.icon(
                      onPressed: () => _toggleTracking(order.id),
                      icon: Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.alt_route_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isExpanded ? 'Hide Live Tracking' : 'Track Shipment',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    // Download Invoice
                    OutlinedButton.icon(
                      onPressed: () => _showInvoiceDialog(context, order),
                      icon: const Icon(Icons.receipt_rounded, size: 16),
                      label: Text(
                        'Tax Invoice',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    // Repeat Order
                    ElevatedButton.icon(
                      onPressed: () => _repeatOrder(order),
                      icon: const Icon(Icons.repeat_rounded, size: 16),
                      label: Text(
                        'Buy Again',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    // Need Help
                    TextButton.icon(
                      onPressed: () => _showHelpModal(context, order),
                      icon: const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.textMuted),
                      label: Text(
                        'Need Help?',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OrdersController ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          Text(
            ctrl.searchQuery.isNotEmpty
                ? 'No orders found matching "${ctrl.searchQuery}"'
                : 'No orders found under this category',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Explore certified fertilizers, insecticides, and high-yield seeds to place your first farm depot order.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: Text(
              'Explore Agri Catalog',
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

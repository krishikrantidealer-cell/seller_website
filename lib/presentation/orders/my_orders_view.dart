import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/order_models.dart';
import 'order_detail_view.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: OrdersController.instance.searchQuery);

    if (widget.initialOrderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ord = OrdersController.instance.getOrderById(widget.initialOrderId!);
        if (ord != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailView(order: ord),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight <= 1.0 || constraints.maxWidth <= 1.0) {
                return const SizedBox.shrink();
              }
              return Column(
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

              // Scrollable Orders Content with Pinned Filter Bar
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 900;
                    final horizontalPadding = isMobile ? 12.0 : 24.0;
                    final sidePadding = math.max(horizontalPadding, (constraints.maxWidth - 1400) / 2);
                    final filterBarHeight = isMobile ? 88.0 : 62.0;

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // 1. Top Section (Breadcrumb + Hero Dashboard Banner)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            sidePadding,
                            isMobile ? 10 : 20,
                            sidePadding,
                            isMobile ? 8 : 16,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBreadcrumb(context, isMobile),
                                SizedBox(height: isMobile ? 8 : 14),
                                _buildHeroBanner(ordersCtrl, isMobile),
                              ],
                            ),
                          ),
                        ),

                        // 2. PINNED Filter & Search Bar - DOES NOT SCROLL AWAY
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _OrdersFilterHeaderDelegate(
                            height: filterBarHeight,
                            sidePadding: sidePadding,
                            child: _buildFilterAndSearchBar(ordersCtrl, isMobile),
                          ),
                        ),

                        // 3. Orders List or Empty State
                        if (orders.isEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              sidePadding,
                              20,
                              sidePadding,
                              isMobile ? 24 : 40,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildEmptyState(context, ordersCtrl),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              sidePadding,
                              isMobile ? 10 : 16,
                              sidePadding,
                              isMobile ? 24 : 48,
                            ),
                            sliver: SliverList.separated(
                              itemCount: orders.length,
                              separatorBuilder: (_, _) => SizedBox(height: isMobile ? 12 : 18),
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return _buildOrderCard(context, order, isMobile);
                              },
                            ),
                          ),

                        // 4. Integrated Web Footer
                        const SliverToBoxAdapter(
                          child: WebFooter(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  },
);
}

  Widget _buildBreadcrumb(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: isMobile ? 4 : 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: isMobile ? 14 : 16, color: AppColors.textPrimary),
                  SizedBox(width: isMobile ? 4 : 6),
                  Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 11.5 : 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 10),
          Text('/', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: isMobile ? 11.5 : 13)),
          SizedBox(width: isMobile ? 8 : 10),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Home',
              style: GoogleFonts.poppins(fontSize: isMobile ? 11.5 : 12.5, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Text('/', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: isMobile ? 11.5 : 13)),
          SizedBox(width: isMobile ? 6 : 8),
          Text(
            isMobile ? 'My Orders' : 'My Orders & Shipment Tracking',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(OrdersController ctrl, bool isMobile) {
    if (isMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Orders & Farm Deliveries',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Track express shipments, GST invoices & repeat orders.',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0x33FFFFFF), height: 1),
            const SizedBox(height: 8),

            // Compact Stat Pills on Mobile
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatPill('📦 Total Placed', '${ctrl.totalOrderCount} Orders', Colors.white, true),
                  const SizedBox(width: 8),
                  _buildStatPill('🚚 In Transit', '${ctrl.activeOrderCount} Active', const Color(0xFFFEF08A), true),
                  const SizedBox(width: 8),
                  _buildStatPill('✓ Delivered', '${ctrl.deliveredOrderCount} Completed', const Color(0xFFBBF7D0), true),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track live express courier shipments, download GST tax bills, and repeat previous orders.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13,
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
              _buildStatPill('📦 Total Placed', '${ctrl.totalOrderCount} Orders', Colors.white, false),
              _buildStatPill('🚚 In Transit', '${ctrl.activeOrderCount} Active', const Color(0xFFFEF08A), false),
              _buildStatPill('✓ Delivered', '${ctrl.deliveredOrderCount} Completed', const Color(0xFFBBF7D0), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color textColor, [bool isMobile = false]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 3 : 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: isMobile ? 4 : 6,
        runSpacing: 2,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: isMobile ? 10.5 : 11.5,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar(OrdersController ctrl, bool isMobile) {
    final searchField = Container(
      height: isMobile ? 36 : 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => ctrl.setSearchQuery(val),
        style: GoogleFonts.poppins(fontSize: isMobile ? 12 : 13, color: AppColors.textPrimary),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: isMobile
              ? 'Search Order ID, AWB, or product...'
              : 'Search by Order ID (e.g. EBS-2026), AWB, or product name...',
          hintStyle: GoogleFonts.poppins(fontSize: isMobile ? 11.5 : 12.5, color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search_rounded, size: isMobile ? 18 : 20, color: AppColors.textSecondary),
          prefixIconConstraints: BoxConstraints(minWidth: isMobile ? 34 : 40, minHeight: isMobile ? 36 : 42),
          suffixIconConstraints: BoxConstraints(minWidth: isMobile ? 32 : 38, minHeight: isMobile ? 36 : 42),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: isMobile ? 16 : 18, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _searchController.clear();
                    ctrl.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );

    final filterChips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip(ctrl, 'all', 'All Orders (${ctrl.totalOrderCount})', isMobile),
          SizedBox(width: isMobile ? 6 : 8),
          _buildFilterChip(ctrl, 'active', 'In Transit & Active (${ctrl.activeOrderCount})', isMobile),
          SizedBox(width: isMobile ? 6 : 8),
          _buildFilterChip(ctrl, 'delivered', 'Delivered (${ctrl.deliveredOrderCount})', isMobile),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 6),
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

  Widget _buildFilterChip(OrdersController ctrl, String id, String label, [bool isMobile = false]) {
    final isSelected = ctrl.selectedFilter == id;
    return InkWell(
      onTap: () => ctrl.setFilter(id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 5 : 8,
        ),
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
            fontSize: isMobile ? 11.5 : 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, bool isMobile) {
    final statusColor = order.status.color;
    final statusBg = order.status.backgroundColor;
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final remainingCount = order.items.length - 1;

    void openDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailView(order: order),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: openDetail,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Compact Header (Full Width)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 12 : 14)),
                  border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Order ID + Placed Date
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_rounded, size: isMobile ? 12 : 13, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  order.id,
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 11.5 : 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '• Placed on ${order.orderDate.day} Oct ${order.orderDate.year}',
                            style: GoogleFonts.poppins(fontSize: isMobile ? 10.5 : 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),

                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(order.status.icon, size: isMobile ? 11 : 13, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              order.status.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 10.5 : 11,
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
              ),

              // 2. Compact Body (Full Width)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Thumbnail (with multi-item indicator)
                    if (firstItem != null)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: isMobile ? 46 : 56,
                            height: isMobile ? 46 : 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              firstItem.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 20),
                              ),
                            ),
                          ),
                          if (remainingCount > 0)
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Text(
                                  '+$remainingCount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(width: isMobile ? 10 : 14),

                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstItem != null
                                ? '${firstItem.product.title}${remainingCount > 0 ? " + $remainingCount more item${remainingCount > 1 ? 's' : ''}" : ""}'
                                : 'Order #${order.id}',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 12.5 : 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${order.totalItemCount} item${order.totalItemCount > 1 ? 's' : ''} • ₹${order.totalAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 11.5 : 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDarkGreen,
                                ),
                              ),
                              Text(
                                '(${order.paymentMethod})',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 10 : 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Delivery: ${order.estimatedDelivery} via ${order.courierName}${order.awbNumber.isNotEmpty ? " (AWB: ${order.awbNumber})" : ""}',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 10.5 : 11.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFFE2E8F0), height: 1),

              // 3. Compact Footer Actions Bar (Full Width)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 14,
                  vertical: isMobile ? 6 : 8,
                ),
                child: Wrap(
                  spacing: isMobile ? 6 : 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // View Order Details (Primary Action)
                    ElevatedButton.icon(
                      onPressed: openDetail,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: Text(
                        'View Order Details',
                        style: GoogleFonts.poppins(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 5 : 8),
                        minimumSize: Size(0, isMobile ? 30 : 34),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),

                    // Quick Track Shipment
                    OutlinedButton.icon(
                      onPressed: openDetail,
                      icon: const Icon(Icons.alt_route_rounded, size: 14),
                      label: Text(
                        'Track Shipment',
                        style: GoogleFonts.poppins(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 5 : 8),
                        minimumSize: Size(0, isMobile ? 30 : 34),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),

                    // Buy Again
                    OutlinedButton.icon(
                      onPressed: () => _repeatOrder(order),
                      icon: const Icon(Icons.repeat_rounded, size: 14),
                      label: Text(
                        'Buy Again',
                        style: GoogleFonts.poppins(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 5 : 8),
                        minimumSize: Size(0, isMobile ? 30 : 34),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),

                    // Tax Invoice
                    OutlinedButton.icon(
                      onPressed: () => _showInvoiceDialog(context, order),
                      icon: const Icon(Icons.receipt_rounded, size: 14),
                      label: Text(
                        'Tax Invoice',
                        style: GoogleFonts.poppins(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 5 : 8),
                        minimumSize: Size(0, isMobile ? 30 : 34),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),

                    // Need Help
                    TextButton.icon(
                      onPressed: () => _showHelpModal(context, order),
                      icon: const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.textMuted),
                      label: Text(
                        'Need Help?',
                        style: GoogleFonts.poppins(fontSize: isMobile ? 10.5 : 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        minimumSize: Size(0, isMobile ? 30 : 34),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

/// Pinned sticky header delegate that keeps the order filter chips and search bar
/// fixed at the top of the viewport when scrolling through orders.
class _OrdersFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final double sidePadding;

  _OrdersFilterHeaderDelegate({
    required this.child,
    required this.height,
    required this.sidePadding,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isPinned = shrinkOffset > 0 || overlapsContent;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: isPinned
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              )
            : null,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _OrdersFilterHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.sidePadding != sidePadding ||
        oldDelegate.child != child;
  }
}


// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class KanbanPage extends StatefulComponent {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  String courierFilter = 'Semua';
  String searchQuery = '';

  // Thermal Shipping Label Modal State
  OrderItem? activeOrderForShippingLabel;

  // Tracking No Input Modal
  OrderItem? activeOrderForTracking;
  String trackingInput = '';

  void _advanceOrderStatus(OrderItem order, String newStatus) {
    if (newStatus == 'Dikirim') {
      setState(() {
        activeOrderForTracking = order;
        trackingInput = 'JNE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      });
      return;
    }
    AppStore().updateOrderStatus(order.id, newStatus);
    setState(() {});
  }

  void _saveTrackingNo() {
    if (activeOrderForTracking != null) {
      AppStore().updateOrderStatus(
        activeOrderForTracking!.id,
        'Dikirim',
        trackingNo: trackingInput.trim().isNotEmpty ? trackingInput.trim() : 'JNE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      );
      setState(() {
        activeOrderForTracking = null;
      });
    }
  }

  void _openWhatsApp(String phone, String orderNo) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final target = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : cleanPhone;
    final msg = Uri.encodeComponent('Halo kak, update pesanan Anda dengan No Invoice $orderNo sedang kami proses di Abel\'z Handmade.');
    html.window.open('https://wa.me/$target?text=$msg', '_blank');
  }

  @override
  Component build(BuildContext context) {
    final allOrders = AppStore().orders;

    final filtered = allOrders.where((o) {
      final matchesCourier = courierFilter == 'Semua' || o.courier.toLowerCase().contains(courierFilter.toLowerCase());
      final matchesSearch = o.orderNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          o.paymentMethod.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCourier && matchesSearch;
    }).toList();

    final pendingOrders = filtered.where((e) => e.status == 'Pending').toList();
    final processingOrders = filtered.where((e) => e.status == 'Diproses').toList();
    final shippingOrders = filtered.where((e) => e.status == 'Dikirim').toList();
    final completedOrders = filtered.where((e) => e.status == 'Selesai').toList();

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4 d-print-none', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-md-6', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis d-flex align-items-center gap-2', [
                i(classes: 'bi bi-kanban text-primary', []),
                Component.text('Fulfillment Kanban Board'),
              ]),
              p(classes: 'text-muted mb-0 fs-7', [
                Component.text('Papan alur pemrosesan fisik gudang: Masuk -> Packing -> Pengiriman -> Selesai.'),
              ]),
            ]),
            div(classes: 'col-md-6 text-md-end mt-3 mt-md-0 d-flex flex-wrap align-items-center justify-content-md-end gap-2', [
              // Search Input
              div(classes: 'input-group input-group-sm', styles: Styles(maxWidth: 220.px), [
                span(classes: 'input-group-text bg-body text-muted', [i(classes: 'bi bi-search', [])]),
                input(
                  type: InputType.text,
                  classes: 'form-control',
                  attributes: {'placeholder': 'Cari Order / Nama...'},
                  events: {'input': (e) => setState(() => searchQuery = (e.target as html.InputElement).value ?? '')},
                ),
              ]),
              // Courier Filter
              select(
                classes: 'form-select form-select-sm w-auto rounded-3',
                events: {'change': (e) => setState(() => courierFilter = (e.target as html.SelectElement).value ?? 'Semua')},
                [
                  option(value: 'Semua', [Component.text('Semua Kurir')]),
                  option(value: 'JNE', [Component.text('JNE Reguler')]),
                  option(value: 'Sicepat', [Component.text('Sicepat BEST')]),
                  option(value: 'GoSend', [Component.text('GoSend Instant')]),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-primary btn-sm rounded-3 shadow-xs',
                events: {'click': (e) => setState(() {})},
                [
                  i(classes: 'bi bi-arrow-clockwise me-1', []),
                  Component.text('Refresh'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Kanban Board Columns
      div(classes: 'row g-3 d-print-none', [
        _buildKanbanColumn('1. Pesanan Masuk', 'Pending', pendingOrders, 'border-warning', 'bg-warning-subtle text-warning-emphasis', 'bi-hourglass-split'),
        _buildKanbanColumn('2. Packing & Rajutan', 'Diproses', processingOrders, 'border-info', 'bg-info-subtle text-info-emphasis', 'bi-box-seam-fill'),
        _buildKanbanColumn('3. Pengiriman Kurir', 'Dikirim', shippingOrders, 'border-primary', 'bg-primary-subtle text-primary', 'bi-truck'),
        _buildKanbanColumn('4. Pesanan Selesai', 'Selesai', completedOrders, 'border-success', 'bg-success-subtle text-success', 'bi-check-circle-fill'),
      ]),

      // 3. Modal Input Resi
      if (activeOrderForTracking != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-75 d-print-none', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden bg-body', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
                  i(classes: 'bi bi-truck', []),
                  Component.text('Kirim Paket & Input Nomor Resi'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeOrderForTracking = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4 bg-body text-body', [
                p(classes: 'fs-7 text-muted mb-3', [
                  Component.text('Pesanan '),
                  strong(classes: 'text-body-emphasis', [Component.text(activeOrderForTracking!.orderNo)]),
                  Component.text(' siap diserahkan ke kurir '),
                  strong(classes: 'text-primary', [Component.text(activeOrderForTracking!.courier)]),
                  Component.text('. Masukkan nomor resi resmi pengiriman:'),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Nomor Resi / AWB Ekspedisi:')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control font-monospace fs-6 fw-bold text-primary',
                    value: trackingInput,
                    events: {'input': (e) => trackingInput = (e.target as html.InputElement).value ?? ''},
                  ),
                ]),
              ]),
              div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3 rounded-pill fw-semibold',
                  events: {'click': (e) => setState(() => activeOrderForTracking = null)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 rounded-pill fw-bold shadow-sm',
                  events: {'click': (e) => _saveTrackingNo()},
                  [
                    i(classes: 'bi bi-check2-circle me-1', []),
                    Component.text('Konfirmasi Kirim'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),

      // 4. Modal Cetak Thermal Label 10x15
      if (activeOrderForShippingLabel != null)
        _buildThermalLabelModal(activeOrderForShippingLabel!),
    ]);
  }

  Component _buildKanbanColumn(String title, String status, List<OrderItem> items, String borderColor, String badgeStyle, String icon) {
    return div(classes: 'col-12 col-md-6 col-xl-3', [
      div(classes: 'card border-0 shadow-sm rounded-4 bg-body-tertiary h-100', [
        // Column Header
        div(classes: 'card-header bg-body border-bottom border-2 $borderColor py-3 d-flex align-items-center justify-content-between rounded-top-4', [
          div(classes: 'd-flex align-items-center gap-2', [
            i(classes: 'bi $icon fs-6', []),
            h6(classes: 'fw-bold text-body-emphasis mb-0 fs-7', [Component.text(title)]),
          ]),
          span(classes: 'badge $badgeStyle rounded-pill px-2.5 py-1 fs-8 fw-bold', [
            Component.text(items.length.toString()),
          ]),
        ]),

        // Column Cards Container
        div(classes: 'card-body p-2 d-flex flex-column gap-2 overflow-y-auto', styles: Styles(maxHeight: 700.px), [
          if (items.isEmpty)
            div(classes: 'text-center py-5 text-muted fs-8', [
              i(classes: 'bi bi-inbox fs-3 d-block opacity-50 mb-1', []),
              Component.text('Tidak ada pesanan di tahap ini.'),
            ])
          else
            for (var order in items)
              _buildKanbanCard(order),
        ]),
      ]),
    ]);
  }

  Component _buildKanbanCard(OrderItem order) {
    return div(classes: 'card border shadow-xs rounded-3 p-3 bg-body hover-shadow transition-all', [
      // Top Row: Order No & Time
      div(classes: 'd-flex align-items-center justify-content-between mb-2', [
        span(classes: 'badge bg-body-tertiary text-body-emphasis border font-monospace fs-8', [Component.text(order.orderNo)]),
        small(classes: 'text-muted fs-8', [Component.text(order.date.split(',').first)]),
      ]),

      // Customer Info
      h6(classes: 'fw-bold text-body-emphasis fs-7 mb-1 text-truncate', [Component.text(order.customerName)]),
      div(classes: 'd-flex align-items-center gap-1 text-muted fs-8 mb-2', [
        i(classes: 'bi bi-telephone', []),
        Component.text(order.customerPhone),
      ]),

      // Products Summary
      div(classes: 'p-2 bg-body-tertiary rounded-2 border mb-2 fs-8', [
        for (var item in order.items.take(2))
          div(classes: 'd-flex justify-content-between text-truncate mb-0.5', [
            span(classes: 'text-body-emphasis text-truncate', styles: Styles(maxWidth: 160.px), [Component.text('${item.qty}x ${item.productName}')]),
            span(classes: 'fw-semibold text-secondary', [Component.text('Rp ${(item.price * item.qty).toInt()}')]),
          ]),
        if (order.items.length > 2)
          small(classes: 'text-primary fw-semibold d-block mt-0.5', [Component.text('+ ${order.items.length - 2} produk lainnya')]),
      ]),

      // Courier & Resi Info
      div(classes: 'd-flex align-items-center justify-content-between mb-2 fs-8', [
        span(classes: 'badge bg-body-tertiary text-primary border', [
          i(classes: 'bi bi-truck me-1', []),
          Component.text(order.courier.split(' ').first),
        ]),
        span(classes: 'badge ${order.paymentMethod.contains('Virtual Account') ? 'bg-primary-subtle text-primary' : 'bg-success-subtle text-success'} rounded-pill', [
          Component.text(order.paymentMethod.replaceAll('Virtual Account', 'VA')),
        ]),
      ]),

      if (order.trackingNo.isNotEmpty)
        div(classes: 'alert alert-info py-1 px-2 mb-2 fs-8 font-monospace text-truncate', [
          i(classes: 'bi bi-qr-code me-1', []),
          Component.text('Resi: ${order.trackingNo}'),
        ]),

      // Bottom Row: Total & Action Buttons
      div(classes: 'd-flex align-items-center justify-content-between border-top pt-2 mt-1', [
        div([
          small(classes: 'text-muted d-block fs-8', [Component.text('Total:')]),
          span(classes: 'fw-extrabold text-terracotta fs-7', [Component.text('Rp ${order.total.toInt()}')]),
        ]),
        div(classes: 'd-flex align-items-center gap-1', [
          // Thermal Label Print
          button(
            type: ButtonType.button,
            classes: 'btn btn-sm btn-outline-secondary rounded-circle p-1',
            attributes: {'title': 'Cetak Label Resi Thermal'},
            events: {'click': (e) => setState(() => activeOrderForShippingLabel = order)},
            [i(classes: 'bi bi-printer fs-8', [])],
          ),
          // WhatsApp
          button(
            type: ButtonType.button,
            classes: 'btn btn-sm btn-outline-success rounded-circle p-1',
            attributes: {'title': 'WhatsApp Pembeli'},
            events: {'click': (e) => _openWhatsApp(order.customerPhone, order.orderNo)},
            [i(classes: 'bi bi-whatsapp fs-8', [])],
          ),
          // Advance Action
          if (order.status == 'Pending')
            button(
              type: ButtonType.button,
              classes: 'btn btn-sm btn-info text-white rounded-pill px-2.5 py-0.5 fs-8 fw-bold',
              events: {'click': (e) => _advanceOrderStatus(order, 'Diproses')},
              [Component.text('Packing 📦')],
            )
          else if (order.status == 'Diproses')
            button(
              type: ButtonType.button,
              classes: 'btn btn-sm btn-primary text-white rounded-pill px-2.5 py-0.5 fs-8 fw-bold',
              events: {'click': (e) => _advanceOrderStatus(order, 'Dikirim')},
              [Component.text('Kirim 🚚')],
            )
          else if (order.status == 'Dikirim')
            button(
              type: ButtonType.button,
              classes: 'btn btn-sm btn-success text-white rounded-pill px-2.5 py-0.5 fs-8 fw-bold',
              events: {'click': (e) => _advanceOrderStatus(order, 'Selesai')},
              [Component.text('Selesai ✅')],
            ),
        ]),
      ]),
    ]);
  }

  Component _buildThermalLabelModal(OrderItem order) {
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered', styles: Styles(maxWidth: 420.px), [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden bg-body text-body', [
          div(classes: 'modal-header bg-dark text-white py-2.5 d-print-none', [
            h6(classes: 'modal-title fw-bold fs-7 mb-0', [Component.text('Label Resi Ekspedisi (Thermal 10x15)')]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => activeOrderForShippingLabel = null)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 text-dark', [
            // Thermal Sticker Container
            div(classes: 'p-3 border border-dark rounded-3 bg-white font-monospace text-start', [
              div(classes: 'd-flex justify-content-between align-items-center border-bottom border-dark pb-2 mb-2', [
                div([
                  h5(classes: 'fw-extrabold mb-0 text-dark', [Component.text(order.courier.toUpperCase())]),
                  small(classes: 'fs-8 text-muted', [Component.text('REGULER SERVICE')]),
                ]),
                img(
                  src: 'https://api.qrserver.com/v1/create-qr-code/?size=70x70&data=${order.orderNo}',
                  attributes: {'width': '55', 'height': '55', 'alt': 'QR AWB'},
                ),
              ]),
              div(classes: 'border-bottom border-dark pb-2 mb-2', [
                 small(classes: 'fs-8 text-muted d-block', [Component.text('NO. RESI / AWB:')]),
                span(classes: 'fw-bold fs-5 text-dark', [
                  Component.text(order.trackingNo.isNotEmpty ? order.trackingNo : 'JNE-DEFAULT-001'),
                ]),
              ]),
              div(classes: 'row g-2 border-bottom border-dark pb-2 mb-2 fs-8', [
                div(classes: 'col-6 border-end border-dark', [
                  strong(classes: 'd-block text-muted', [Component.text('PENERIMA:')]),
                  span(classes: 'fw-bold text-dark d-block', [Component.text(order.customerName)]),
                  span(classes: 'd-block text-muted', [Component.text(order.customerPhone)]),
                ]),
                div(classes: 'col-6', [
                  strong(classes: 'd-block text-muted', [Component.text('PENGIRIM:')]),
                  span(classes: 'fw-bold text-dark d-block', [Component.text("Abel'z Handmade")]),
                  span(classes: 'd-block text-muted', [Component.text('081234567890')]),
                ]),
              ]),
              div(classes: 'fs-8 text-muted', [
                strong(classes: 'd-block text-dark mb-1', [Component.text('DAFTAR ISI BARANG:')]),
                for (var item in order.items)
                  div(classes: 'd-flex justify-content-between', [
                    span([Component.text('- ${item.qty}x ${item.productName}')]),
                  ]),
              ]),
            ]),
          ]),
          div(classes: 'modal-footer bg-body-tertiary border-top py-2.5 d-print-none', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary btn-sm px-3 rounded-pill',
              events: {'click': (e) => setState(() => activeOrderForShippingLabel = null)},
              [Component.text('Tutup')],
            ),
            button(
              type: ButtonType.button,
              classes: 'btn btn-primary btn-sm px-4 rounded-pill fw-bold shadow-sm',
              events: {'click': (e) => html.window.print()},
              [
                i(classes: 'bi bi-printer me-1', []),
                Component.text('Cetak Label'),
              ],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}

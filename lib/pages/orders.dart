// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class OrdersPage extends StatefulComponent {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedStatus = 'Semua';
  String searchQuery = '';

  OrderItem? activeOrderForDetail;
  OrderItem? activeOrderForTracking;
  String trackingInput = '';

  OrderItem? activeOrderForCancel;
  String cancelReasonInput = 'Stok Barang Habis';

  OrderItem? activeOrderForShippingLabel;

  void _updateStatus(OrderItem order, String newStatus) {
    if (newStatus == 'Dikirim' && order.trackingNo.isEmpty) {
      setState(() {
        activeOrderForTracking = order;
        trackingInput = 'JNE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      });
      return;
    }

    if (newStatus == 'Dibatalkan') {
      setState(() {
        activeOrderForCancel = order;
        cancelReasonInput = 'Stok Barang Habis';
      });
      return;
    }

    AppStore().updateOrderStatus(order.id, newStatus);
    setState(() {});
  }

  void _saveTrackingNo() {
    if (activeOrderForTracking != null) {
      AppStore().updateOrderStatus(activeOrderForTracking!.id, 'Dikirim', trackingNo: trackingInput.trim());
      setState(() {
        activeOrderForTracking = null;
      });
    }
  }

  void _confirmCancelOrder() {
    if (activeOrderForCancel != null) {
      AppStore().updateOrderStatus(activeOrderForCancel!.id, 'Dibatalkan', cancelReason: cancelReasonInput);
      setState(() {
        activeOrderForCancel = null;
      });
    }
  }

  void _printShippingLabel() {
    html.window.print();
  }

  void _openWhatsApp(String phone, String orderNo) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent('Halo Kak, kami dari E-Comes Admin terkait pesanan nomor $orderNo.');
    html.window.open('https://wa.me/$cleanPhone?text=$msg', '_blank');
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final allOrders = store.orders;

    final filteredOrders = allOrders.where((o) {
      final matchesStatus = selectedStatus == 'Semua' || o.status == selectedStatus;
      final matchesSearch = o.orderNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          o.courier.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4 d-print-none', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis', [Component.text('Kelola Pesanan & Fulfillment Toko')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Verifikasi pembayaran, cetak label resi pengiriman, dan proses pengemasan.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-success btn-sm rounded-3 me-2',
                events: {'click': (e) => AppStore().exportOrdersToCsv()},
                [
                  i(classes: 'bi bi-file-earmark-spreadsheet me-1', []),
                  Component.text('Export CSV / Excel'),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-primary btn-sm rounded-3 me-2',
                events: {'click': (e) => setState(() {})},
                [
                  i(classes: 'bi bi-arrow-clockwise me-1', []),
                  Component.text('Refresh Data'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Status Filter Pills
      div(classes: 'card shadow-sm border-0 mb-4 rounded-3 p-2 bg-body d-print-none', [
        div(classes: 'd-flex flex-wrap align-items-center justify-content-between gap-2', [
          ul(classes: 'nav nav-pills gap-1', [
            _buildFilterPill('Semua', allOrders.length),
            _buildFilterPill('Pending', allOrders.where((e) => e.status == 'Pending').length, colorClass: 'bg-warning text-dark'),
            _buildFilterPill('Diproses', allOrders.where((e) => e.status == 'Diproses').length, colorClass: 'bg-info text-dark'),
            _buildFilterPill('Dikirim', allOrders.where((e) => e.status == 'Dikirim').length, colorClass: 'bg-primary'),
            _buildFilterPill('Selesai', allOrders.where((e) => e.status == 'Selesai').length, colorClass: 'bg-success'),
            _buildFilterPill('Dibatalkan', allOrders.where((e) => e.status == 'Dibatalkan').length, colorClass: 'bg-danger'),
          ]),
          div(classes: 'input-group input-group-sm', styles: Styles(width: 220.px), [
            span(classes: 'input-group-text bg-body-tertiary border-end-0', [i(classes: 'bi bi-search', [])]),
            input(
              type: InputType.text,
              classes: 'form-control border-start-0',
              value: searchQuery,
              attributes: {'placeholder': 'Cari No. Order / Pembeli...'},
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
      ]),

      // 3. Orders Table
      div(classes: 'card shadow-sm border-0 rounded-3 bg-body d-print-none', [
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3 text-nowrap', [Component.text('No. Invoice & Tanggal')]),
                  th(classes: 'text-nowrap', [Component.text('Pelanggan')]),
                  th(classes: 'text-nowrap', [Component.text('Metode Pembayaran')]),
                  th(classes: 'text-nowrap', [Component.text('Ekspedisi & Resi')]),
                  th(classes: 'text-nowrap', [Component.text('Total Transaksi')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Status')]),
                  th(classes: 'text-end pe-3 text-nowrap', [Component.text('Aksi Status & Label')]),
                ]),
              ]),
              tbody([
                if (filteredOrders.isEmpty)
                  tr([
                    td(attributes: {'colspan': '7'}, classes: 'text-center py-5 text-muted', [
                      i(classes: 'bi bi-inbox fs-1 d-block mb-2 text-secondary', []),
                      Component.text('Tidak ada pesanan pada kategori ini.'),
                    ]),
                  ])
                else
                  for (var o in filteredOrders)
                    tr([
                      td(classes: 'ps-3 text-nowrap', [
                        div([
                          div(classes: 'fw-bold fs-7 text-primary', [Component.text(o.orderNo)]),
                          div(classes: 'text-muted fs-8', [Component.text(o.date)]),
                        ]),
                      ]),
                      td([
                        div([
                          div(classes: 'fw-semibold fs-7 text-body-emphasis', [Component.text(o.customerName)]),
                          button(
                            type: ButtonType.button,
                            classes: 'btn btn-link btn-sm p-0 text-success text-decoration-none fs-8',
                            events: {'click': (e) => _openWhatsApp(o.customerPhone, o.orderNo)},
                            [
                              i(classes: 'bi bi-whatsapp me-1', []),
                              Component.text(o.customerPhone),
                            ],
                          ),
                        ]),
                      ]),
                      td(classes: 'fs-7 text-nowrap', [
                        span(classes: 'badge bg-body-secondary text-body-emphasis border', [Component.text(o.paymentMethod)]),
                      ]),
                      td(classes: 'fs-7 text-nowrap', [
                        div(classes: 'fw-semibold text-body-emphasis', [Component.text(o.courier)]),
                        if (o.trackingNo.isNotEmpty)
                          small(classes: 'text-primary fw-bold fs-8', [Component.text('Resi: ${o.trackingNo}')])
                        else
                          small(classes: 'text-muted fs-8', [Component.text('Belum ada resi')]),
                      ]),
                      td(classes: 'fw-bold fs-7 text-body-emphasis text-nowrap', [Component.text('Rp ${o.total.toInt()}')]),
                      td(classes: 'text-nowrap', [
                        span(classes: 'badge ${_getStatusBadge(o.status)} rounded-pill fs-8', [
                          Component.text(o.status),
                        ]),
                        if (o.cancelReason.isNotEmpty)
                          small(classes: 'text-danger d-block fs-8', [Component.text('Alasan: ${o.cancelReason}')]),
                      ]),
                      td(classes: 'text-end pe-3 text-nowrap', [
                        div(classes: 'd-flex align-items-center justify-content-end gap-1', [
                          // 1. Detail Button
                          button(
                            type: ButtonType.button,
                            classes: 'btn btn-sm btn-outline-secondary border text-primary rounded-circle shadow-sm px-2 py-1',
                            attributes: {'title': 'Lihat Rincian & Detail Pesanan', 'data-bs-toggle': 'tooltip'},
                            events: {'click': (e) => setState(() => activeOrderForDetail = o)},
                            [i(classes: 'bi bi-eye-fill fs-7', [])],
                          ),

                          // 2. Status Action Button
                          if (o.status == 'Pending')
                            button(
                              type: ButtonType.button,
                              classes: 'btn btn-sm btn-info text-white rounded-circle shadow-sm px-2 py-1',
                              attributes: {'title': 'Proses Pesanan (Mulai Packing)', 'data-bs-toggle': 'tooltip'},
                              events: {'click': (e) => _updateStatus(o, 'Diproses')},
                              [i(classes: 'bi bi-box-seam-fill fs-7', [])],
                            ),
                          if (o.status == 'Diproses')
                            button(
                              type: ButtonType.button,
                              classes: 'btn btn-sm btn-primary text-white rounded-circle shadow-sm px-2 py-1',
                              attributes: {'title': 'Kirim Paket & Input No Resi', 'data-bs-toggle': 'tooltip'},
                              events: {'click': (e) => _updateStatus(o, 'Dikirim')},
                              [i(classes: 'bi bi-truck fs-7', [])],
                            ),
                          if (o.status == 'Dikirim')
                            button(
                              type: ButtonType.button,
                              classes: 'btn btn-sm btn-success text-white rounded-circle shadow-sm px-2 py-1',
                              attributes: {'title': 'Tandai Pesanan Selesai / Diterima', 'data-bs-toggle': 'tooltip'},
                              events: {'click': (e) => _updateStatus(o, 'Selesai')},
                              [i(classes: 'bi bi-check-circle-fill fs-7', [])],
                            ),

                          // 3. Print Shipping Label Button
                          button(
                            type: ButtonType.button,
                            classes: 'btn btn-sm btn-warning text-dark rounded-circle shadow-sm px-2 py-1',
                            attributes: {'title': 'Cetak Stiker Resi Pengiriman (Thermal Label)', 'data-bs-toggle': 'tooltip'},
                            events: {'click': (e) => setState(() => activeOrderForShippingLabel = o)},
                            [i(classes: 'bi bi-printer-fill fs-7', [])],
                          ),

                          // 4. WhatsApp Contact Button
                          button(
                            type: ButtonType.button,
                            classes: 'btn btn-sm btn-success text-white rounded-circle shadow-sm px-2 py-1',
                            attributes: {'title': 'Chat WhatsApp Customer (${o.customerPhone})', 'data-bs-toggle': 'tooltip'},
                            events: {'click': (e) => _openWhatsApp(o.customerPhone, o.orderNo)},
                            [i(classes: 'bi bi-whatsapp fs-7', [])],
                          ),

                          // 5. Cancel Button
                          if (o.status != 'Selesai' && o.status != 'Dibatalkan')
                            button(
                              type: ButtonType.button,
                              classes: 'btn btn-sm btn-outline-danger rounded-circle shadow-sm px-2 py-1',
                              attributes: {'title': 'Batalkan Pesanan Ini', 'data-bs-toggle': 'tooltip'},
                              events: {'click': (e) => _updateStatus(o, 'Dibatalkan')},
                              [i(classes: 'bi bi-x-circle-fill fs-7', [])],
                            ),
                        ]),
                      ]),
                    ]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 3.5. Modal Detail Rincian Pesanan
      if (activeOrderForDetail != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-75 d-print-none', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                div(classes: 'd-flex align-items-center gap-2', [
                  i(classes: 'bi bi-receipt fs-4', []),
                  div([
                    h5(classes: 'modal-title fw-bold fs-6 mb-0', [
                      Component.text('Rincian Pesanan: ${activeOrderForDetail!.orderNo}'),
                    ]),
                    small(classes: 'opacity-75 fs-8', [
                      Component.text('Tanggal: ${activeOrderForDetail!.date}'),
                    ]),
                  ]),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeOrderForDetail = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4 bg-body-tertiary', [
                div(classes: 'row g-3 mb-4', [
                  div(classes: 'col-md-6', [
                    div(classes: 'p-3 bg-body rounded-3 border shadow-sm h-100', [
                      h6(classes: 'fw-bold text-body-emphasis fs-7 mb-2 border-bottom pb-2', [
                        i(classes: 'bi bi-person-fill text-primary me-2', []),
                        Component.text('Informasi Pemesan'),
                      ]),
                      p(classes: 'mb-1 fs-7 text-body-emphasis fw-bold', [Component.text(activeOrderForDetail!.customerName)]),
                      p(classes: 'mb-1 fs-7 text-muted', [
                        i(classes: 'bi bi-telephone me-1', []),
                        Component.text(activeOrderForDetail!.customerPhone),
                      ]),
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-success rounded-pill mt-2 px-3 fs-8 fw-bold',
                        events: {'click': (e) => _openWhatsApp(activeOrderForDetail!.customerPhone, activeOrderForDetail!.orderNo)},
                        [
                          i(classes: 'bi bi-whatsapp me-1', []),
                          Component.text('Chat Customer via WhatsApp'),
                        ],
                      ),
                    ]),
                  ]),
                  div(classes: 'col-md-6', [
                    div(classes: 'p-3 bg-body rounded-3 border shadow-sm h-100', [
                      h6(classes: 'fw-bold text-body-emphasis fs-7 mb-2 border-bottom pb-2', [
                        i(classes: 'bi bi-truck text-primary me-2', []),
                        Component.text('Status & Pengiriman'),
                      ]),
                      div(classes: 'd-flex align-items-center justify-content-between mb-2', [
                        span(classes: 'text-muted fs-7', [Component.text('Status Pesanan:')]),
                        span(classes: 'badge ${_getStatusBadge(activeOrderForDetail!.status)} rounded-pill fs-8', [
                          Component.text(activeOrderForDetail!.status),
                        ]),
                      ]),
                      p(classes: 'mb-1 fs-7 text-body-emphasis fw-semibold', [
                        Component.text('Ekspedisi: ${activeOrderForDetail!.courier}'),
                      ]),
                      p(classes: 'mb-1 fs-7 text-muted', [
                        Component.text('Metode Bayar: ${activeOrderForDetail!.paymentMethod}'),
                      ]),
                      if (activeOrderForDetail!.vaNumber.isNotEmpty)
                        p(classes: 'mb-1 fs-8 text-primary fw-bold font-monospace', [
                          Component.text('No. VA: ${activeOrderForDetail!.vaNumber}'),
                        ]),
                      if (activeOrderForDetail!.trackingNo.isNotEmpty)
                        p(classes: 'mb-0 fs-7 text-primary fw-bold font-monospace', [
                          Component.text('No Resi: ${activeOrderForDetail!.trackingNo}'),
                        ])
                      else
                        p(classes: 'mb-0 fs-8 text-muted', [Component.text('No Resi belum diinput')]),
                    ]),
                  ]),
                ]),
                div(classes: 'bg-body rounded-3 border shadow-sm p-3 mb-3', [
                  h6(classes: 'fw-bold text-body-emphasis fs-7 mb-3 border-bottom pb-2', [
                    i(classes: 'bi bi-bag-fill text-primary me-2', []),
                    Component.text('Daftar Produk Yang Dipesan'),
                  ]),
                  table(classes: 'table table-hover align-middle mb-0 fs-7', [
                    thead(classes: 'table-light fs-7', [
                      tr([
                        th([Component.text('Nama Produk')]),
                        th(classes: 'text-center', [Component.text('Jumlah')]),
                        th(classes: 'text-end', [Component.text('Harga Satuan')]),
                        th(classes: 'text-end', [Component.text('Subtotal')]),
                      ]),
                    ]),
                    tbody([
                      for (var item in activeOrderForDetail!.items)
                        tr([
                          td(classes: 'fw-semibold text-body-emphasis', [
                            Component.text(item.productName),
                            if (item.customColor.isNotEmpty || item.yarnType.isNotEmpty)
                              span(classes: 'badge bg-danger-subtle text-danger ms-2 fs-8', [
                                Component.text('${item.yarnType} • ${item.customColor}'),
                              ]),
                            if (item.customNotes.isNotEmpty)
                              small(classes: 'text-muted d-block fs-8 fst-italic', [Component.text('Catatan: ${item.customNotes}')]),
                          ]),
                          td(classes: 'text-center fw-bold', [Component.text('x${item.qty}')]),
                          td(classes: 'text-end text-muted', [Component.text('Rp ${item.price.toInt()}')]),
                          td(classes: 'text-end fw-bold text-body-emphasis', [Component.text('Rp ${(item.price * item.qty).toInt()}')]),
                        ]),
                    ]),
                  ]),
                  div(classes: 'd-flex justify-content-between align-items-center border-top pt-3 mt-3', [
                    span(classes: 'fw-bold text-body-emphasis fs-6', [Component.text('Total Pembayaran:')]),
                    span(classes: 'fw-extrabold text-danger fs-5', [Component.text('Rp ${activeOrderForDetail!.total.toInt()}')]),
                  ]),
                ]),
              ]),
              div(classes: 'modal-footer bg-body border-top py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3 rounded-pill fw-semibold',
                  events: {'click': (e) => setState(() => activeOrderForDetail = null)},
                  [Component.text('Tutup')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-3 rounded-pill fw-semibold',
                  events: {
                    'click': (e) {
                      final target = activeOrderForDetail!;
                      setState(() {
                        activeOrderForDetail = null;
                        activeOrderForShippingLabel = target;
                      });
                    }
                  },
                  [
                    i(classes: 'bi bi-printer me-1', []),
                    Component.text('Cetak Label Thermal'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),

      // 4. Modal Input Resi
      if (activeOrderForTracking != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50 d-print-none', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content bg-body text-body border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  i(classes: 'bi bi-truck me-2', []),
                  Component.text('Input Nomor Resi Ekspedisi'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeOrderForTracking = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4 bg-body', [
                p(classes: 'fs-7 text-muted mb-3', [
                  Component.text('Masukkan nomor resi resmi pengiriman untuk pesanan '),
                  strong([Component.text(activeOrderForTracking!.orderNo)]),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Nomor Resi / Tracking Airwaybill')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: trackingInput,
                    events: {
                      'input': (e) {
                        trackingInput = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
              ]),
              div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => activeOrderForTracking = null)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold shadow-sm',
                  events: {'click': (e) => _saveTrackingNo()},
                  [Component.text('Simpan Nomor Resi')],
                ),
              ]),
            ]),
          ]),
        ]),

      // 5. Modal Cancel Order Reason
      if (activeOrderForCancel != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50 d-print-none', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content bg-body text-body border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-danger text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  i(classes: 'bi bi-x-circle me-2', []),
                  Component.text('Pembatalan Pesanan Toko'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeOrderForCancel = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4 bg-body', [
                p(classes: 'fs-7 text-muted mb-3', [
                  Component.text('Silakan pilih alasan pembatalan untuk pesanan '),
                  strong([Component.text(activeOrderForCancel!.orderNo)]),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Alasan Utama Pembatalan')]),
                  select(
                    classes: 'form-select',
                    events: {
                      'change': (e) {
                        cancelReasonInput = (e.target as html.SelectElement).value ?? '';
                      }
                    },
                    [
                      option(value: 'Stok Barang Habis', [Component.text('Stok Barang Habis / Kosong')]),
                      option(value: 'Pembeli Meminta Batal', [Component.text('Pembeli Meminta Batal')]),
                      option(value: 'Alamat Tidak Terjangkau Kurir', [Component.text('Alamat Tidak Terjangkau Kurir')]),
                      option(value: 'Pembayaran Gagal / Kadaluarsa', [Component.text('Pembayaran Gagal / Kadaluarsa')]),
                    ],
                  ),
                ]),
              ]),
              div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => activeOrderForCancel = null)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-danger px-4 fw-semibold',
                  events: {'click': (e) => _confirmCancelOrder()},
                  [
                    i(classes: 'bi bi-check-circle me-1', []),
                    Component.text('Konfirmasi Batalkan Pesanan'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),

      // 5. Thermal Shipping Label View
      if (activeOrderForShippingLabel != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content bg-body text-body border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-dark text-white py-2 d-print-none', [
                h6(classes: 'modal-title fw-bold mb-0', [Component.text('Pratinjau Label Resi Thermal')]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeOrderForShippingLabel = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-3 bg-body-tertiary d-flex justify-content-center', [
                div(
                  classes: 'bg-white p-4 border border-2 border-dark rounded-3 shadow text-dark font-sans-serif',
                  styles: Styles(width: 380.px, minHeight: 520.px),
                  [
                    div(classes: 'd-flex align-items-center justify-content-between border-bottom border-3 border-dark pb-2 mb-3', [
                      h4(classes: 'fw-bold mb-0 text-uppercase', [Component.text(activeOrderForShippingLabel!.courier)]),
                      span(classes: 'badge bg-dark text-white fs-7 px-2 py-1', [Component.text('REGULER')]),
                    ]),
                    div(classes: 'text-center border-bottom border-2 border-dark pb-3 mb-3', [
                      img(
                        src: 'https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${activeOrderForShippingLabel!.trackingNo.isEmpty ? activeOrderForShippingLabel!.orderNo : activeOrderForShippingLabel!.trackingNo}',
                        attributes: {'width': '100', 'height': '100', 'alt': 'Barcode Resi'},
                      ),
                      div(classes: 'fw-bold fs-6 font-monospace mt-2 text-uppercase', [
                        Component.text(activeOrderForShippingLabel!.trackingNo.isEmpty ? 'RESI: PENDING' : activeOrderForShippingLabel!.trackingNo),
                      ]),
                      small(classes: 'text-muted fs-8 font-monospace', [Component.text(activeOrderForShippingLabel!.orderNo)]),
                    ]),
                    div(classes: 'row g-2 mb-3 fs-7 border-bottom border-2 border-dark pb-3', [
                      div(classes: 'col-6 border-end pe-2', [
                        strong(classes: 'd-block text-uppercase fs-8 text-muted', [Component.text('PENGIRIM:')]),
                        div(classes: 'fw-bold', [Component.text(store.settings.storeName)]),
                        small(classes: 'd-block text-muted fs-8', [Component.text(store.settings.phone)]),
                      ]),
                      div(classes: 'col-6 ps-2', [
                        strong(classes: 'd-block text-uppercase fs-8 text-muted', [Component.text('PENERIMA:')]),
                        div(classes: 'fw-bold', [Component.text(activeOrderForShippingLabel!.customerName)]),
                        small(classes: 'd-block text-muted fs-8', [Component.text(activeOrderForShippingLabel!.customerPhone)]),
                        small(classes: 'd-block text-muted fs-8 mt-1', [Component.text('Jl. Raya Pengiriman No. 12, DKI Jakarta')]),
                      ]),
                    ]),
                    div([
                      strong(classes: 'd-block text-uppercase fs-8 text-muted mb-1', [Component.text('ISI PAKET / ITEMS:')]),
                      ul(classes: 'list-unstyled mb-0 fs-8', [
                        for (var item in activeOrderForShippingLabel!.items)
                          li(classes: 'd-flex justify-content-between border-bottom py-1', [
                            div([
                              span(classes: 'fw-semibold', [Component.text(item.productName)]),
                              if (item.customColor.isNotEmpty || item.yarnType.isNotEmpty)
                                small(classes: 'd-block text-muted fs-9', [Component.text('(${item.yarnType} - ${item.customColor})')]),
                            ]),
                            span(classes: 'fw-bold ms-2', [Component.text('x${item.qty}')]),
                          ]),
                      ]),
                    ]),
                  ],
                ),
              ]),
              div(classes: 'modal-footer bg-body border-top py-3 d-print-none', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => activeOrderForShippingLabel = null)},
                  [Component.text('Tutup')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold shadow-sm',
                  events: {'click': (e) => _printShippingLabel()},
                  [
                    i(classes: 'bi bi-printer me-1', []),
                    Component.text('Cetak Stiker Label Thermal'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
    ]);
  }

  Component _buildFilterPill(String status, int count, {String colorClass = 'bg-primary'}) {
    final isActive = selectedStatus == status;

    return li(classes: 'nav-item', [
      button(
        type: ButtonType.button,
        classes: 'nav-link rounded-pill px-3 py-1 fs-7 ${isActive ? 'active bg-primary text-white fw-bold shadow-sm' : 'text-body-emphasis bg-body-tertiary'}',
        events: {'click': (e) => setState(() => selectedStatus = status)},
        [
          Component.text(status),
          span(classes: 'badge ${isActive ? 'bg-white text-primary' : colorClass} rounded-pill ms-2 fs-8', [
            Component.text(count.toString()),
          ]),
        ],
      ),
    ]);
  }

  String _getStatusBadge(String status) {
    switch (status) {
      case 'Pending':
        return 'bg-warning text-dark';
      case 'Diproses':
        return 'bg-info text-dark';
      case 'Dikirim':
        return 'bg-primary';
      case 'Selesai':
        return 'bg-success';
      case 'Dibatalkan':
        return 'bg-danger';
      default:
        return 'bg-secondary';
    }
  }
}

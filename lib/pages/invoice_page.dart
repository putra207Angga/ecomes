// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class InvoicePage extends StatefulComponent {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late String selectedOrderId;

  @override
  void initState() {
    super.initState();
    final store = AppStore();
    selectedOrderId = store.orders.isNotEmpty ? store.orders.first.id : 'ORD-2026-001';
  }

  void _printInvoice() {
    html.window.print();
  }

  void _downloadInvoiceData(OrderItem order) {
    final csvRows = [
      'No. Invoice,Pelanggan,Tanggal,Kurir,Metode Pembayaran,Total',
      '"${order.orderNo}","${order.customerName}","${order.date}","${order.courier}","${order.paymentMethod}",${order.total}'
    ];
    final csvContent = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(csvRows.join('\n'))}';
    html.AnchorElement(href: csvContent)
      ..setAttribute('download', 'invoice_${order.id}.csv')
      ..click();
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final orders = store.orders;
    final order = orders.firstWhere((o) => o.id == selectedOrderId, orElse: () => orders.first);

    final subtotal = order.total / 1.11;
    final tax = order.total - subtotal;

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header Actions (Hidden when printing)
      div(classes: 'app-content-header mb-4 d-print-none', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis', [Component.text('Lembar Invoice & Faktur Resmi')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Cetak dokumen transaksi resmi untuk pelanggan & arsip akuntansi.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0 d-flex align-items-center justify-content-sm-end gap-2', [
              select(
                classes: 'form-select form-select-sm w-auto rounded-3',
                events: {
                  'change': (e) {
                    setState(() {
                      selectedOrderId = (e.target as html.SelectElement).value ?? '';
                    });
                  }
                },
                [
                  for (var o in orders)
                    option(value: o.id, selected: selectedOrderId == o.id, [
                      Component.text('${o.orderNo} (${o.customerName})'),
                    ]),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-secondary btn-sm rounded-3',
                events: {'click': (e) => _downloadInvoiceData(order)},
                [
                  i(classes: 'bi bi-download me-1', []),
                  Component.text('Export CSV'),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm fw-semibold rounded-3 px-3 shadow-sm',
                events: {'click': (e) => _printInvoice()},
                [
                  i(classes: 'bi bi-printer me-1', []),
                  Component.text('Cetak Invoice'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Printable Invoice Sheet Card
      div(
        classes: 'card shadow border-0 rounded-4 overflow-hidden bg-white text-dark p-4 p-md-5 mx-auto',
        styles: Styles(maxWidth: 860.px),
        [
        div(classes: 'invoice-header border-bottom pb-4 mb-4', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-6', [
              h2(classes: 'fw-bold text-primary mb-1 d-flex align-items-center gap-2', [
                i(classes: 'bi bi-bag-check-fill', []),
                Component.text('E-COMES'),
              ]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text(store.settings.storeName)]),
              small(classes: 'text-muted fs-8 d-block', [Component.text(store.settings.address)]),
              small(classes: 'text-muted fs-8 d-block', [Component.text('WA: ${store.settings.phone} | Email: ${store.settings.email}')]),
            ]),
            div(classes: 'col-6 text-end', [
              h4(classes: 'fw-bold text-dark mb-1', [Component.text('INVOICE')]),
              div(classes: 'fw-bold text-primary fs-6 font-monospace mb-1', [Component.text(order.orderNo)]),
              span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill fs-7 px-3 py-1', [
                i(classes: 'bi bi-check-circle-fill me-1', []),
                Component.text('LUNAS / PAID'),
              ]),
              small(classes: 'text-muted d-block mt-2 fs-8', [Component.text('Tanggal: ${order.date}')]),
            ]),
          ]),
        ]),

        // Customer & Order Info Row
        div(classes: 'row mb-4 fs-7', [
          div(classes: 'col-sm-6 mb-3 mb-sm-0', [
            h6(classes: 'fw-bold text-dark text-uppercase fs-8 mb-2 text-muted', [Component.text('DITUJUKAN KEPADA:')]),
            div(classes: 'fw-bold text-dark fs-6', [Component.text(order.customerName)]),
            div(classes: 'text-muted', [Component.text('Telepon / WA: ${order.customerPhone}')]),
            div(classes: 'text-muted', [Component.text('Metode Pembayaran: ${order.paymentMethod}')]),
          ]),
          div(classes: 'col-sm-6 text-sm-end', [
            h6(classes: 'fw-bold text-dark text-uppercase fs-8 mb-2 text-muted', [Component.text('INFO PENGIRIMAN:')]),
            div(classes: 'fw-bold text-dark', [Component.text('Kurir: ${order.courier}')]),
            if (order.trackingNo.isNotEmpty)
              div(classes: 'text-primary fw-bold font-monospace', [Component.text('No. Resi: ${order.trackingNo}')]),
            div(classes: 'text-muted', [Component.text('Status: ${order.status}')]),
          ]),
        ]),

        // Products Table
        div(classes: 'table-responsive mb-4', [
          table(classes: 'table table-bordered align-middle', [
            thead(classes: 'table-light fs-7', [
              tr([
                th(classes: 'text-center', styles: Styles(width: 50.px), [Component.text('#')]),
                th([Component.text('Item Produk')]),
                th(classes: 'text-center', styles: Styles(width: 80.px), [Component.text('Qty')]),
                th(classes: 'text-end', styles: Styles(width: 150.px), [Component.text('Harga Satuan')]),
                th(classes: 'text-end', styles: Styles(width: 150.px), [Component.text('Total (Rp)')]),
              ]),
            ]),
            tbody([
              for (var i = 0; i < order.items.length; i++)
                tr([
                  td(classes: 'text-center fs-7', [Component.text('${i + 1}')]),
                  td(classes: 'fs-7 fw-semibold text-dark', [Component.text(order.items[i].productName)]),
                  td(classes: 'text-center fs-7', [Component.text('${order.items[i].qty}')]),
                  td(classes: 'text-end fs-7', [Component.text('Rp ${order.items[i].price.toInt()}')]),
                  td(classes: 'text-end fs-7 fw-bold', [Component.text('Rp ${(order.items[i].price * order.items[i].qty).toInt()}')]),
                ]),
            ]),
          ]),
        ]),

        // Totals & QRIS Row
        div(classes: 'row align-items-center', [
          div(classes: 'col-md-6 mb-3 mb-md-0', [
            div(classes: 'p-3 bg-light rounded-3 border d-flex align-items-center gap-3', [
              div(classes: 'bg-white p-2 rounded border shadow-sm', [
                img(src: 'https://api.qrserver.com/v1/create-qr-code/?size=80x80&data=${order.orderNo}', attributes: {'width': '70', 'height': '70', 'alt': 'QRIS'}),
              ]),
              div([
                h6(classes: 'fw-bold text-dark mb-1 fs-7', [Component.text('QRIS Verification Code')]),
                small(classes: 'text-muted fs-8 d-block', [Component.text('Scan QR di atas untuk verifikasi keabsahan invoice ini di sistem e-commerce.')]),
              ]),
            ]),
          ]),
          div(classes: 'col-md-6 text-end fs-7', [
            div(classes: 'd-flex justify-content-between py-1 border-bottom', [
              span(classes: 'text-muted', [Component.text('Subtotal Produk:')]),
              span(classes: 'fw-semibold text-dark', [Component.text('Rp ${subtotal.toInt()}')]),
            ]),
            div(classes: 'd-flex justify-content-between py-1 border-bottom', [
              span(classes: 'text-muted', [Component.text('PPN (11%):')]),
              span(classes: 'fw-semibold text-dark', [Component.text('Rp ${tax.toInt()}')]),
            ]),
            div(classes: 'd-flex justify-content-between py-2 fs-5 fw-bold text-primary', [
              span([Component.text('Grand Total:')]),
              span([Component.text('Rp ${order.total.toInt()}')]),
            ]),
          ]),
        ]),

        // 3. Panduan Pembayaran Virtual Account (VA Guide Section)
        hr(classes: 'my-4 border-secondary border-opacity-25'),
        div(classes: 'p-4 rounded-4 border bg-light-subtle', [
          div(classes: 'd-flex flex-wrap align-items-center justify-content-between gap-2 mb-3', [
            div(classes: 'd-flex align-items-center gap-2', [
              i(classes: 'bi bi-credit-card-2-back-fill fs-4 text-primary', []),
              div([
                h5(classes: 'fw-bold text-dark mb-0 fs-6', [Component.text('Panduan Pembayaran Virtual Account (VA)')]),
                small(classes: 'text-muted fs-8', [Component.text('Petunjuk transfer otomatis via ATM, Mobile Banking, dan Internet Banking.')]),
              ]),
            ]),
            if (order.status == 'Pending')
              button(
                type: ButtonType.button,
                classes: 'btn btn-success btn-sm rounded-pill px-3 fw-bold d-print-none shadow-sm',
                events: {
                  'click': (e) {
                    AppStore().confirmPaymentVirtualAccount(order.id);
                    setState(() {});
                  }
                },
                [
                  i(classes: 'bi bi-check2-circle me-1', []),
                  Component.text('⚡ Simulasi Bayar VA (Lunas Instan)'),
                ],
              )
            else
              span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill fs-7 px-3 py-1.5 fw-bold', [
                i(classes: 'bi bi-patch-check-fill me-1', []),
                Component.text('Pembayaran Terverifikasi Lunas'),
              ]),
          ]),

          // VA Details Card
          div(classes: 'card border-0 shadow-sm rounded-3 p-3 bg-white mb-3', [
            div(classes: 'row g-3 align-items-center', [
              div(classes: 'col-md-4 border-end-md', [
                small(classes: 'text-muted d-block fs-8 fw-semibold text-uppercase', [Component.text('Bank Tujuan Transfer:')]),
                span(classes: 'fw-bold fs-6 text-dark', [
                  Component.text(order.paymentMethod.contains('Virtual Account') ? order.paymentMethod : 'BCA Virtual Account'),
                ]),
              ]),
              div(classes: 'col-md-4 border-end-md', [
                small(classes: 'text-muted d-block fs-8 fw-semibold text-uppercase', [Component.text('Nomor Virtual Account:')]),
                span(classes: 'fw-extrabold fs-5 text-primary font-monospace', [
                  Component.text(order.vaNumber.isNotEmpty ? order.vaNumber : '80777${order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                ]),
              ]),
              div(classes: 'col-md-4', [
                small(classes: 'text-muted d-block fs-8 fw-semibold text-uppercase', [Component.text('Atas Nama Rekening:')]),
                span(classes: 'fw-bold fs-7 text-dark', [Component.text('ABELZ HANDMADE / E-COMES')]),
              ]),
            ]),
          ]),

          // Bank Guide Accordion
          div(classes: 'row g-3 fs-7', [
            div(classes: 'col-md-4', [
              div(classes: 'p-3 bg-white rounded-3 border h-100 shadow-xs', [
                h6(classes: 'fw-bold text-dark fs-7 mb-2 d-flex align-items-center gap-1', [
                  i(classes: 'bi bi-phone text-primary', []),
                  Component.text('1. Mobile Banking (m-BCA / Livin)'),
                ]),
                ol(classes: 'ps-3 mb-0 text-muted fs-8', [
                  li([Component.text('Buka aplikasi m-Banking di smartphone Anda.')]),
                  li([Component.text('Pilih menu Transfer > Virtual Account.')]),
                  li([Component.text('Masukkan nomor Virtual Account di atas.')]),
                  li([Component.text('Periksa kesesuaian nama & nominal lalu masukkan PIN.')]),
                ]),
              ]),
            ]),
            div(classes: 'col-md-4', [
              div(classes: 'p-3 bg-white rounded-3 border h-100 shadow-xs', [
                h6(classes: 'fw-bold text-dark fs-7 mb-2 d-flex align-items-center gap-1', [
                  i(classes: 'bi bi-hdd text-success', []),
                  Component.text('2. Mesin ATM Bank'),
                ]),
                ol(classes: 'ps-3 mb-0 text-muted fs-8', [
                  li([Component.text('Masukkan kartu ATM dan PIN 6-digit Anda.')]),
                  li([Component.text('Pilih menu Transaksi Lainnya > Transfer > Virtual Account.')]),
                  li([Component.text('Input nomor Virtual Account pesanan.')]),
                  li([Component.text('Konfirmasi transfer dan simpan struk pembayaran.')]),
                ]),
              ]),
            ]),
            div(classes: 'col-md-4', [
              div(classes: 'p-3 bg-white rounded-3 border h-100 shadow-xs', [
                h6(classes: 'fw-bold text-dark fs-7 mb-2 d-flex align-items-center gap-1', [
                  i(classes: 'bi bi-globe text-info', []),
                  Component.text('3. Internet Banking (KlikBCA / Mandiri)'),
                ]),
                ol(classes: 'ps-3 mb-0 text-muted fs-8', [
                  li([Component.text('Login ke akun Internet Banking resmi.')]),
                  li([Component.text('Pilih Pembayaran > Pembayaran Virtual Account.')]),
                  li([Component.text('Masukkan nomor VA & selesaikan dengan Token respon.')]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

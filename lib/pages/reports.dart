// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class ReportsPage extends StatefulComponent {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  void _exportReportCSV() {
    final csvRows = [
      'Bulan,Jumlah Pesanan,Omset Kotor (Rp),PPN 11% (Rp),Profit Bersih (Rp)',
      'Januari 2026,1420,1485000000,163350000,284000000',
      'Februari 2026,1280,1320000000,145200000,245000000',
      'Maret 2026,1560,1650000000,181500000,312000000',
      'April 2026,1390,1410000000,155100000,268000000',
      'Mei 2026,1680,1780000000,195800000,340000000',
      'Juni 2026,1750,1890000000,207900000,365000000',
      'Juli 2026,1620,1710000000,188100000,325000000',
      'Agustus 2026,1810,1950000000,214500000,380000000',
      'September 2026,890,920000000,101200000,175000000',
    ];
    final csvContent = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(csvRows.join('\n'))}';
    html.AnchorElement(href: csvContent)
      ..setAttribute('download', 'laporan_penjualan_ecomes_2026.csv')
      ..click();
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final totalSales = store.orders.fold<double>(0, (sum, item) => sum + item.total);
    final totalOrders = store.orders.length;

    // Compute Estimated Real HPP from orders items
    double totalHpp = 0;
    for (var order in store.orders) {
      for (var item in order.items) {
        final prodMatch = store.products.firstWhere(
          (prod) => prod.name.toLowerCase() == item.productName.toLowerCase(),
          orElse: () => ProductItem(id: '', name: '', sku: '', category: '', price: item.price, hpp: item.price * 0.52, stock: 0, image: '', status: ''),
        );
        totalHpp += (prodMatch.hpp * item.qty);
      }
    }

    final netProfit = totalSales - totalHpp;
    final marginPct = totalSales > 0 ? ((netProfit / totalSales) * 100) : 0.0;

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Laporan Keuangan & HPP Penjualan')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Kalkulasi real-time omset kotor, HPP (modal benang & pengerjaan), dan laba bersih (Net Profit).')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm fw-semibold rounded-3 px-3 shadow-sm',
                events: {'click': (e) => _exportReportCSV()},
                [
                  i(classes: 'bi bi-download me-1', []),
                  Component.text('Download Laporan CSV'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Financial Summary Cards
      div(classes: 'row g-3 mb-4', [
        _buildMetricCard(
          totalSales >= 1000000 ? 'Rp ${(totalSales / 1000000).toStringAsFixed(2)}M' : 'Rp ${totalSales.toInt()}',
          'Total Omset Kotor',
          'bi-currency-dollar',
          'text-bg-primary',
        ),
        _buildMetricCard(
          totalHpp >= 1000000 ? 'Rp ${(totalHpp / 1000000).toStringAsFixed(2)}M' : 'Rp ${totalHpp.toInt()}',
          'Total Modal HPP Benang',
          'bi-box-seam',
          'text-bg-warning text-dark',
        ),
        _buildMetricCard(
          netProfit >= 1000000 ? 'Rp ${(netProfit / 1000000).toStringAsFixed(2)}M' : 'Rp ${netProfit.toInt()}',
          'Laba Bersih (Net Profit)',
          'bi-graph-up-arrow',
          'text-bg-success',
        ),
        _buildMetricCard(
          '+${marginPct.toStringAsFixed(1)}%',
          'Rata-rata Margin Profit',
          'bi-pie-chart',
          'text-bg-info text-dark',
        ),
      ]),

      // 3. Monthly Breakdown Table Card
      div(classes: 'card shadow-sm border-0 rounded-3', [
        div(classes: 'card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between', [
          h5(classes: 'card-title fw-bold mb-0 text-dark', [
            i(classes: 'bi bi-calendar3 text-primary me-2', []),
            Component.text('Rekapitulasi Penjualan Per-Bulan Tahun 2026'),
          ]),
          span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill', [
            Component.text('Real HPP Calculated'),
          ]),
        ]),
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3 text-start text-nowrap', [Component.text('Periode Bulan')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Volume Pesanan')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Omset Kotor (Rp)')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Modal HPP (Rp)')]),
                  th(classes: 'text-end pe-3 text-nowrap', [Component.text('Profit Bersih')]),
                ]),
              ]),
              tbody([
                _buildReportRow('Januari 2026', '1,420', 'Rp 1.485.000.000', 'Rp 785.000.000', 'Rp 700.000.000'),
                _buildReportRow('Februari 2026', '1,280', 'Rp 1.320.000.000', 'Rp 695.000.000', 'Rp 625.000.000'),
                _buildReportRow('Maret 2026', '1,560', 'Rp 1.650.000.000', 'Rp 870.000.000', 'Rp 780.000.000'),
                _buildReportRow('April 2026', '1,390', 'Rp 1.410.000.000', 'Rp 740.000.000', 'Rp 670.000.000'),
                _buildReportRow('Mei 2026', '1,680', 'Rp 1.780.000.000', 'Rp 930.000.000', 'Rp 850.000.000'),
                _buildReportRow('Juni 2026', '1,750', 'Rp 1.890.000.000', 'Rp 990.000.000', 'Rp 900.000.000'),
                _buildReportRow('Juli 2026', '1,620', 'Rp 1.710.000.000', 'Rp 900.000.000', 'Rp 810.000.000'),
                _buildReportRow('Agustus 2026', '1,810', 'Rp 1.950.000.000', 'Rp 1.020.000.000', 'Rp 930.000.000'),
                _buildReportRow('September 2026 (Berjalan)', '$totalOrders', 'Rp ${totalSales.toInt()}', 'Rp ${totalHpp.toInt()}', 'Rp ${netProfit.toInt()}'),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildReportRow(String month, String orders, String omset, String ppn, String profit) {
    return tr([
      td(classes: 'ps-3 text-start fw-semibold fs-7 text-dark text-nowrap', [Component.text(month)]),
      td(classes: 'fs-7 text-muted text-center text-nowrap', [Component.text('$orders Transaksi')]),
      td(classes: 'fs-7 text-dark fw-bold text-start text-nowrap', [Component.text(omset)]),
      td(classes: 'fs-7 text-muted text-start text-nowrap', [Component.text(ppn)]),
      td(classes: 'text-end pe-3 fs-7 fw-bold text-success text-nowrap', [Component.text(profit)]),
    ]);
  }

  Component _buildMetricCard(String val, String label, String icon, String colorClass) {
    return div(classes: 'col-lg-3 col-6', [
      div(classes: 'small-box $colorClass shadow-sm rounded-3 p-3 position-relative overflow-hidden', [
        div(classes: 'inner', [
          h3(classes: 'fw-bold mb-1 fs-4', [Component.text(val)]),
          p(classes: 'mb-0 opacity-75 fs-7', [Component.text(label)]),
        ]),
        i(classes: 'bi $icon position-absolute bottom-0 end-0 fs-1 opacity-25 me-3 mb-2', []),
      ]),
    ]);
  }
}

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class PromosPage extends StatefulComponent {
  const PromosPage({super.key});

  @override
  State<PromosPage> createState() => _PromosPageState();
}

class _PromosPageState extends State<PromosPage> {
  bool showAddModal = false;

  String codeInput = '';
  String discountInput = 'Diskon 10%';
  double minPurchaseInput = 100000;
  double maxDiscountInput = 50000;
  int quotaInput = 100;
  String expiredInput = '31 Des 2026';

  void _openAddModal() {
    setState(() {
      codeInput = 'PROMO${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
      discountInput = 'Diskon 15% max Rp 50.000';
      minPurchaseInput = 150000;
      maxDiscountInput = 50000;
      quotaInput = 250;
      expiredInput = '31 Des 2026';
      showAddModal = true;
    });
  }

  void _savePromo() {
    if (codeInput.trim().isEmpty) return;
    final newP = PromoItem(
      id: 'PRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      code: codeInput.trim().toUpperCase(),
      discountText: discountInput.trim(),
      minPurchase: minPurchaseInput,
      maxDiscount: maxDiscountInput,
      quota: quotaInput,
      used: 0,
      expiredDate: expiredInput.trim(),
      isActive: true,
    );
    AppStore().addPromo(newP);
    setState(() {
      showAddModal = false;
    });
  }

  void _toggleStatus(String id) {
    AppStore().togglePromoStatus(id);
    setState(() {});
  }

  void _deletePromo(String id) {
    if (html.window.confirm('Apakah Anda yakin ingin menghapus kupon promo ini?')) {
      AppStore().deletePromo(id);
      setState(() {});
    }
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Kupon Diskon & Campaign Promosi')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Manajemen kode voucher, potongan harga, dan campaign Flash Sale.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm fw-semibold rounded-3 px-3',
                events: {'click': (e) => _openAddModal()},
                [
                  i(classes: 'bi bi-ticket-perforated me-1', []),
                  Component.text('Buat Voucher Promo'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Promos Table Card
      div(classes: 'card shadow-sm border-0 rounded-3', [
        div(classes: 'card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between', [
          h5(classes: 'card-title fw-bold mb-0 text-dark', [
            i(classes: 'bi bi-tags-fill text-primary me-2', []),
            Component.text('Voucher Aktif & Campaign'),
          ]),
          span(classes: 'badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill', [
            Component.text('${store.promos.length} Kupon Terdaftar'),
          ]),
        ]),
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3 text-start text-nowrap', [Component.text('Kode Kupon')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Potongan Diskon')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Min. Belanja')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Maks. Diskon')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Kuota Klaim')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Masa Berlaku')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Status')]),
                  th(classes: 'text-end pe-3 text-nowrap', [Component.text('Aksi')]),
                ]),
              ]),
              tbody([
                for (var p in store.promos)
                  tr([
                    td(classes: 'ps-3 text-start text-nowrap', [
                      span(classes: 'badge bg-primary-subtle text-primary border border-primary border-dashed fs-7 px-2 py-1 font-monospace', [
                        Component.text(p.code),
                      ]),
                    ]),
                    td(classes: 'fw-bold fs-7 text-dark text-start text-nowrap', [Component.text(p.discountText)]),
                    td(classes: 'fs-7 text-start text-nowrap', [Component.text('Rp ${p.minPurchase.toInt()}')]),
                    td(classes: 'fs-7 text-muted text-start text-nowrap', [Component.text('Rp ${p.maxDiscount.toInt()}')]),
                    td(classes: 'fs-7 text-center text-nowrap', [
                      div(classes: 'progress me-2 d-inline-block align-middle', styles: Styles(width: 80.px, height: 6.px), [
                        div(classes: 'progress-bar bg-primary', attributes: {'style': 'width: ${(p.used / p.quota * 100).toInt()}%'}, []),
                      ]),
                      small(classes: 'text-muted fs-8 d-block mt-1', [Component.text('${p.used}/${p.quota} Terpakai')]),
                    ]),
                    td(classes: 'fs-7 text-muted text-center text-nowrap', [Component.text(p.expiredDate)]),
                    td(classes: 'text-center text-nowrap', [
                      span(classes: 'badge ${p.isActive ? 'bg-success' : 'bg-secondary'} rounded-pill fs-8', [
                        Component.text(p.isActive ? 'Aktif' : 'Nonaktif'),
                      ]),
                    ]),
                    td(classes: 'text-end pe-3 text-nowrap', [
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm ${p.isActive ? 'btn-outline-warning text-dark' : 'btn-outline-success'} me-1',
                        events: {'click': (e) => _toggleStatus(p.id)},
                        [
                          i(classes: 'bi ${p.isActive ? 'bi-toggle-on' : 'bi-toggle-off'} me-1', []),
                          Component.text(p.isActive ? 'Matikan' : 'Aktifkan'),
                        ],
                      ),
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-danger',
                        events: {'click': (e) => _deletePromo(p.id)},
                        [i(classes: 'bi bi-trash', [])],
                      ),
                    ]),
                  ]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 3. Modal Add Promo
      if (showAddModal)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [Component.text('Buat Voucher Promo Baru')]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => showAddModal = false)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4', [
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Kode Voucher (Kapital)')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control font-monospace text-uppercase',
                    value: codeInput,
                    events: {
                      'input': (e) {
                        codeInput = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Keterangan Diskon')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: discountInput,
                    events: {
                      'input': (e) {
                        discountInput = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
                div(classes: 'row g-3 mb-3', [
                  div(classes: 'col-md-6', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Min. Belanja (Rp)')]),
                    input(
                      type: InputType.number,
                      classes: 'form-control',
                      value: minPurchaseInput.toInt().toString(),
                      events: {
                        'input': (e) {
                          minPurchaseInput = double.tryParse((e.target as html.InputElement).value ?? '') ?? 0;
                        }
                      },
                    ),
                  ]),
                  div(classes: 'col-md-6', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Maks. Diskon (Rp)')]),
                    input(
                      type: InputType.number,
                      classes: 'form-control',
                      value: maxDiscountInput.toInt().toString(),
                      events: {
                        'input': (e) {
                          maxDiscountInput = double.tryParse((e.target as html.InputElement).value ?? '') ?? 50000;
                        }
                      },
                    ),
                  ]),
                ]),
                div(classes: 'row g-3 mb-3', [
                  div(classes: 'col-md-6', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Kuota Klaim')]),
                    input(
                      type: InputType.number,
                      classes: 'form-control',
                      value: quotaInput.toString(),
                      events: {
                        'input': (e) {
                          quotaInput = int.tryParse((e.target as html.InputElement).value ?? '') ?? 100;
                        }
                      },
                    ),
                  ]),
                  div(classes: 'col-md-6', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Masa Berlaku Sampai')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control',
                      value: expiredInput,
                      events: {
                        'input': (e) {
                          expiredInput = (e.target as html.InputElement).value ?? '';
                        }
                      },
                    ),
                  ]),
                ]),
              ]),
              div(classes: 'modal-footer bg-light py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => showAddModal = false)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold',
                  events: {'click': (e) => _savePromo()},
                  [Component.text('Simpan Voucher')],
                ),
              ]),
            ]),
          ]),
        ]),
    ]);
  }
}

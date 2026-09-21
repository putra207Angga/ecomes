// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../services/app_store.dart';
import '../services/database_service.dart';

class SettingsPage extends StatefulComponent {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String storeName;
  late String phone;
  late String email;
  late String address;
  late String couriers;
  late String midtransKey;
  late String xenditKey;
  late double taxRate;

  String? toastMessage;

  @override
  void initState() {
    super.initState();
    final s = AppStore().settings;
    storeName = s.storeName;
    phone = s.phone;
    email = s.email;
    address = s.address;
    couriers = s.couriers;
    midtransKey = s.midtransKey;
    xenditKey = s.xenditKey;
    taxRate = s.taxRate;
  }

  void _saveSettings() {
    final store = AppStore();
    store.settings.storeName = storeName.trim();
    store.settings.phone = phone.trim();
    store.settings.email = email.trim();
    store.settings.address = address.trim();
    store.settings.couriers = couriers.trim();
    store.settings.midtransKey = midtransKey.trim();
    store.settings.xenditKey = xenditKey.trim();
    store.settings.taxRate = taxRate;
    store.saveAll();

    setState(() {
      toastMessage = 'Pengaturan toko berhasil diperbarui dan disimpan!';
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => toastMessage = null);
    });
  }

  void _exportDatabase() {
    DatabaseService().exportDatabaseBackupJson();
    setState(() {
      toastMessage = 'File backup database JSON berhasil di-download!';
    });
  }

  void _handleImportDatabase(dynamic event) async {
    final success = await DatabaseService().importDatabaseBackupJson(event);
    if (success) {
      final s = AppStore().settings;
      setState(() {
        storeName = s.storeName;
        phone = s.phone;
        email = s.email;
        address = s.address;
        couriers = s.couriers;
        midtransKey = s.midtransKey;
        xenditKey = s.xenditKey;
        taxRate = s.taxRate;
        toastMessage = 'Data database dari file backup JSON berhasil di-restore!';
      });
    }
  }

  void _resetDefaultData() {
    if (html.window.confirm('Reset semua data produk, pesanan, dan settings ke data default awal?')) {
      AppStore().resetToDefault();
      final s = AppStore().settings;
      setState(() {
        storeName = s.storeName;
        phone = s.phone;
        email = s.email;
        address = s.address;
        couriers = s.couriers;
        midtransKey = s.midtransKey;
        xenditKey = s.xenditKey;
        taxRate = s.taxRate;
        toastMessage = 'Seluruh data aplikasi berhasil direset ke data default!';
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Pengaturan Toko & Payment Gateway')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Konfigurasi identitas toko, alamat gudang, kurir pengiriman, dan tarif PPN.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-danger btn-sm rounded-3 me-2',
                events: {'click': (e) => _resetDefaultData()},
                [
                  i(classes: 'bi bi-arrow-counterclockwise me-1', []),
                  Component.text('Reset Data Default'),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm fw-semibold rounded-3 px-4 shadow-sm',
                events: {'click': (e) => _saveSettings()},
                [
                  i(classes: 'bi bi-check-circle me-1', []),
                  Component.text('Simpan Perubahan'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      if (toastMessage != null)
        div(classes: 'alert alert-success alert-dismissible fade show mb-4 rounded-3 shadow-sm', [
          i(classes: 'bi bi-check-circle-fill me-2', []),
          Component.text(toastMessage!),
        ]),

      // 2. Form Cards
      div(classes: 'row g-4', [
        // Left Column (Identitas & Kontak)
        div(classes: 'col-lg-7', [
          div(classes: 'card shadow-sm border-0 rounded-4 p-4 bg-white mb-4', [
            h5(classes: 'fw-bold text-dark mb-3 border-bottom pb-2', [
              i(classes: 'bi bi-shop text-primary me-2', []),
              Component.text('Profil & Alamat Operasional Toko'),
            ]),
            form([
              div(classes: 'mb-3', [
                label(classes: 'form-label fw-semibold fs-7', [Component.text('Nama Resmi Toko Online')]),
                input(
                  type: InputType.text,
                  classes: 'form-control',
                  value: storeName,
                  events: {
                    'input': (e) {
                      storeName = (e.target as html.InputElement).value ?? '';
                    }
                  },
                ),
              ]),
              div(classes: 'row g-3 mb-3', [
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Nomor WhatsApp Support')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: phone,
                    events: {
                      'input': (e) {
                        phone = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Email Resmi CS')]),
                  input(
                    type: InputType.email,
                    classes: 'form-control',
                    value: email,
                    events: {
                      'input': (e) {
                        email = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
              ]),
              div(classes: 'mb-3', [
                label(classes: 'form-label fw-semibold fs-7', [Component.text('Alamat Gudang / Tempat Pengiriman')]),
                textarea(
                  classes: 'form-control',
                  rows: 3,
                  events: {
                    'input': (e) {
                      address = (e.target as html.TextAreaElement).value ?? '';
                    }
                  },
                  [Component.text(address)],
                ),
              ]),
              div(classes: 'row g-3 mb-3', [
                div(classes: 'col-md-8', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Mitra Kurir Ekspedisi Dipilih')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: couriers,
                    events: {
                      'input': (e) {
                        couriers = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
                div(classes: 'col-md-4', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Tarif PPN Toko (%)')]),
                  input(
                    type: InputType.number,
                    classes: 'form-control',
                    value: taxRate.toString(),
                    events: {
                      'input': (e) {
                        taxRate = double.tryParse((e.target as html.InputElement).value ?? '') ?? 11.0;
                      }
                    },
                  ),
                ]),
              ]),
            ]),
          ]),
        ]),

        // Right Column (Payment Gateway Integrations)
        div(classes: 'col-lg-5', [
          div(classes: 'card shadow-sm border-0 rounded-4 p-4 bg-white mb-4', [
            h5(classes: 'fw-bold text-dark mb-3 border-bottom pb-2', [
              i(classes: 'bi bi-credit-card-2-front text-success me-2', []),
              Component.text('Konfigurasi Payment Gateway'),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-semibold fs-7', [Component.text('Midtrans Server Key (Production/Sandbox)')]),
              input(
                type: InputType.text,
                classes: 'form-control font-monospace fs-7',
                value: midtransKey,
                events: {
                  'input': (e) {
                    midtransKey = (e.target as html.InputElement).value ?? '';
                  }
                },
              ),
            ]),
            div(classes: 'mb-4', [
              label(classes: 'form-label fw-semibold fs-7', [Component.text('Xendit Secret API Key')]),
              input(
                type: InputType.text,
                classes: 'form-control font-monospace fs-7',
                value: xenditKey,
                events: {
                  'input': (e) {
                    xenditKey = (e.target as html.InputElement).value ?? '';
                  }
                },
              ),
            ]),
            div(classes: 'p-3 bg-light rounded-3 border fs-8 text-muted', [
              i(classes: 'bi bi-shield-lock-fill me-1 text-success', []),
              Component.text('API key Anda terenkripsi di penyimpanan lokal browser.'),
            ]),
          ]),

          // Status Database DB (Embedded SQLite Engine)
          div(classes: 'card shadow-sm border-0 rounded-4 p-4 bg-white mb-4', [
            h5(classes: 'fw-bold text-dark mb-3 border-bottom pb-2 d-flex align-items-center justify-content-between', [
              div(classes: 'd-flex align-items-center gap-2', [
                i(classes: 'bi bi-database-check text-success fs-5', []),
                Component.text('Status Engine Database DB'),
              ]),
              span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill fs-8', [
                Component.text('Active'),
              ]),
            ]),
            div(classes: 'p-3 bg-success-subtle rounded-3 border border-success-subtle mb-3', [
              div(classes: 'fw-bold text-success fs-7 mb-1', [
                i(classes: 'bi bi-check-circle-fill me-1', []),
                Component.text('Embedded Local DB Active (SQLite Engine)'),
              ]),
              p(classes: 'text-muted fs-8 mb-0', [
                Component.text('Aplikasi E-Comes menyimpan seluruh data produk, pesanan, testimoni, dan konfigurasi secara mandiri (Zero-Server Dependency). Bebas demo tanpa MySQL atau server DB eksternal.'),
              ]),
            ]),
            div(classes: 'row g-2 text-center fs-8 fw-bold mb-3', [
              div(classes: 'col-6', [
                div(classes: 'p-2 border rounded-2 bg-light', [
                  div(classes: 'text-primary fs-6', [Component.text(AppStore().products.length.toString())]),
                  span(classes: 'text-muted fw-normal', [Component.text('Produk Katalog')]),
                ]),
              ]),
              div(classes: 'col-6', [
                div(classes: 'p-2 border rounded-2 bg-light', [
                  div(classes: 'text-success fs-6', [Component.text(AppStore().orders.length.toString())]),
                  span(classes: 'text-muted fw-normal', [Component.text('Pesanan Toko')]),
                ]),
              ]),
            ]),
            div(classes: 'd-flex flex-column gap-2', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-primary btn-sm rounded-3 fw-semibold w-100 d-flex align-items-center justify-content-center gap-2',
                events: {'click': (e) => _exportDatabase()},
                [
                  i(classes: 'bi bi-download', []),
                  Component.text('Export Backup Database (JSON)'),
                ],
              ),
              label(classes: 'btn btn-outline-secondary btn-sm rounded-3 fw-semibold w-100 mb-0 d-flex align-items-center justify-content-center gap-2 cursor-pointer', [
                i(classes: 'bi bi-upload', []),
                Component.text('Restore DB Dari File JSON'),
                input(
                  type: InputType.file,
                  classes: 'd-none',
                  attributes: {'accept': '.json'},
                  events: {'change': (e) => _handleImportDatabase(e)},
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

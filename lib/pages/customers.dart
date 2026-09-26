// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class CustomersPage extends StatefulComponent {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String searchQuery = '';
  bool showAddModal = false;
  CustomerItem? activeCustomerDetail;

  String nameInput = '';
  String emailInput = '';
  String phoneInput = '';
  String levelInput = 'Regular';
  String addressInput = '';

  void _openAddModal() {
    setState(() {
      nameInput = '';
      emailInput = '';
      phoneInput = '08';
      levelInput = 'Regular';
      addressInput = 'Jl. Raya Pengiriman No. 12, Jakarta';
      showAddModal = true;
    });
  }

  void _saveCustomer() {
    if (nameInput.trim().isEmpty || emailInput.trim().isEmpty) return;
    final initials = nameInput.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final newC = CustomerItem(
      id: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      name: nameInput.trim(),
      email: emailInput.trim(),
      phone: phoneInput.trim(),
      level: levelInput,
      totalOrders: 1,
      totalSpent: 250000,
      avatar: initials.isEmpty ? 'CU' : initials,
      address: addressInput.trim(),
    );
    AppStore().addCustomer(newC);
    setState(() {
      showAddModal = false;
    });
  }

  void _toggleBlockCustomer(String id) {
    AppStore().toggleCustomerBlock(id);
    setState(() {});
  }

  void _exportCSV() {
    final store = AppStore();
    final csvRows = ['ID,Nama,Email,Telepon,Level,Total Pesanan,Total Belanja (Rp),Status Blokir'];
    for (var c in store.customers) {
      csvRows.add('"${c.id}","${c.name}","${c.email}","${c.phone}","${c.level}",${c.totalOrders},${c.totalSpent},"${c.isBlocked ? 'Dibloki' : 'Aktif'}"');
    }
    final csvContent = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(csvRows.join('\n'))}';
    html.AnchorElement(href: csvContent)
      ..setAttribute('download', 'pelanggan_ecomes_2026.csv')
      ..click();
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final allCustomers = store.customers;

    final filteredCustomers = allCustomers.where((c) {
      return c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.phone.contains(searchQuery);
    }).toList();

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis', [Component.text('Direktori Pelanggan & CRM Toko')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Manajemen database pembeli, status keanggotaan VIP, dan riwayat LTV.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-secondary btn-sm me-2 rounded-3',
                events: {'click': (e) => _exportCSV()},
                [
                  i(classes: 'bi bi-download me-1', []),
                  Component.text('Export CSV'),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm fw-semibold rounded-3 px-3',
                events: {'click': (e) => _openAddModal()},
                [
                  i(classes: 'bi bi-person-plus me-1', []),
                  Component.text('Tambah Pelanggan'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Customers Table
      div(classes: 'card shadow-sm border-0 rounded-3 bg-body', [
        div(classes: 'card-header bg-body py-3 border-bottom d-flex align-items-center justify-content-between gap-2', [
          div(classes: 'd-flex align-items-center gap-2', [
            i(classes: 'bi bi-people-fill text-primary fs-5', []),
            h5(classes: 'card-title fw-bold mb-0 text-body-emphasis', [Component.text('Daftar Pembeli Terdaftar')]),
          ]),
          div(classes: 'input-group input-group-sm ms-auto', styles: Styles(width: 250.px), [
            span(classes: 'input-group-text bg-body-tertiary border-end-0', [i(classes: 'bi bi-search', [])]),
            input(
              type: InputType.text,
              classes: 'form-control border-start-0',
              value: searchQuery,
              attributes: {'placeholder': 'Cari nama / email / No. WA...'},
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
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3 text-start text-nowrap', [Component.text('Pelanggan')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Kontak Email & WA')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Status Member')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Total Transaksi')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Akumulasi Belanja')]),
                  th(classes: 'text-end pe-3 text-nowrap', [Component.text('Aksi')]),
                ]),
              ]),
              tbody([
                if (filteredCustomers.isEmpty)
                  tr([
                    td(attributes: {'colspan': '6'}, classes: 'text-center py-5 text-muted', [
                      Component.text('Tidak ada pelanggan ditemukan.'),
                    ]),
                  ])
                else
                  for (var c in filteredCustomers)
                    tr([
                      td(classes: 'ps-3', [
                        div(classes: 'd-flex align-items-center gap-3', [
                          div(
                            classes: '${c.isBlocked ? 'bg-secondary' : 'bg-primary'} text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7 shadow-sm',
                            styles: Styles(width: 40.px, height: 40.px),
                            [Component.text(c.avatar)],
                          ),
                          div([
                            div(classes: 'fw-bold fs-7 text-body-emphasis', [
                              Component.text(c.name),
                              if (c.isBlocked)
                                span(classes: 'badge bg-danger ms-2 fs-8', [Component.text('Dibloki')]),
                            ]),
                            div(classes: 'text-muted fs-8', [Component.text('ID: ${c.id}')]),
                          ]),
                        ]),
                      ]),
                      td(classes: 'fs-7 text-start text-nowrap', [
                        div([
                          div(classes: 'text-body-emphasis', [Component.text(c.email)]),
                          small(classes: 'text-muted fs-8', [Component.text(c.phone)]),
                        ]),
                      ]),
                      td(classes: 'text-center text-nowrap', [
                        span(classes: 'badge ${c.level.contains('VIP') ? 'bg-warning text-dark' : 'bg-body-secondary text-body-emphasis border'} rounded-pill fs-8', [
                          if (c.level.contains('VIP')) i(classes: 'bi bi-star-fill me-1 text-dark', []),
                          Component.text(c.level),
                        ]),
                      ]),
                      td(classes: 'fs-7 fw-semibold text-body-emphasis text-center text-nowrap', [
                        Component.text('${c.totalOrders} Pesanan'),
                      ]),
                      td(classes: 'fw-bold text-primary fs-7 text-start text-nowrap', [
                        Component.text('Rp ${c.totalSpent.toInt()}'),
                      ]),
                      td(classes: 'text-end pe-3 text-nowrap', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm btn-outline-primary me-1',
                          events: {'click': (e) => setState(() => activeCustomerDetail = c)},
                          [
                            i(classes: 'bi bi-eye me-1', []),
                            Component.text('Detail'),
                          ],
                        ),
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm ${c.isBlocked ? 'btn-outline-success' : 'btn-outline-danger'}',
                          events: {'click': (e) => _toggleBlockCustomer(c.id)},
                          [
                            i(classes: 'bi ${c.isBlocked ? 'bi-unlock' : 'bi-lock'} me-1', []),
                            Component.text(c.isBlocked ? 'Buka Akses' : 'Blokir'),
                          ],
                        ),
                      ]),
                    ]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 3. Modal Customer Detail Profile
      if (activeCustomerDetail != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content bg-body text-body border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  i(classes: 'bi bi-person-lines-fill me-2', []),
                  Component.text('Detail Profil & Alamat Pelanggan'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeCustomerDetail = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4 text-body fs-7', [
                div(classes: 'd-flex align-items-center gap-3 border-bottom pb-3 mb-3', [
                  div(
                    classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-4 shadow-sm',
                    styles: Styles(width: 54.px, height: 54.px),
                    [Component.text(activeCustomerDetail!.avatar)],
                  ),
                  div([
                    h5(classes: 'fw-bold text-body-emphasis mb-1', [Component.text(activeCustomerDetail!.name)]),
                    span(classes: 'badge bg-warning text-dark me-2', [Component.text(activeCustomerDetail!.level)]),
                    small(classes: 'text-muted', [Component.text(activeCustomerDetail!.id)]),
                  ]),
                ]),
                div(classes: 'mb-2', [
                  strong(classes: 'text-muted d-block fs-8', [Component.text('ALAMAT EMAIL:')]),
                  Component.text(activeCustomerDetail!.email),
                ]),
                div(classes: 'mb-2', [
                  strong(classes: 'text-muted d-block fs-8', [Component.text('TELEPON / WHATSAPP:')]),
                  Component.text(activeCustomerDetail!.phone),
                ]),
                div(classes: 'mb-2', [
                  strong(classes: 'text-muted d-block fs-8', [Component.text('ALAMAT UTAMA PENGIRIMAN:')]),
                  Component.text(activeCustomerDetail!.address),
                ]),
                div(classes: 'p-3 bg-body-tertiary rounded-3 border mt-3 d-flex justify-content-between', [
                  div([
                    small(classes: 'text-muted d-block fs-8', [Component.text('Total Pesanan')]),
                    strong(classes: 'fs-6 text-body-emphasis', [Component.text('${activeCustomerDetail!.totalOrders} Order')]),
                  ]),
                  div(classes: 'text-end', [
                    small(classes: 'text-muted d-block fs-8', [Component.text('Lifetime Value (LTV)')]),
                    strong(classes: 'fs-6 text-primary', [Component.text('Rp ${activeCustomerDetail!.totalSpent.toInt()}')]),
                  ]),
                ]),
              ]),
              div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-4',
                  events: {'click': (e) => setState(() => activeCustomerDetail = null)},
                  [Component.text('Tutup')],
                ),
              ]),
            ]),
          ]),
        ]),

      // 4. Modal Add Customer
      if (showAddModal)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content bg-body text-body border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  i(classes: 'bi bi-person-plus me-2', []),
                  Component.text('Tambah Pelanggan Baru'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => showAddModal = false)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4 bg-body', [
                form([
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Nama Lengkap')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control',
                      value: nameInput,
                      events: {
                        'input': (e) {
                          nameInput = (e.target as html.InputElement).value ?? '';
                        }
                      },
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Alamat Email')]),
                    input(
                      type: InputType.email,
                      classes: 'form-control',
                      value: emailInput,
                      events: {
                        'input': (e) {
                          emailInput = (e.target as html.InputElement).value ?? '';
                        }
                      },
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Nomor WhatsApp')]),
                    input(
                      type: InputType.text,
                      classes: 'form-control',
                      value: phoneInput,
                      events: {
                        'input': (e) {
                          phoneInput = (e.target as html.InputElement).value ?? '';
                        }
                      },
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Alamat Lengkap Pengiriman')]),
                    textarea(
                      classes: 'form-control',
                      rows: 2,
                      events: {
                        'input': (e) {
                          addressInput = (e.target as html.TextAreaElement).value ?? '';
                        }
                      },
                      [Component.text(addressInput)],
                    ),
                  ]),
                  div(classes: 'mb-3', [
                    label(classes: 'form-label fw-semibold fs-7', [Component.text('Tingkat Keanggotaan')]),
                    select(
                      classes: 'form-select',
                      events: {
                        'change': (e) {
                          levelInput = (e.target as html.SelectElement).value ?? 'Regular';
                        }
                      },
                      [
                        option(value: 'Regular', selected: levelInput == 'Regular', [Component.text('Regular Member')]),
                        option(value: 'VIP Member', selected: levelInput == 'VIP Member', [Component.text('VIP Member')]),
                      ],
                    ),
                  ]),
                ]),
              ]),
              div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => showAddModal = false)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold',
                  events: {'click': (e) => _saveCustomer()},
                  [
                    i(classes: 'bi bi-check-circle me-1', []),
                    Component.text('Simpan Pelanggan'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
    ]);
  }
}

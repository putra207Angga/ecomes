// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class ProductsPage extends StatefulComponent {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String searchQuery = '';
  String statusFilter = 'Semua';
  bool showAddModal = false;
  ProductItem? editingProduct;

  List<String> selectedProductIds = [];

  // Form Fields
  String nameInput = '';
  String skuInput = '';
  String categoryInput = 'Boneka Amigurumi';
  double priceInput = 0;
  double hppInput = 0;
  int stockInput = 0;
  String imageInput = 'images/amigurumi_bear.png';
  String descriptionInput = '';

  void _openAddModal() {
    setState(() {
      editingProduct = null;
      nameInput = '';
      skuInput = 'RJT-AMG-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      categoryInput = 'Boneka Amigurumi';
      priceInput = 120000;
      hppInput = 65000;
      stockInput = 15;
      imageInput = 'images/amigurumi_bear.png';
      descriptionInput = '';
      showAddModal = true;
    });
  }

  void _openEditModal(ProductItem item) {
    setState(() {
      editingProduct = item;
      nameInput = item.name;
      skuInput = item.sku;
      categoryInput = item.category;
      priceInput = item.price;
      hppInput = item.hpp > 0 ? item.hpp : (item.price * 0.55);
      stockInput = item.stock;
      imageInput = item.image;
      descriptionInput = item.description;
      showAddModal = true;
    });
  }

  void _handleImageFileUpload(dynamic e) {
    final target = (e as dynamic).target;
    if (target is html.InputElement && target.files != null && target.files!.isNotEmpty) {
      final file = target.files![0];
      final reader = html.FileReader();
      reader.onLoadEnd.listen((event) {
        if (reader.result != null) {
          setState(() {
            imageInput = reader.result as String;
          });
        }
      });
      reader.readAsDataUrl(file);
    }
  }

  void _saveProduct() {
    if (nameInput.trim().isEmpty) return;
    final store = AppStore();
    final status = stockInput <= 0 ? 'Out of Stock' : stockInput < 5 ? 'Menipis' : 'Aktif';

    if (editingProduct == null) {
      final newP = ProductItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameInput.trim(),
        sku: skuInput.trim(),
        category: categoryInput,
        price: priceInput,
        hpp: hppInput > 0 ? hppInput : (priceInput * 0.55),
        stock: stockInput,
        image: imageInput.trim(),
        status: status,
        description: descriptionInput.trim(),
      );
      store.addProduct(newP);
    } else {
      editingProduct!.name = nameInput.trim();
      editingProduct!.sku = skuInput.trim();
      editingProduct!.category = categoryInput;
      editingProduct!.price = priceInput;
      editingProduct!.hpp = hppInput > 0 ? hppInput : (priceInput * 0.55);
      editingProduct!.stock = stockInput;
      editingProduct!.image = imageInput.trim();
      editingProduct!.status = status;
      editingProduct!.description = descriptionInput.trim();
      store.updateProduct(editingProduct!);
    }

    setState(() {
      showAddModal = false;
    });
  }

  void _deleteProduct(String id) {
    if (html.window.confirm('Apakah Anda yakin ingin menghapus produk ini dari katalog?')) {
      AppStore().deleteProduct(id);
      selectedProductIds.remove(id);
      setState(() {});
    }
  }

  void _handleBulkDelete() {
    if (selectedProductIds.isEmpty) return;
    if (html.window.confirm('Hapus ${selectedProductIds.length} produk terpilih secara massal?')) {
      AppStore().bulkDeleteProducts(selectedProductIds);
      selectedProductIds.clear();
      setState(() {});
    }
  }

  void _toggleSelectAll(List<ProductItem> items, bool isChecked) {
    setState(() {
      if (isChecked) {
        selectedProductIds = items.map((e) => e.id).toList();
      } else {
        selectedProductIds.clear();
      }
    });
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final allProducts = store.products;

    final totalCount = allProducts.length;
    final activeCount = allProducts.where((e) => e.status == 'Aktif').length;
    final lowCount = allProducts.where((e) => e.stock > 0 && e.stock < 5).length;
    final outCount = allProducts.where((e) => e.stock <= 0).length;

    final filteredProducts = allProducts.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase()) || item.sku.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = statusFilter == 'Semua' || item.status == statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    final isAllSelected = filteredProducts.isNotEmpty && filteredProducts.every((e) => selectedProductIds.contains(e.id));

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Kelola Produk & Stok Inventaris')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Manajemen katalog boneka amigurumi, produk rajutan handmade, penyesuaian stok, dan variasi harga.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              if (selectedProductIds.isNotEmpty)
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-outline-danger btn-sm rounded-3 me-2',
                  events: {'click': (e) => _handleBulkDelete()},
                  [
                    i(classes: 'bi bi-trash me-1', []),
                    Component.text('Hapus Terpilih (${selectedProductIds.length})'),
                  ],
                ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm shadow-sm rounded-3 px-3 fw-semibold',
                events: {'click': (e) => _openAddModal()},
                [
                  i(classes: 'bi bi-plus-lg me-1', []),
                  Component.text('Tambah Produk Baru'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Metrics
      div(classes: 'row g-3 mb-4', [
        _buildMetricCard('$totalCount Item', 'Total Katalog Produk', 'bi-box-seam', 'text-bg-primary'),
        _buildMetricCard('$activeCount Item', 'Produk Aktif / Published', 'bi-check-circle', 'text-bg-success'),
        _buildMetricCard('$lowCount Item', 'Stok Menipis (< 5)', 'bi-exclamation-triangle', 'text-bg-warning text-dark'),
        _buildMetricCard('$outCount Item', 'Stok Habis / Out of Stock', 'bi-x-circle', 'text-bg-danger'),
      ]),

      // 3. Table Card
      div(classes: 'card shadow-sm border-0 rounded-3', [
        div(classes: 'card-header bg-white py-3 border-bottom d-flex flex-wrap align-items-center justify-content-between gap-2', [
          div(classes: 'd-flex align-items-center gap-2', [
            i(classes: 'bi bi-grid-3x3-gap-fill text-primary fs-5', []),
            h5(classes: 'card-title fw-bold mb-0 text-dark', [Component.text('Daftar Produk Toko')]),
          ]),
          div(classes: 'd-flex flex-wrap align-items-center gap-2 ms-auto', [
            // Search Input
            div(classes: 'input-group input-group-sm', styles: Styles(width: 220.px), [
              span(classes: 'input-group-text bg-light border-end-0', [i(classes: 'bi bi-search', [])]),
              input(
                type: InputType.text,
                classes: 'form-control border-start-0',
                value: searchQuery,
                attributes: {'placeholder': 'Cari produk / SKU...'},
                events: {
                  'input': (e) {
                    setState(() {
                      searchQuery = (e.target as html.InputElement).value ?? '';
                    });
                  }
                },
              ),
            ]),
            // Filter Dropdown
            select(
              classes: 'form-select form-select-sm',
              styles: Styles(width: 150.px),
              events: {
                'change': (e) {
                  setState(() {
                    statusFilter = (e.target as html.SelectElement).value ?? '';
                  });
                }
              },
              [
                option(value: 'Semua', selected: statusFilter == 'Semua', [Component.text('Semua Status')]),
                option(value: 'Aktif', selected: statusFilter == 'Aktif', [Component.text('Status Aktif')]),
                option(value: 'Menipis', selected: statusFilter == 'Menipis', [Component.text('Stok Menipis')]),
                option(value: 'Out of Stock', selected: statusFilter == 'Out of Stock', [Component.text('Out of Stock')]),
              ],
            ),
          ]),
        ]),
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3 text-center', styles: Styles(width: 40.px), [
                    input(
                      type: InputType.checkbox,
                      classes: 'form-check-input',
                      attributes: isAllSelected ? {'checked': 'checked'} : {},
                      events: {
                        'change': (e) {
                          final isChecked = (e.target as html.InputElement).checked ?? false;
                          _toggleSelectAll(filteredProducts, isChecked);
                        }
                      },
                    ),
                  ]),
                  th(classes: 'text-start text-nowrap', [Component.text('Produk & SKU')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Kategori')]),
                  th(classes: 'text-start text-nowrap', [Component.text('Harga & HPP')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Margin Profit')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Stok')]),
                  th(classes: 'text-center text-nowrap', [Component.text('Status')]),
                  th(classes: 'text-end pe-3 text-nowrap', [Component.text('Aksi')]),
                ]),
              ]),
              tbody([
                if (filteredProducts.isEmpty)
                  tr([
                    td(attributes: {'colspan': '8'}, classes: 'text-center py-5 text-muted', [
                      i(classes: 'bi bi-inbox fs-1 d-block mb-2 text-secondary', []),
                      Component.text('Tidak ada produk yang cocok dengan pencarian.'),
                    ]),
                  ])
                else
                  for (var item in filteredProducts) ...[
                    tr([
                      td(classes: 'ps-3', [
                        input(
                          type: InputType.checkbox,
                          classes: 'form-check-input',
                          attributes: selectedProductIds.contains(item.id) ? {'checked': 'checked'} : {},
                          events: {
                            'change': (e) {
                              final isChecked = (e.target as html.InputElement).checked ?? false;
                              setState(() {
                                if (isChecked) {
                                  selectedProductIds.add(item.id);
                                } else {
                                  selectedProductIds.remove(item.id);
                                }
                              });
                            }
                          },
                        ),
                      ]),
                      td([
                        div(classes: 'd-flex align-items-center gap-3', [
                          img(src: item.image, classes: 'rounded-3 border object-fit-cover', attributes: {'width': '48', 'height': '48', 'alt': item.name}),
                          div([
                            div(classes: 'fw-bold fs-7 text-dark', [Component.text(item.name)]),
                            div(classes: 'text-muted fs-8', [Component.text('SKU: ${item.sku}')]),
                          ]),
                        ]),
                      ]),
                      td(classes: 'fs-7 text-start text-nowrap', [Component.text(item.category)]),
                      td(classes: 'fs-7 text-start text-nowrap', [
                        div(classes: 'fw-bold text-primary', [Component.text('Rp ${item.price.toInt()}')]),
                        div(classes: 'text-muted fs-8', [Component.text('HPP: Rp ${item.hpp.toInt()}')]),
                      ]),
                      td(classes: 'fs-7 text-center text-nowrap', [
                        span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill fs-8 fw-bold', [
                          Component.text('+${item.price > 0 ? (((item.price - item.hpp) / item.price) * 100).toStringAsFixed(0) : '0'}% (Rp ${(item.price - item.hpp).toInt()})'),
                        ]),
                      ]),
                      td(classes: 'fs-7 text-center text-nowrap', [
                        span(classes: 'fw-bold ${item.stock < 5 ? 'text-danger' : 'text-dark'}', [
                          Component.text('${item.stock} unit'),
                        ]),
                      ]),
                      td(classes: 'text-center text-nowrap', [
                        span(classes: 'badge ${item.status == 'Aktif' ? 'bg-success' : item.status == 'Menipis' ? 'bg-warning text-dark' : 'bg-danger'} rounded-pill fs-8', [
                          Component.text(item.status),
                        ]),
                      ]),
                      td(classes: 'text-end pe-3', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm btn-outline-primary me-1',
                          events: {'click': (e) => _openEditModal(item)},
                          [i(classes: 'bi bi-pencil-square', [])],
                        ),
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm btn-outline-danger',
                          events: {'click': (e) => _deleteProduct(item.id)},
                          [i(classes: 'bi bi-trash', [])],
                        ),
                      ]),
                    ]),
                  ],
              ]),
            ]),
          ]),
        ]),
      ]),

      // 4. Modal Add/Edit Product with Image File Picker
      if (showAddModal)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered modal-lg', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  i(classes: 'bi bi-box-seam me-2', []),
                  Component.text(editingProduct == null ? 'Tambah Produk Baru' : 'Edit Data Produk'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => showAddModal = false)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4', [
                form([
                  div(classes: 'row g-3', [
                    div(classes: 'col-md-8', [
                      label(classes: 'form-label fw-semibold fs-7', [Component.text('Nama Produk')]),
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
                    div(classes: 'col-md-4', [
                      label(classes: 'form-label fw-semibold fs-7', [Component.text('Kode SKU')]),
                      input(
                        type: InputType.text,
                        classes: 'form-control',
                        value: skuInput,
                        events: {
                          'input': (e) {
                            skuInput = (e.target as html.InputElement).value ?? '';
                          }
                        },
                      ),
                    ]),
                    div(classes: 'col-md-5', [
                      label(classes: 'form-label fw-semibold fs-7', [Component.text('Kategori Barang')]),
                      select(
                        classes: 'form-select',
                        events: {
                          'change': (e) {
                            categoryInput = (e.target as html.SelectElement).value ?? '';
                          }
                        },
                        [
                          for (var c in store.categories)
                            option(value: c.name, selected: categoryInput == c.name, [Component.text(c.name)]),
                        ],
                      ),
                    ]),
                    div(classes: 'col-md-3', [
                      label(classes: 'form-label fw-semibold fs-7', [Component.text('Harga Jual (Rp)')]),
                      input(
                        type: InputType.number,
                        classes: 'form-control',
                        value: priceInput.toInt().toString(),
                        events: {
                          'input': (e) {
                            priceInput = double.tryParse((e.target as html.InputElement).value ?? '') ?? 0;
                          }
                        },
                      ),
                    ]),
                    div(classes: 'col-md-2', [
                      label(classes: 'form-label fw-semibold fs-7 text-danger', [Component.text('Modal HPP (Rp)')]),
                      input(
                        type: InputType.number,
                        classes: 'form-control border-danger-subtle',
                        value: hppInput.toInt().toString(),
                        events: {
                          'input': (e) {
                            hppInput = double.tryParse((e.target as html.InputElement).value ?? '') ?? 0;
                          }
                        },
                      ),
                    ]),
                    div(classes: 'col-md-2', [
                      label(classes: 'form-label fw-semibold fs-7', [Component.text('Stok Awal')]),
                      input(
                        type: InputType.number,
                        classes: 'form-control',
                        value: stockInput.toString(),
                        events: {
                          'input': (e) {
                            stockInput = int.tryParse((e.target as html.InputElement).value ?? '') ?? 0;
                          }
                        },
                      ),
                    ]),
                    // Image File Upload & URL Picker
                    div(classes: 'col-12', [
                      label(classes: 'form-label fw-semibold fs-7 d-block', [Component.text('Gambar Produk (Upload File / URL)')]),
                      div(classes: 'd-flex align-items-center gap-3', [
                        img(src: imageInput, classes: 'rounded-3 border object-fit-cover shadow-sm', attributes: {'width': '70', 'height': '70', 'alt': 'Preview'}),
                        div(classes: 'flex-grow-1', [
                          input(
                            type: InputType.file,
                            classes: 'form-control form-control-sm mb-2',
                            attributes: {'accept': 'image/*'},
                            events: {'change': (e) => _handleImageFileUpload(e)},
                          ),
                          input(
                            type: InputType.text,
                            classes: 'form-control form-control-sm',
                            value: imageInput,
                            attributes: {'placeholder': 'Atau tempel URL gambar...'},
                            events: {
                              'input': (e) {
                                setState(() {
                                  imageInput = (e.target as html.InputElement).value ?? '';
                                });
                              }
                            },
                          ),
                        ]),
                      ]),
                    ]),
                    div(classes: 'col-12', [
                      label(classes: 'form-label fw-semibold fs-7', [Component.text('Deskripsi Singkat')]),
                      textarea(
                        classes: 'form-control',
                        rows: 3,
                        events: {
                          'input': (e) {
                            descriptionInput = (e.target as html.TextAreaElement).value ?? '';
                          }
                        },
                        [Component.text(descriptionInput)],
                      ),
                    ]),
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
                  events: {'click': (e) => _saveProduct()},
                  [
                    i(classes: 'bi bi-check-circle me-1', []),
                    Component.text('Simpan Produk'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
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

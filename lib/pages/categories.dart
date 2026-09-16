// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class CategoriesPage extends StatefulComponent {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool showCatModal = false;
  bool showBrandModal = false;

  CategoryItem? editingCat;
  BrandItem? editingBrand;

  String catName = '';
  String catIcon = 'bi-box-seam';

  String brandName = '';
  String brandCountry = 'Indonesia';

  void _openCatModal([CategoryItem? cat]) {
    setState(() {
      editingCat = cat;
      catName = cat?.name ?? '';
      catIcon = cat?.icon ?? 'bi-box-seam';
      showCatModal = true;
    });
  }

  void _openBrandModal([BrandItem? b]) {
    setState(() {
      editingBrand = b;
      brandName = b?.name ?? '';
      brandCountry = b?.country ?? 'Indonesia';
      showBrandModal = true;
    });
  }

  void _saveCategory() {
    if (catName.trim().isEmpty) return;
    final store = AppStore();
    if (editingCat == null) {
      final newCat = CategoryItem(
        id: 'CAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: catName.trim(),
        icon: catIcon,
        productCount: 0,
      );
      store.addCategory(newCat);
    } else {
      editingCat!.name = catName.trim();
      editingCat!.icon = catIcon;
      store.updateCategory(editingCat!);
    }
    setState(() {
      showCatModal = false;
    });
  }

  void _saveBrand() {
    if (brandName.trim().isEmpty) return;
    final store = AppStore();
    if (editingBrand == null) {
      final newBrand = BrandItem(
        id: 'BRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: brandName.trim(),
        logo: 'bi-patch-check',
        country: brandCountry.trim(),
        productCount: 0,
      );
      store.addBrand(newBrand);
    } else {
      editingBrand!.name = brandName.trim();
      editingBrand!.country = brandCountry.trim();
      store.updateBrand(editingBrand!);
    }
    setState(() {
      showBrandModal = false;
    });
  }

  void _deleteCat(String id) {
    if (html.window.confirm('Hapus kategori ini?')) {
      AppStore().deleteCategory(id);
      setState(() {});
    }
  }

  void _deleteBrand(String id) {
    if (html.window.confirm('Hapus brand ini?')) {
      AppStore().deleteBrand(id);
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
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Taksonomi Kategori & Brand Mitra')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Struktur pengelompokan produk dan lisensi brand resmi.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-primary btn-sm me-2 rounded-3',
                events: {'click': (e) => _openBrandModal()},
                [
                  i(classes: 'bi bi-plus-lg me-1', []),
                  Component.text('Tambah Brand'),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary btn-sm fw-semibold rounded-3 px-3',
                events: {'click': (e) => _openCatModal()},
                [
                  i(classes: 'bi bi-plus-lg me-1', []),
                  Component.text('Tambah Kategori'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Categories Grid Cards
      div(classes: 'mb-4', [
        h5(classes: 'fw-bold text-dark mb-3', [
          i(classes: 'bi bi-grid-3x3-gap-fill text-primary me-2', []),
          Component.text('Kategori Utama Produk'),
        ]),
        div(classes: 'row g-3', [
          for (var cat in store.categories)
            div(classes: 'col-lg-4 col-md-6', [
              div(classes: 'card shadow-sm border-0 rounded-3 p-3 position-relative', [
                div(classes: 'd-flex align-items-center justify-content-between', [
                  div(classes: 'd-flex align-items-center gap-3', [
                    div(
                      classes: 'bg-primary-subtle text-primary rounded-3 d-flex align-items-center justify-content-center fs-3',
                      styles: Styles(width: 50.px, height: 50.px),
                      [i(classes: 'bi ${cat.icon}', [])],
                    ),
                    div([
                      h6(classes: 'fw-bold text-dark mb-1', [Component.text(cat.name)]),
                      span(classes: 'badge bg-light text-dark border rounded-pill fs-8', [
                        Component.text('${cat.productCount} Produk'),
                      ]),
                    ]),
                  ]),
                  div(classes: 'btn-group btn-group-sm', [
                    button(
                      type: ButtonType.button,
                      classes: 'btn btn-outline-primary border-0 me-1',
                      events: {'click': (e) => _openCatModal(cat)},
                      [i(classes: 'bi bi-pencil-square', [])],
                    ),
                    button(
                      type: ButtonType.button,
                      classes: 'btn btn-outline-danger border-0',
                      events: {'click': (e) => _deleteCat(cat.id)},
                      [i(classes: 'bi bi-trash', [])],
                    ),
                  ]),
                ]),
              ]),
            ]),
        ]),
      ]),

      // 3. Brands Table Card
      div(classes: 'card shadow-sm border-0 rounded-3', [
        div(classes: 'card-header bg-white py-3 border-bottom', [
          h5(classes: 'card-title fw-bold mb-0 text-dark', [
            i(classes: 'bi bi-award-fill text-warning me-2', []),
            Component.text('Daftar Brand Mitra Resmi'),
          ]),
        ]),
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3', [Component.text('Nama Brand')]),
                  th([Component.text('Negara Asal')]),
                  th([Component.text('Jumlah Katalog')]),
                  th(classes: 'text-end pe-3', [Component.text('Aksi')]),
                ]),
              ]),
              tbody([
                for (var b in store.brands)
                  tr([
                    td(classes: 'ps-3', [
                      div(classes: 'd-flex align-items-center gap-2', [
                        i(classes: 'bi ${b.logo} text-primary fs-5', []),
                        span(classes: 'fw-bold fs-7 text-dark', [Component.text(b.name)]),
                      ]),
                    ]),
                    td(classes: 'fs-7', [Component.text(b.country)]),
                    td(classes: 'fs-7 fw-semibold', [Component.text('${b.productCount} Item')]),
                    td(classes: 'text-end pe-3', [
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-primary me-1',
                        events: {'click': (e) => _openBrandModal(b)},
                        [i(classes: 'bi bi-pencil-square', [])],
                      ),
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-danger',
                        events: {'click': (e) => _deleteBrand(b.id)},
                        [i(classes: 'bi bi-trash', [])],
                      ),
                    ]),
                  ]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 4. Modal Add/Edit Category
      if (showCatModal)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  Component.text(editingCat == null ? 'Tambah Kategori Baru' : 'Edit Kategori'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => showCatModal = false)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4', [
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Nama Kategori')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: catName,
                    events: {
                      'input': (e) {
                        catName = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Ikon Bootstrap')]),
                  select(
                    classes: 'form-select',
                    events: {
                      'change': (e) {
                        catIcon = (e.target as html.SelectElement).value ?? 'bi-box-seam';
                      }
                    },
                    [
                      option(value: 'bi-bag-heart', selected: catIcon == 'bi-bag-heart', [Component.text('bi-bag-heart (Fashion)')]),
                      option(value: 'bi-laptop', selected: catIcon == 'bi-laptop', [Component.text('bi-laptop (Elektronik)')]),
                      option(value: 'bi-house-door', selected: catIcon == 'bi-house-door', [Component.text('bi-house-door (Perlengkapan Rumah)')]),
                      option(value: 'bi-stars', selected: catIcon == 'bi-stars', [Component.text('bi-stars (Kecantikan)')]),
                      option(value: 'bi-activity', selected: catIcon == 'bi-activity', [Component.text('bi-activity (Kesehatan)')]),
                    ],
                  ),
                ]),
              ]),
              div(classes: 'modal-footer bg-light py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => showCatModal = false)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold',
                  events: {'click': (e) => _saveCategory()},
                  [Component.text('Simpan Kategori')],
                ),
              ]),
            ]),
          ]),
        ]),

      // 5. Modal Add/Edit Brand
      if (showBrandModal)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  Component.text(editingBrand == null ? 'Tambah Brand Baru' : 'Edit Brand Mitra'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => showBrandModal = false)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4', [
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Nama Brand / Merek')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: brandName,
                    events: {
                      'input': (e) {
                        brandName = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Negara Asal Brand')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control',
                    value: brandCountry,
                    events: {
                      'input': (e) {
                        brandCountry = (e.target as html.InputElement).value ?? '';
                      }
                    },
                  ),
                ]),
              ]),
              div(classes: 'modal-footer bg-light py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => showBrandModal = false)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold',
                  events: {'click': (e) => _saveBrand()},
                  [Component.text('Simpan Brand')],
                ),
              ]),
            ]),
          ]),
        ]),
    ]);
  }
}

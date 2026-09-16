// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../services/app_store.dart';

class LandingCmsPage extends StatefulComponent {
  const LandingCmsPage({super.key});

  @override
  State<LandingCmsPage> createState() => _LandingCmsPageState();
}

class _LandingCmsPageState extends State<LandingCmsPage> {
  bool showSuccessToast = false;
  String toastMessage = '';

  // Form Fields for Hero Banner & Brand
  late String storeNameInput;
  late String storeTaglineInput;
  late String heroHeadlinePrefixInput;
  late String heroHeadlineHighlightInput;
  late String heroDescriptionInput;
  late String heroBadgeInput;
  late String heroImageInput;
  late String whatsappNumberInput;
  late String instagramHandleInput;

  // Preset Header Images
  final List<Map<String, String>> imagePresets = [
    {
      'title': '🔥 Special Promo Flash Sale',
      'subtitle': 'Koleksi Boneka Rajut Utama',
      'path': 'images/hero_crochet_dolls.png',
      'badge': 'PROMO FLASHSALE ⚡',
    },
    {
      'title': '🏆 Best Seller Amigurumi Bear',
      'subtitle': 'Boneka Rajut Paling Laris',
      'path': 'images/amigurumi_bear.png',
      'badge': 'BEST SELLER #1 🧸',
    },
    {
      'title': '🧶 Winter Scarf & Beanie Collection',
      'subtitle': 'Syal & Kupluk Soft Acrylic',
      'path': 'images/crochet_scarf_beanie.png',
      'badge': 'NEW ARRIVAL ✨',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFromStore();
  }

  void _loadFromStore() {
    final cfg = AppStore().landingConfig;
    storeNameInput = cfg.storeName;
    storeTaglineInput = cfg.storeTagline;
    heroHeadlinePrefixInput = cfg.heroHeadlinePrefix;
    heroHeadlineHighlightInput = cfg.heroHeadlineHighlight;
    heroDescriptionInput = cfg.heroDescription;
    heroBadgeInput = cfg.heroBadge;
    heroImageInput = cfg.heroImage;
    whatsappNumberInput = cfg.whatsappNumber;
    instagramHandleInput = cfg.instagramHandle;
  }

  void _showNotification(String msg) {
    setState(() {
      toastMessage = msg;
      showSuccessToast = true;
    });
  }

  void _saveHeroSettings() {
    final store = AppStore();
    final cfg = store.landingConfig;
    cfg.storeName = storeNameInput.trim();
    cfg.storeTagline = storeTaglineInput.trim();
    cfg.heroHeadlinePrefix = heroHeadlinePrefixInput.trim();
    cfg.heroHeadlineHighlight = heroHeadlineHighlightInput.trim();
    cfg.heroDescription = heroDescriptionInput.trim();
    cfg.heroBadge = heroBadgeInput.trim();
    cfg.heroImage = heroImageInput.trim();
    cfg.whatsappNumber = whatsappNumberInput.trim();
    cfg.instagramHandle = instagramHandleInput.trim();

    store.updateLandingConfig(cfg);
    _showNotification('Pengaturan Hero Banner & Header Image berhasil disimpan!');
  }

  void _selectPresetImage(Map<String, String> preset) {
    setState(() {
      heroImageInput = preset['path']!;
      if (preset.containsKey('badge') && preset['badge']!.isNotEmpty) {
        heroBadgeInput = preset['badge']!;
      }
    });
    _showNotification('Gambar header diganti ke: ${preset['title']}');
  }

  void _resetToDefaultData() {
    AppStore().resetToDefault();
    _loadFromStore();
    _showNotification('Konfigurasi banner & brand berhasil di-reset ke default toko rajutan!');
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-md-7', [
              h3(classes: 'mb-0 fw-bold text-dark d-flex align-items-center gap-2', [
                i(classes: 'bi bi-window-stack text-danger', []),
                Component.text('Manajemen Landing Page Toko Rajutan'),
              ]),
              p(classes: 'text-muted mb-0 fs-7', [
                Component.text('Khusus mengelola Hero Banner utama, input gambar promo/best seller header landing page, serta identitas brand toko.'),
              ]),
            ]),
            div(classes: 'col-md-5 text-md-end mt-3 mt-md-0 d-flex gap-2 justify-content-md-end', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-secondary rounded-pill px-3 py-2 fs-7 fw-semibold shadow-sm',
                events: {'click': (e) => _resetToDefaultData()},
                [
                  i(classes: 'bi bi-arrow-counterclockwise me-1', []),
                  Component.text('Reset Default'),
                ],
              ),
              a(
                classes: 'btn btn-danger rounded-pill px-4 py-2 fs-7 fw-bold shadow-sm d-flex align-items-center gap-2',
                href: '/landing',
                attributes: {'target': '_blank'},
                [
                  i(classes: 'bi bi-box-arrow-up-right', []),
                  Component.text('Pratinjau Toko Live'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Notification Toast Alert
      if (showSuccessToast)
        div(classes: 'alert alert-success alert-dismissible fade show rounded-3 shadow-sm d-flex align-items-center gap-2 mb-4', attributes: {'role': 'alert'}, [
          i(classes: 'bi bi-check-circle-fill fs-5 text-success', []),
          div(classes: 'flex-grow-1 fs-7 fw-semibold', [Component.text(toastMessage)]),
          button(
            type: ButtonType.button,
            classes: 'btn-close py-2',
            events: {'click': (e) => setState(() => showSuccessToast = false)},
            [],
          ),
        ]),

      // 3. Main Grid (Form Editor + Live Preview)
      div(classes: 'row g-4', [
        // Left Column: Form Settings & Image Picker
        div(classes: 'col-lg-7', [
          div(classes: 'card border-0 shadow-sm rounded-4 mb-4 overflow-hidden', [
            div(classes: 'card-header bg-white border-bottom p-3 d-flex align-items-center justify-content-between', [
              h5(classes: 'fw-bold text-dark mb-0 d-flex align-items-center gap-2 fs-6', [
                i(classes: 'bi bi-image text-danger', []),
                Component.text('1. Pilih Gambar Header Landing Page (Promo / Best Seller)'),
              ]),
              span(classes: 'badge bg-danger-subtle text-danger rounded-pill px-2 py-1 fs-8 fw-semibold', [
                Component.text('Header Image Input'),
              ]),
            ]),
            div(classes: 'card-body p-4 bg-white', [
              p(classes: 'text-muted fs-7 mb-3', [
                Component.text('Pilih opsi cepat preset gambar header untuk promo/best seller produk rajutan mendatang, atau masukkan URL/Path gambar kustom Anda:'),
              ]),

              // Image Presets Grid
              div(classes: 'row g-3 mb-4', [
                for (var preset in imagePresets)
                  div(classes: 'col-md-4', [
                    div(
                      classes: 'card h-100 border rounded-3 p-2 cursor-pointer shadow-sm transition-all ${heroImageInput == preset['path'] ? 'border-danger border-2 bg-danger-subtle bg-opacity-10' : 'bg-light'}',
                      events: {'click': (e) => _selectPresetImage(preset)},
                      [
                        div(classes: 'position-relative rounded-2 overflow-hidden mb-2 bg-white border', styles: Styles(height: 110.px), [
                          img(
                            src: preset['path']!,
                            classes: 'w-100 h-100 object-fit-cover',
                            attributes: {'alt': preset['title']!},
                          ),
                          if (heroImageInput == preset['path'])
                            div(classes: 'position-absolute top-0 end-0 m-1 badge bg-danger text-white rounded-circle p-1', [
                              i(classes: 'bi bi-check-lg', []),
                            ]),
                        ]),
                        div(classes: 'fw-bold text-dark fs-8 line-clamp-1', [Component.text(preset['title']!)]),
                        small(classes: 'text-muted fs-8 d-block', [Component.text(preset['subtitle']!)]),
                      ],
                    ),
                  ]),
              ]),

              // Custom Image Input
              div(classes: 'mb-2', [
                label(classes: 'form-label fw-bold fs-7 text-dark', [
                  i(classes: 'bi bi-link-45deg me-1 text-danger', []),
                  Component.text('Atau Input Direct URL / Path Gambar Header:'),
                ]),
                div(classes: 'input-group', [
                  span(classes: 'input-group-text bg-light fs-7 text-muted', [Component.text('URL / Path')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-end-3 fs-7',
                    value: heroImageInput,
                    events: {
                      'input': (e) {
                        setState(() {
                          heroImageInput = (e.target as html.InputElement).value ?? '';
                        });
                      }
                    },
                  ),
                ]),
                small(classes: 'text-muted fs-8 mt-1 d-block', [
                  Component.text('Gunakan format relatif lokal seperti `images/hero_crochet_dolls.png` atau URL HTTP lengkap.'),
                ]),
              ]),
            ]),
          ]),

          // Card 2: Text Content & Brand Settings
          div(classes: 'card border-0 shadow-sm rounded-4 mb-4 overflow-hidden', [
            div(classes: 'card-header bg-white border-bottom p-3 d-flex align-items-center justify-content-between', [
              h5(classes: 'fw-bold text-dark mb-0 d-flex align-items-center gap-2 fs-6', [
                i(classes: 'bi bi-sliders text-danger', []),
                Component.text('2. Konten Teks Hero Banner & Identitas Brand'),
              ]),
            ]),
            div(classes: 'card-body p-4 bg-white', [
              div(classes: 'row g-3', [
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Nama Toko Rajutan')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: storeNameInput,
                    events: {'input': (e) => setState(() => storeNameInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Tagline Toko')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: storeTaglineInput,
                    events: {'input': (e) => setState(() => storeTaglineInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-12', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Badge Top Tagline Banner (Highlight Info)')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: heroBadgeInput,
                    events: {'input': (e) => setState(() => heroBadgeInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Awalan Judul Headline (Normal)')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: heroHeadlinePrefixInput,
                    events: {'input': (e) => setState(() => heroHeadlinePrefixInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Sorotan Judul (Gradient Merah)')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: heroHeadlineHighlightInput,
                    events: {'input': (e) => setState(() => heroHeadlineHighlightInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-12', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Deskripsi Lengkap Banner Hero')]),
                  textarea(
                    classes: 'form-control rounded-3 fs-7',
                    rows: 3,
                    events: {'input': (e) => setState(() => heroDescriptionInput = (e.target as html.TextAreaElement).value ?? '')},
                    [Component.text(heroDescriptionInput)],
                  ),
                ]),
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Nomor WhatsApp Toko (Pemesanan Direct)')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: whatsappNumberInput,
                    events: {'input': (e) => setState(() => whatsappNumberInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-6', [
                  label(classes: 'form-label fw-bold fs-7', [Component.text('Handle Instagram Toko')]),
                  input(
                    type: InputType.text,
                    classes: 'form-control rounded-3 fs-7',
                    value: instagramHandleInput,
                    events: {'input': (e) => setState(() => instagramHandleInput = (e.target as html.InputElement).value ?? '')},
                  ),
                ]),
                div(classes: 'col-md-12 text-end mt-4', [
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-danger px-4 py-2 rounded-pill fw-bold shadow d-inline-flex align-items-center gap-2',
                    events: {'click': (e) => _saveHeroSettings()},
                    [
                      i(classes: 'bi bi-check2-circle fs-5', []),
                      Component.text('Simpan Perubahan Banner & Brand'),
                    ],
                  ),
                ]),
              ]),
            ]),
          ]),
        ]),

        // Right Column: Real-Time Interactive Banner Preview
        div(classes: 'col-lg-5', [
          div(classes: 'card border-0 shadow-sm rounded-4 overflow-hidden sticky-top', attributes: {'style': 'top: 90px;'}, [
            div(classes: 'card-header bg-dark text-white p-3 d-flex align-items-center justify-content-between', [
              div(classes: 'd-flex align-items-center gap-2', [
                span(classes: 'spinner-grow spinner-grow-sm text-danger', []),
                h6(classes: 'fw-bold mb-0 text-white fs-7', [Component.text('Pratinjau Real-Time Banner Landing')]),
              ]),
              span(classes: 'badge bg-secondary rounded-pill fs-8', [Component.text('Live Preview')]),
            ]),
            div(classes: 'card-body p-4 hero-gradient-bg border-bottom position-relative', [
              // Badge Preview
              div(classes: 'mb-3', [
                span(classes: 'badge bg-danger-subtle text-danger rounded-pill px-3 py-2 fs-8 fw-bold badge-glow', [
                  Component.text(heroBadgeInput.isEmpty ? '100% Original Handmade' : heroBadgeInput),
                ]),
              ]),

              // Headline Preview
              h4(classes: 'fw-extrabold text-dark mb-2 lh-sm', [
                Component.text(heroHeadlinePrefixInput.isEmpty ? 'Kehangatan Sentuhan Tangan: ' : '$heroHeadlinePrefixInput '),
                span(classes: 'text-gradient-danger', [
                  Component.text(heroHeadlineHighlightInput.isEmpty ? 'Boneka & Rajutan Custom' : heroHeadlineHighlightInput),
                ]),
              ]),

              // Description Preview
              p(classes: 'text-muted fs-8 mb-4 line-clamp-3', [
                Component.text(heroDescriptionInput.isEmpty ? 'Deskripsi hero banner toko rajutan...' : heroDescriptionInput),
              ]),

              // Action Buttons Preview
              div(classes: 'd-flex flex-wrap gap-2 mb-4', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-danger btn-sm rounded-pill px-3 py-2 fw-bold shadow-sm',
                  [
                    i(classes: 'bi bi-bag-heart me-1', []),
                    Component.text('Beli Sekarang'),
                  ],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-outline-dark btn-sm rounded-pill px-3 py-2 fw-semibold',
                  [
                    i(classes: 'bi bi-whatsapp text-success me-1', []),
                    Component.text('Tanya WA'),
                  ],
                ),
              ]),

              // Header Image Preview
              div(classes: 'position-relative rounded-4 overflow-hidden border shadow-sm bg-white p-2 text-center animate-float', [
                img(
                  src: heroImageInput.isEmpty ? 'images/abelz_hero_cover.png' : heroImageInput,
                  classes: 'img-fluid rounded-3 object-fit-cover w-100',
                  styles: Styles(maxHeight: 220.px),
                  attributes: {'alt': 'Hero Header Preview'},
                ),
                div(classes: 'position-absolute bottom-0 start-50 translate-middle-x mb-3 bg-dark bg-opacity-75 text-white rounded-pill px-3 py-1 fs-8 fw-semibold shadow', [
                  i(classes: 'bi bi-magic me-1 text-warning', []),
                  Component.text(storeNameInput.isEmpty ? "Abel'z Handmade Official" : storeNameInput),
                ]),
              ]),
            ]),

            div(classes: 'card-footer bg-light p-3 fs-8 text-muted d-flex align-items-center justify-content-between', [
              span([
                i(classes: 'bi bi-info-circle me-1', []),
                Component.text('Tampilan di atas diperbarui secara langsung sesuai input.'),
              ]),
              a(
                href: '/landing',
                attributes: {'target': '_blank'},
                classes: 'text-danger fw-bold text-decoration-none',
                [
                  Component.text('Buka Landing Page '),
                  i(classes: 'bi bi-arrow-right', []),
                ],
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

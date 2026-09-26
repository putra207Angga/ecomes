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

  // Active Tab: 'hero', 'scarcity', 'stories', 'faqs'
  String activeCmsTab = 'hero';

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

  // Form Fields for Scarcity & PO Slots
  late String scarcityTitleInput;
  late String scarcitySubtitleInput;
  late int scarcityRemainingSlotsInput;
  late int scarcityTotalSlotsInput;

  // Story Editor Modal State
  bool showStoryModal = false;
  int? editingStoryIndex;
  String storyTitleInput = '';
  String storyLabelInput = '';
  String storyImageInput = '';
  String storyTagInput = '';
  String storyDescInput = '';

  // FAQ Editor Modal State
  bool showFaqModal = false;
  int? editingFaqIndex;
  String faqQuestionInput = '';
  String faqAnswerInput = '';

  // Preview state for FAQ in CMS
  int? previewFaqActiveIdx = 0;

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

  // Quick Presets for Stories
  final List<Map<String, String>> storyImagePresets = [
    {
      'label': 'Tas Rajut Pastel',
      'url': 'images/abelz_tas_rajut.png',
    },
    {
      'label': 'Ganci Miffy Charm',
      'url': 'images/abelz_ganci_miffy.png',
    },
    {
      'label': 'Cup Holder Eco',
      'url': 'images/abelz_cup_holder.png',
    },
    {
      'label': 'OOTD Aesthetic',
      'url': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500',
    },
    {
      'label': 'Handcrafted Studio',
      'url': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=500',
    },
    {
      'label': 'Happy Customer',
      'url': 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=500',
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

    scarcityTitleInput = cfg.scarcityTitle;
    scarcitySubtitleInput = cfg.scarcitySubtitle;
    scarcityRemainingSlotsInput = cfg.scarcityRemainingSlots;
    scarcityTotalSlotsInput = cfg.scarcityTotalSlots;
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

  void _saveScarcitySettings() {
    final store = AppStore();
    final cfg = store.landingConfig;
    cfg.scarcityTitle = scarcityTitleInput.trim();
    cfg.scarcitySubtitle = scarcitySubtitleInput.trim();
    cfg.scarcityRemainingSlots = scarcityRemainingSlotsInput;
    cfg.scarcityTotalSlots = scarcityTotalSlotsInput;

    store.updateLandingConfig(cfg);
    _showNotification('Pengaturan Slot Pre-Order & Scarcity Banner berhasil disimpan!');
  }

  void _openStoryEditor({int? index}) {
    final store = AppStore();
    if (index != null && index >= 0 && index < store.landingConfig.stories.length) {
      final s = store.landingConfig.stories[index];
      editingStoryIndex = index;
      storyTitleInput = s['title'] ?? '';
      storyLabelInput = s['label'] ?? '';
      storyImageInput = s['image'] ?? '';
      storyTagInput = s['tag'] ?? '';
      storyDescInput = s['desc'] ?? '';
    } else {
      editingStoryIndex = null;
      storyTitleInput = '';
      storyLabelInput = '';
      storyImageInput = 'images/abelz_tas_rajut.png';
      storyTagInput = 'New Drop ✨';
      storyDescInput = '';
    }
    setState(() {
      showStoryModal = true;
    });
  }

  void _saveStoryItem() {
    if (storyLabelInput.trim().isEmpty || storyImageInput.trim().isEmpty) {
      _showNotification('Label dan Gambar Story wajib diisi!');
      return;
    }

    final store = AppStore();
    final item = {
      'title': storyTitleInput.trim().isEmpty ? storyLabelInput.trim() : storyTitleInput.trim(),
      'label': storyLabelInput.trim(),
      'image': storyImageInput.trim(),
      'tag': storyTagInput.trim().isEmpty ? 'Story ✨' : storyTagInput.trim(),
      'desc': storyDescInput.trim(),
    };

    if (editingStoryIndex != null && editingStoryIndex! >= 0 && editingStoryIndex! < store.landingConfig.stories.length) {
      store.landingConfig.stories[editingStoryIndex!] = item;
      store.saveAll();
      _showNotification('Story "${item['label']}" berhasil diperbarui!');
    } else {
      store.landingConfig.stories.add(item);
      store.saveAll();
      _showNotification('Story baru "${item['label']}" berhasil ditambahkan!');
    }

    setState(() {
      showStoryModal = false;
    });
  }

  void _deleteStoryItem(int index) {
    final store = AppStore();
    if (index >= 0 && index < store.landingConfig.stories.length) {
      final label = store.landingConfig.stories[index]['label'] ?? 'Story';
      store.deleteStory(index);
      _showNotification('Story "$label" berhasil dihapus!');
      setState(() {});
    }
  }

  void _openFaqEditor({int? index}) {
    final store = AppStore();
    if (index != null && index >= 0 && index < store.landingConfig.faqs.length) {
      final f = store.landingConfig.faqs[index];
      editingFaqIndex = index;
      faqQuestionInput = f['q'] ?? '';
      faqAnswerInput = f['a'] ?? '';
    } else {
      editingFaqIndex = null;
      faqQuestionInput = '';
      faqAnswerInput = '';
    }
    setState(() {
      showFaqModal = true;
    });
  }

  void _saveFaqItem() {
    if (faqQuestionInput.trim().isEmpty || faqAnswerInput.trim().isEmpty) {
      _showNotification('Pertanyaan dan Jawaban FAQ wajib diisi!');
      return;
    }

    final store = AppStore();
    final item = {
      'q': faqQuestionInput.trim(),
      'a': faqAnswerInput.trim(),
    };

    store.saveFaq(item, index: editingFaqIndex);
    _showNotification(editingFaqIndex != null ? 'FAQ berhasil diperbarui!' : 'FAQ baru berhasil ditambahkan!');

    setState(() {
      showFaqModal = false;
    });
  }

  void _deleteFaqItem(int index) {
    final store = AppStore();
    if (index >= 0 && index < store.landingConfig.faqs.length) {
      store.deleteFaq(index);
      _showNotification('FAQ berhasil dihapus!');
      setState(() {});
    }
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
    _showNotification('Konfigurasi landing CMS berhasil di-reset ke default toko rajutan!');
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-md-7', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis d-flex align-items-center gap-2', [
                i(classes: 'bi bi-palette2 text-danger', []),
                Component.text('CMS & Konten Landing Page'),
              ]),
              p(classes: 'text-muted mb-0 fs-7', [
                Component.text('Kelola Hero Banner, Slot Pre-Order Mingguan, Story Highlights Instagram, dan FAQ Rajutan.'),
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

      // 3. Modern CMS Tabs Navigation
      div(classes: 'nav nav-pills bg-body p-2 rounded-4 shadow-sm mb-4 border d-flex gap-2 flex-wrap', [
        button(
          type: ButtonType.button,
          classes: 'nav-link rounded-pill px-4 py-2 fs-7 fw-bold ${activeCmsTab == 'hero' ? 'active bg-danger text-white shadow-sm' : 'text-body-emphasis bg-body-tertiary'}',
          events: {'click': (e) => setState(() => activeCmsTab = 'hero')},
          [
            i(classes: 'bi bi-image me-2', []),
            Component.text('Hero Banner & Brand'),
          ],
        ),
        button(
          type: ButtonType.button,
          classes: 'nav-link rounded-pill px-4 py-2 fs-7 fw-bold ${activeCmsTab == 'scarcity' ? 'active bg-danger text-white shadow-sm' : 'text-body-emphasis bg-body-tertiary'}',
          events: {'click': (e) => setState(() => activeCmsTab = 'scarcity')},
          [
            i(classes: 'bi bi-lightning-charge-fill me-2', []),
            Component.text('Slot PO & Scarcity'),
          ],
        ),
        button(
          type: ButtonType.button,
          classes: 'nav-link rounded-pill px-4 py-2 fs-7 fw-bold ${activeCmsTab == 'stories' ? 'active bg-danger text-white shadow-sm' : 'text-body-emphasis bg-body-tertiary'}',
          events: {'click': (e) => setState(() => activeCmsTab = 'stories')},
          [
            i(classes: 'bi bi-camera-reels-fill me-2', []),
            Component.text('Story Highlights Gen Z (${AppStore().landingConfig.stories.length})'),
          ],
        ),
        button(
          type: ButtonType.button,
          classes: 'nav-link rounded-pill px-4 py-2 fs-7 fw-bold ${activeCmsTab == 'faqs' ? 'active bg-danger text-white shadow-sm' : 'text-body-emphasis bg-body-tertiary'}',
          events: {'click': (e) => setState(() => activeCmsTab = 'faqs')},
          [
            i(classes: 'bi bi-question-circle-fill me-2', []),
            Component.text('FAQ Accordion (${AppStore().landingConfig.faqs.length})'),
          ],
        ),
      ]),

      // 4. Tab Contents
      if (activeCmsTab == 'hero') _buildHeroTab(),
      if (activeCmsTab == 'scarcity') _buildScarcityTab(),
      if (activeCmsTab == 'stories') _buildStoriesTab(),
      if (activeCmsTab == 'faqs') _buildFaqsTab(),

      // 5. Story Editor Modal
      if (showStoryModal) _buildStoryModalDialog(),

      // 6. FAQ Editor Modal
      if (showFaqModal) _buildFaqModalDialog(),
    ]);
  }

  // TAB 1: HERO & BRAND
  Component _buildHeroTab() {
    return div(classes: 'row g-4', [
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
              Component.text('Pilih opsi cepat preset gambar header untuk promo/best seller produk rajutan, atau masukkan URL/Path gambar kustom Anda:'),
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
              h6(classes: 'fw-bold mb-0 text-white fs-7', [Component.text('Pratinjau Real-Time Banner')]),
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
    ]);
  }

  // TAB 2: SCARCITY & PO SLOTS
  Component _buildScarcityTab() {
    final total = scarcityTotalSlotsInput > 0 ? scarcityTotalSlotsInput : 10;
    final remaining = scarcityRemainingSlotsInput.clamp(0, total);
    final percentTaken = (((total - remaining) / total) * 100).clamp(0, 100).toInt();

    return div(classes: 'row g-4', [
      // Left Column: Scarcity Form
      div(classes: 'col-lg-7', [
        div(classes: 'card border-0 shadow-sm rounded-4 mb-4 overflow-hidden', [
          div(classes: 'card-header bg-white border-bottom p-3 d-flex align-items-center justify-content-between', [
            h5(classes: 'fw-bold text-dark mb-0 d-flex align-items-center gap-2 fs-6', [
              i(classes: 'bi bi-lightning-charge-fill text-warning', []),
              Component.text('Pengaturan Slot Pre-Order Mingguan (Scarcity Banner)'),
            ]),
            span(classes: 'badge bg-warning-subtle text-dark rounded-pill px-3 py-1 fs-8 fw-bold', [
              Component.text('Batch Mingguan'),
            ]),
          ]),
          div(classes: 'card-body p-4 bg-white', [
            p(classes: 'text-muted fs-7 mb-4', [
              Component.text('Banner Scarcity bertujuan menciptakan urgensi bagi calon pembeli Gen Z agar segera klaim slot pesanan Pre-Order rajutan custom sebelum kuota minggu ini habis.'),
            ]),

            div(classes: 'row g-3', [
              div(classes: 'col-md-12', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Judul Banner Scarcity')]),
                input(
                  type: InputType.text,
                  classes: 'form-control rounded-3 fs-7',
                  value: scarcityTitleInput,
                  events: {'input': (e) => setState(() => scarcityTitleInput = (e.target as html.InputElement).value ?? '')},
                ),
                small(classes: 'text-muted fs-8 mt-1 d-block', [
                  Component.text('Contoh: Slot Pre-Order Rajutan Custom: Tersisa 4 dari 10 Slot!'),
                ]),
              ]),
              div(classes: 'col-md-12', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Deskripsi / Subtitle Scarcity')]),
                textarea(
                  classes: 'form-control rounded-3 fs-7',
                  rows: 2,
                  events: {'input': (e) => setState(() => scarcitySubtitleInput = (e.target as html.TextAreaElement).value ?? '')},
                  [Component.text(scarcitySubtitleInput)],
                ),
                small(classes: 'text-muted fs-8 mt-1 d-block', [
                  Component.text('Jelaskan alasan terbatasnya slot, misal: demi menjaga kerapian dan kualitas rajutan tangan.'),
                ]),
              ]),
              div(classes: 'col-md-6', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Sisa Slot Tersedia (Remaining)')]),
                input(
                  type: InputType.number,
                  classes: 'form-control rounded-3 fs-7',
                  value: scarcityRemainingSlotsInput.toString(),
                  events: {
                    'input': (e) {
                      setState(() {
                        scarcityRemainingSlotsInput = int.tryParse((e.target as html.InputElement).value ?? '0') ?? 0;
                      });
                    }
                  },
                ),
              ]),
              div(classes: 'col-md-6', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Total Slot Mingguan (Quota)')]),
                input(
                  type: InputType.number,
                  classes: 'form-control rounded-3 fs-7',
                  value: scarcityTotalSlotsInput.toString(),
                  events: {
                    'input': (e) {
                      setState(() {
                        scarcityTotalSlotsInput = int.tryParse((e.target as html.InputElement).value ?? '10') ?? 10;
                      });
                    }
                  },
                ),
              ]),
              div(classes: 'col-md-12 text-end mt-4', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-danger px-4 py-2 rounded-pill fw-bold shadow d-inline-flex align-items-center gap-2',
                  events: {'click': (e) => _saveScarcitySettings()},
                  [
                    i(classes: 'bi bi-check2-circle fs-5', []),
                    Component.text('Simpan Perubahan Scarcity'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
      ]),

      // Right Column: Live Scarcity Banner Preview
      div(classes: 'col-lg-5', [
        div(classes: 'card border-0 shadow-sm rounded-4 overflow-hidden sticky-top', attributes: {'style': 'top: 90px;'}, [
          div(classes: 'card-header bg-dark text-white p-3 d-flex align-items-center justify-content-between', [
            div(classes: 'd-flex align-items-center gap-2', [
              span(classes: 'spinner-grow spinner-grow-sm text-warning', []),
              h6(classes: 'fw-bold mb-0 text-white fs-7', [Component.text('Pratinjau Scarcity Banner Live')]),
            ]),
            span(classes: 'badge bg-secondary rounded-pill fs-8', [Component.text('Live Preview')]),
          ]),
          div(classes: 'card-body p-4 bg-light', [
            // Preview Card matching Landing Page
            div(
              classes: 'card border-0 rounded-4 p-4 shadow-sm text-white position-relative overflow-hidden mb-3',
              styles: Styles(raw: {'background': 'linear-gradient(135deg, #2D2424 0%, #C87D55 60%, #E2AC8D 100%)'}),
              [
                div(classes: 'd-flex align-items-center gap-2 mb-2 flex-wrap', [
                  span(classes: 'badge bg-danger rounded-pill px-3 py-1 fs-8 fw-bold d-inline-flex align-items-center gap-1', [
                    i(classes: 'bi bi-lightning-charge-fill', []),
                    Component.text('LIMITED WEEKLY SLOTS ⚡'),
                  ]),
                  span(classes: 'text-white-50 fs-8 fw-semibold', [
                    Component.text('Batch Pengerjaan'),
                  ]),
                ]),
                h5(classes: 'fw-bold text-white mb-2 fs-6', [
                  Component.text(scarcityTitleInput.isEmpty ? 'Slot Pre-Order Rajutan Custom: Tersisa $remaining dari $total Slot!' : scarcityTitleInput),
                ]),
                p(classes: 'text-white-50 fs-8 mb-3', [
                  Component.text(scarcitySubtitleInput.isEmpty ? 'Pengerjaan tangan handmade terbatas demi menjaga kerapian dan kualitas rajutan terbaik.' : scarcitySubtitleInput),
                ]),
                div(classes: 'd-flex align-items-center justify-content-between text-white-50 fs-8 mb-1 fw-bold', [
                  span([Component.text('Slot Terisi: $percentTaken%')]),
                  span([Component.text('Sisa: $remaining Slot')]),
                ]),
                div(classes: 'progress rounded-pill bg-white bg-opacity-25 mb-3', styles: Styles(height: 8.px), [
                  div(classes: 'progress-bar bg-warning rounded-pill', styles: Styles(width: percentTaken.percent), []),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-light btn-sm text-dark fw-bold rounded-pill px-3 py-1.5 fs-8 w-100 shadow-sm',
                  [Component.text('Klaim Slot Kamu Sekarang 🛍️')],
                ),
              ],
            ),
            div(classes: 'p-3 bg-white rounded-3 border fs-8 text-muted', [
              div(classes: 'd-flex justify-content-between mb-1', [
                span([Component.text('Total Slot:')]),
                span(classes: 'fw-bold text-dark', [Component.text('$total Slot')]),
              ]),
              div(classes: 'd-flex justify-content-between mb-1', [
                span([Component.text('Sisa Slot:')]),
                span(classes: 'fw-bold text-success', [Component.text('$remaining Slot')]),
              ]),
              div(classes: 'd-flex justify-content-between', [
                span([Component.text('Slot Terpakai:')]),
                span(classes: 'fw-bold text-danger', [Component.text('${total - remaining} Slot ($percentTaken%)')]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  // TAB 3: STORY HIGHLIGHTS GEN Z
  Component _buildStoriesTab() {
    final stories = AppStore().landingConfig.stories;

    return div(classes: 'row g-4', [
      // Left Column: Stories Management List
      div(classes: 'col-lg-7', [
        div(classes: 'card border-0 shadow-sm rounded-4 mb-4 overflow-hidden', [
          div(classes: 'card-header bg-white border-bottom p-3 d-flex align-items-center justify-content-between', [
            h5(classes: 'fw-bold text-dark mb-0 d-flex align-items-center gap-2 fs-6', [
              i(classes: 'bi bi-camera-reels-fill text-danger', []),
              Component.text('Daftar Story Highlights Gen Z (${stories.length})'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn btn-danger btn-sm rounded-pill px-3 py-1.5 fw-bold d-inline-flex align-items-center gap-1 shadow-sm',
              events: {'click': (e) => _openStoryEditor()},
              [
                i(classes: 'bi bi-plus-lg', []),
                Component.text('Tambah Story Baru'),
              ],
            ),
          ]),
          div(classes: 'card-body p-3 bg-white', [
            if (stories.isEmpty)
              div(classes: 'text-center py-5 text-muted', [
                i(classes: 'bi bi-camera-reels fs-1 text-secondary mb-2 d-block', []),
                p(classes: 'fs-7 fw-semibold mb-1', [Component.text('Belum ada Story Highlights.')]),
                small([Component.text('Klik tombol "Tambah Story Baru" di atas untuk menambahkan.')]),
              ])
            else
              div(classes: 'd-flex flex-column gap-2', [
                for (var storyIdx = 0; storyIdx < stories.length; storyIdx++)
                  div(classes: 'card border rounded-3 p-3 bg-light shadow-xs d-flex flex-row align-items-center justify-content-between gap-3', [
                    div(classes: 'd-flex align-items-center gap-3', [
                      div(
                        classes: 'rounded-circle overflow-hidden border border-danger border-2 p-0.5 bg-white flex-shrink-0 shadow-xs',
                        styles: Styles(width: 50.px, height: 50.px),
                        [
                          img(
                            src: stories[storyIdx]['image'] ?? 'images/abelz_tas_rajut.png',
                            classes: 'w-100 h-100 rounded-circle object-fit-cover',
                            attributes: {'alt': stories[storyIdx]['label'] ?? 'story'},
                          ),
                        ],
                      ),
                      div([
                        div(classes: 'd-flex align-items-center gap-2 mb-0.5', [
                          h6(classes: 'fw-bold text-dark fs-7 mb-0', [Component.text(stories[storyIdx]['title'] ?? '')]),
                          span(classes: 'badge bg-danger-subtle text-danger rounded-pill px-2 py-0.5 fs-9 fw-semibold', [
                            Component.text(stories[storyIdx]['tag'] ?? 'Story'),
                          ]),
                        ]),
                        div(classes: 'fs-8 text-secondary fw-semibold mb-1', [
                          Component.text('Tombol: "${stories[storyIdx]['label'] ?? ''}"'),
                        ]),
                        small(classes: 'text-muted fs-9 line-clamp-1 max-w-280px', [
                          Component.text(stories[storyIdx]['desc'] ?? ''),
                        ]),
                      ]),
                    ]),
                    div(classes: 'd-flex align-items-center gap-1 flex-shrink-0', [
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-primary rounded-circle p-1.5',
                        attributes: {'title': 'Edit Story'},
                        events: {'click': (e) => _openStoryEditor(index: storyIdx)},
                        [i(classes: 'bi bi-pencil fs-7', [])],
                      ),
                      button(
                        type: ButtonType.button,
                        classes: 'btn btn-sm btn-outline-danger rounded-circle p-1.5',
                        attributes: {'title': 'Hapus Story'},
                        events: {'click': (e) => _deleteStoryItem(storyIdx)},
                        [i(classes: 'bi bi-trash fs-7', [])],
                      ),
                    ]),
                  ]),
              ]),
          ]),
        ]),
      ]),

      // Right Column: Live Mobile Story Highlights Preview
      div(classes: 'col-lg-5', [
        div(classes: 'card border-0 shadow-sm rounded-4 overflow-hidden sticky-top', attributes: {'style': 'top: 90px;'}, [
          div(classes: 'card-header bg-dark text-white p-3 d-flex align-items-center justify-content-between', [
            div(classes: 'd-flex align-items-center gap-2', [
              span(classes: 'spinner-grow spinner-grow-sm text-danger', []),
              h6(classes: 'fw-bold mb-0 text-white fs-7', [Component.text('Pratinjau Story Bar (Mobile Live)')]),
            ]),
            span(classes: 'badge bg-secondary rounded-pill fs-8', [Component.text('Live Preview')]),
          ]),
          div(classes: 'card-body p-4 bg-white', [
            p(classes: 'text-muted fs-8 mb-3', [
              Component.text('Berikut adalah tampilan deretan story bubble yang muncul di mobile & tablet view:'),
            ]),
            div(classes: 'p-3 rounded-4 bg-light border shadow-inner', [
              div(classes: 'd-flex align-items-center gap-3 overflow-x-auto py-2 text-center', [
                for (var sIdx = 0; sIdx < stories.length; sIdx++)
                  div(
                    classes: 'd-flex flex-column align-items-center flex-shrink-0 cursor-pointer',
                    styles: Styles(width: 76.px),
                    [
                      div(
                        classes: 'rounded-circle p-0.5 border border-danger border-2 bg-white mb-1.5 shadow-sm',
                        styles: Styles(width: 58.px, height: 58.px),
                        [
                          img(
                            src: stories[sIdx]['image'] ?? 'images/abelz_tas_rajut.png',
                            classes: 'w-100 h-100 rounded-circle object-fit-cover',
                            attributes: {'alt': stories[sIdx]['label'] ?? 'story'},
                          ),
                        ],
                      ),
                      span(classes: 'fs-9 fw-semibold text-dark text-center line-clamp-1', [
                        Component.text(stories[sIdx]['label'] ?? ''),
                      ]),
                    ],
                  ),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  // TAB 4: FAQ ACCORDION
  Component _buildFaqsTab() {
    final faqs = AppStore().landingConfig.faqs;

    return div(classes: 'row g-4', [
      // Left Column: FAQ Management List
      div(classes: 'col-lg-7', [
        div(classes: 'card border-0 shadow-sm rounded-4 mb-4 overflow-hidden', [
          div(classes: 'card-header bg-white border-bottom p-3 d-flex align-items-center justify-content-between', [
            h5(classes: 'fw-bold text-dark mb-0 d-flex align-items-center gap-2 fs-6', [
              i(classes: 'bi bi-question-circle-fill text-danger', []),
              Component.text('Daftar Pertanyaan FAQ Rajutan (${faqs.length})'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn btn-danger btn-sm rounded-pill px-3 py-1.5 fw-bold d-inline-flex align-items-center gap-1 shadow-sm',
              events: {'click': (e) => _openFaqEditor()},
              [
                i(classes: 'bi bi-plus-lg', []),
                Component.text('Tambah FAQ Baru'),
              ],
            ),
          ]),
          div(classes: 'card-body p-3 bg-white', [
            if (faqs.isEmpty)
              div(classes: 'text-center py-5 text-muted', [
                i(classes: 'bi bi-question-circle fs-1 text-secondary mb-2 d-block', []),
                p(classes: 'fs-7 fw-semibold mb-1', [Component.text('Belum ada item FAQ.')]),
                small([Component.text('Klik tombol "Tambah FAQ Baru" di atas untuk menambahkan.')]),
              ])
            else
              div(classes: 'd-flex flex-column gap-2', [
                for (var faqIdx = 0; faqIdx < faqs.length; faqIdx++)
                  div(classes: 'card border rounded-3 p-3 bg-light shadow-xs', [
                    div(classes: 'd-flex align-items-start justify-content-between gap-2 mb-2', [
                      h6(classes: 'fw-bold text-dark fs-7 mb-0', [
                        Component.text('${faqIdx + 1}. ${faqs[faqIdx]['q'] ?? ''}'),
                      ]),
                      div(classes: 'd-flex align-items-center gap-1 flex-shrink-0', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm btn-outline-primary rounded-circle p-1.5',
                          attributes: {'title': 'Edit FAQ'},
                          events: {'click': (e) => _openFaqEditor(index: faqIdx)},
                          [i(classes: 'bi bi-pencil fs-7', [])],
                        ),
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm btn-outline-danger rounded-circle p-1.5',
                          attributes: {'title': 'Hapus FAQ'},
                          events: {'click': (e) => _deleteFaqItem(faqIdx)},
                          [i(classes: 'bi bi-trash fs-7', [])],
                        ),
                      ]),
                    ]),
                    p(classes: 'text-muted fs-8 mb-0', [
                      Component.text(faqs[faqIdx]['a'] ?? ''),
                    ]),
                  ]),
              ]),
          ]),
        ]),
      ]),

      // Right Column: Interactive FAQ Accordion Preview
      div(classes: 'col-lg-5', [
        div(classes: 'card border-0 shadow-sm rounded-4 overflow-hidden sticky-top', attributes: {'style': 'top: 90px;'}, [
          div(classes: 'card-header bg-dark text-white p-3 d-flex align-items-center justify-content-between', [
            div(classes: 'd-flex align-items-center gap-2', [
              span(classes: 'spinner-grow spinner-grow-sm text-danger', []),
              h6(classes: 'fw-bold mb-0 text-white fs-7', [Component.text('Pratinjau FAQ Accordion Live')]),
            ]),
            span(classes: 'badge bg-secondary rounded-pill fs-8', [Component.text('Live Preview')]),
          ]),
          div(classes: 'card-body p-4 bg-white', [
            p(classes: 'text-muted fs-8 mb-3', [
              Component.text('Klik item pertanyaan di bawah untuk melihat interaksi accordion pembeli:'),
            ]),
            div(classes: 'd-flex flex-column gap-2', [
              for (var fIdx = 0; fIdx < faqs.length; fIdx++)
                div(classes: 'border rounded-3 overflow-hidden shadow-xs', [
                  button(
                    type: ButtonType.button,
                    classes: 'btn w-100 text-start p-3 d-flex align-items-center justify-content-between gap-2 border-0 ${previewFaqActiveIdx == fIdx ? 'bg-danger-subtle bg-opacity-25' : 'bg-light'}',
                    events: {
                      'click': (e) {
                        setState(() {
                          previewFaqActiveIdx = previewFaqActiveIdx == fIdx ? null : fIdx;
                        });
                      }
                    },
                    [
                      span(classes: 'fw-bold text-dark fs-8 flex-grow-1', [Component.text(faqs[fIdx]['q'] ?? '')]),
                      i(classes: 'bi ${previewFaqActiveIdx == fIdx ? 'bi-dash-circle-fill text-danger' : 'bi-plus-circle text-muted'} fs-6', []),
                    ],
                  ),
                  if (previewFaqActiveIdx == fIdx)
                    div(classes: 'p-3 bg-white text-secondary fs-8 border-top', [
                      Component.text(faqs[fIdx]['a'] ?? ''),
                    ]),
                ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  // MODAL: STORY EDITOR
  Component _buildStoryModalDialog() {
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden bg-body text-body', [
          div(classes: 'modal-header bg-danger text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-camera-reels-fill fs-5', []),
              Component.text(editingStoryIndex != null ? 'Edit Story Highlight' : 'Tambah Story Highlight Baru'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showStoryModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-body', [
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('Label Tombol Bubble Story (Singkat)')]),
              input(
                type: InputType.text,
                classes: 'form-control fs-7',
                value: storyLabelInput,
                attributes: {'placeholder': 'Contoh: New Drops, OOTD Inspo, Custom'},
                events: {'input': (e) => setState(() => storyLabelInput = (e.target as html.InputElement).value ?? '')},
              ),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('Judul Lengkap Story (Saat Modal Terbuka)')]),
              input(
                type: InputType.text,
                classes: 'form-control fs-7',
                value: storyTitleInput,
                attributes: {'placeholder': 'Contoh: New Drops ✨ atau Koleksi Tas Lilac'},
                events: {'input': (e) => setState(() => storyTitleInput = (e.target as html.InputElement).value ?? '')},
              ),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('Tag Badge Story (Highlight Kategori)')]),
              input(
                type: InputType.text,
                classes: 'form-control fs-7',
                value: storyTagInput,
                attributes: {'placeholder': 'Contoh: Edisi Terbatas 🔥, 100% Handcrafted 👐'},
                events: {'input': (e) => setState(() => storyTagInput = (e.target as html.InputElement).value ?? '')},
              ),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('URL / Path Gambar Story')]),
              input(
                type: InputType.text,
                classes: 'form-control fs-7 mb-2',
                value: storyImageInput,
                attributes: {'placeholder': 'Contoh: images/abelz_tas_rajut.png atau URL Unsplash'},
                events: {'input': (e) => setState(() => storyImageInput = (e.target as html.InputElement).value ?? '')},
              ),
              small(classes: 'text-muted fs-8 d-block mb-2', [Component.text('Pilih cepat preset gambar rajutan:')]),
              div(classes: 'd-flex flex-wrap gap-1', [
                for (var p in storyImagePresets)
                  button(
                    type: ButtonType.button,
                    classes: 'btn btn-outline-secondary btn-sm rounded-pill fs-9 py-0.5 px-2 ${storyImageInput == p['url'] ? 'active bg-danger text-white border-danger' : ''}',
                    events: {'click': (e) => setState(() => storyImageInput = p['url']!)},
                    [Component.text(p['label']!)],
                  ),
              ]),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('Deskripsi / Cerita Story')]),
              textarea(
                classes: 'form-control fs-7',
                rows: 3,
                attributes: {'placeholder': 'Tuliskan deskripsi singkat mengenai koleksi atau info penting dalam story ini...'},
                events: {'input': (e) => setState(() => storyDescInput = (e.target as html.TextAreaElement).value ?? '')},
                [Component.text(storyDescInput)],
              ),
            ]),
          ]),
          div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary rounded-pill px-4 fw-semibold fs-7',
              events: {'click': (e) => setState(() => showStoryModal = false)},
              [Component.text('Batal')],
            ),
            button(
              type: ButtonType.button,
              classes: 'btn btn-danger rounded-pill px-4 fw-bold fs-7 shadow-sm',
              events: {'click': (e) => _saveStoryItem()},
              [Component.text('Simpan Story')],
            ),
          ]),
        ]),
      ]),
    ]);
  }

  // MODAL: FAQ EDITOR
  Component _buildFaqModalDialog() {
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden bg-body text-body', [
          div(classes: 'modal-header bg-danger text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6 d-flex align-items-center gap-2', [
              i(classes: 'bi bi-question-circle-fill fs-5', []),
              Component.text(editingFaqIndex != null ? 'Edit Pertanyaan FAQ' : 'Tambah Pertanyaan FAQ Baru'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showFaqModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-body', [
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('Pertanyaan (Question)')]),
              input(
                type: InputType.text,
                classes: 'form-control fs-7',
                value: faqQuestionInput,
                attributes: {'placeholder': 'Contoh: Berapa lama pengerjaan custom tas rajut?'},
                events: {'input': (e) => setState(() => faqQuestionInput = (e.target as html.InputElement).value ?? '')},
              ),
            ]),
            div(classes: 'mb-3', [
              label(classes: 'form-label fw-bold fs-7', [Component.text('Jawaban (Answer)')]),
              textarea(
                classes: 'form-control fs-7',
                rows: 4,
                attributes: {'placeholder': 'Tulis jawaban yang jelas dan ramah untuk pembeli...'},
                events: {'input': (e) => setState(() => faqAnswerInput = (e.target as html.TextAreaElement).value ?? '')},
                [Component.text(faqAnswerInput)],
              ),
            ]),
          ]),
          div(classes: 'modal-footer bg-body-tertiary border-top py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary rounded-pill px-4 fw-semibold fs-7',
              events: {'click': (e) => setState(() => showFaqModal = false)},
              [Component.text('Batal')],
            ),
            button(
              type: ButtonType.button,
              classes: 'btn btn-danger rounded-pill px-4 fw-bold fs-7 shadow-sm',
              events: {'click': (e) => _saveFaqItem()},
              [Component.text('Simpan FAQ')],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}

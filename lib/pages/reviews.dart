// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';

class ReviewsPage extends StatefulComponent {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  ReviewItem? activeReviewForReply;
  String replyInput = '';
  int starFilter = 0; // 0 = Semua
  String statusFilter = 'Semua'; // 'Semua', 'Perlu Balasan', 'Dibalas'

  bool showAddModal = false;
  String newCustomerName = '';
  String newProductTitle = 'Boneka Amigurumi Teddy Bear Premium';
  String newComment = '';
  int newRating = 5;

  void _addReview() {
    if (newCustomerName.trim().isEmpty || newComment.trim().isEmpty) return;
    final store = AppStore();
    final newRev = ReviewItem(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      customerName: newCustomerName.trim(),
      productTitle: newProductTitle.trim(),
      rating: newRating,
      comment: newComment.trim(),
      date: '${DateTime.now().day} Sep ${DateTime.now().year}',
      replyText: 'Terima kasih banyak atas ulasan positif dan ketersediaan testimonialnya Kak!',
      status: 'Dibalas',
    );
    store.reviews.insert(0, newRev);
    store.saveAll();
    setState(() {
      showAddModal = false;
      newCustomerName = '';
      newComment = '';
    });
  }

  void _openReplyModal(ReviewItem rev) {
    setState(() {
      activeReviewForReply = rev;
      replyInput = rev.replyText.isEmpty ? 'Terima kasih banyak atas ulasan positifnya Kak!' : rev.replyText;
    });
  }

  void _saveReply() {
    if (activeReviewForReply != null && replyInput.trim().isNotEmpty) {
      AppStore().replyReview(activeReviewForReply!.id, replyInput.trim());
      setState(() {
        activeReviewForReply = null;
      });
    }
  }

  void _deleteReview(String id) {
    if (html.window.confirm('Sembunyikan / Hapus ulasan ini dari publik?')) {
      AppStore().deleteReview(id);
      setState(() {});
    }
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final allReviews = store.reviews;

    final filteredReviews = allReviews.where((r) {
      final matchesStar = starFilter == 0 || r.rating == starFilter;
      final matchesStatus = statusFilter == 'Semua' || r.status == statusFilter;
      return matchesStar && matchesStatus;
    }).toList();

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Moderasi Ulasan & Rating Pembeli')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Respon testimoni pelanggan dan pantau kepuasan produk.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-danger btn-sm rounded-pill px-3 py-1.5 fw-bold me-2 shadow-sm',
                events: {'click': (e) => setState(() => showAddModal = true)},
                [
                  i(classes: 'bi bi-plus-circle me-1', []),
                  Component.text('Tambah Testimoni'),
                ],
              ),
              select(
                classes: 'form-select form-select-sm d-inline-block w-auto rounded-3 me-2',
                events: {
                  'change': (e) {
                    setState(() {
                      statusFilter = (e.target as html.SelectElement).value ?? '';
                    });
                  }
                },
                [
                  option(value: 'Semua', selected: statusFilter == 'Semua', [Component.text('Semua Status Balasan')]),
                  option(value: 'Perlu Balasan', selected: statusFilter == 'Perlu Balasan', [Component.text('Perlu Balasan Admin')]),
                  option(value: 'Dibalas', selected: statusFilter == 'Dibalas', [Component.text('Sudah Dibalas')]),
                ],
              ),
              select(
                classes: 'form-select form-select-sm d-inline-block w-auto rounded-3',
                events: {
                  'change': (e) {
                    setState(() {
                      starFilter = int.tryParse((e.target as html.SelectElement).value ?? '') ?? 0;
                    });
                  }
                },
                [
                  option(value: '0', selected: starFilter == 0, [Component.text('Semua Bintang')]),
                  option(value: '5', selected: starFilter == 5, [Component.text('5 Bintang (Sangat Puas)')]),
                  option(value: '4', selected: starFilter == 4, [Component.text('4 Bintang (Puas)')]),
                  option(value: '3', selected: starFilter == 3, [Component.text('3 Bintang (Cukup)')]),
                  option(value: '2', selected: starFilter == 2, [Component.text('2 Bintang (Kecewa)')]),
                  option(value: '1', selected: starFilter == 1, [Component.text('1 Bintang (Buruk)')]),
                ],
              ),
            ]),
          ]),
        ]),
      ]),

      // 2. Reviews List Card
      div(classes: 'card shadow-sm border-0 rounded-3', [
        div(classes: 'card-header bg-white py-3 border-bottom', [
          h5(classes: 'card-title fw-bold mb-0 text-dark', [
            i(classes: 'bi bi-star-fill text-warning me-2', []),
            Component.text('Testimoni & Feedback Terbaru'),
          ]),
        ]),
        div(classes: 'card-body p-0', [
          div(classes: 'table-responsive', [
            table(classes: 'table table-hover align-middle mb-0', [
              thead(classes: 'table-light fs-7', [
                tr([
                  th(classes: 'ps-3', [Component.text('Pelanggan & Tanggal')]),
                  th([Component.text('Produk')]),
                  th([Component.text('Rating Bintang')]),
                  th([Component.text('Komentar Ulasan')]),
                  th([Component.text('Balasan Admin')]),
                  th(classes: 'text-end pe-3', [Component.text('Aksi Moderasi')]),
                ]),
              ]),
              tbody([
                if (filteredReviews.isEmpty)
                  tr([
                    td(attributes: {'colspan': '6'}, classes: 'text-center py-5 text-muted', [
                      Component.text('Tidak ada ulasan ditemukan pada filter ini.'),
                    ]),
                  ])
                else
                  for (var rev in filteredReviews)
                    tr([
                      td(classes: 'ps-3', [
                        div([
                          div(classes: 'fw-bold fs-7 text-dark', [Component.text(rev.customerName)]),
                          div(classes: 'text-muted fs-8', [Component.text(rev.date)]),
                        ]),
                      ]),
                      td(classes: 'fs-7 fw-semibold text-primary', [Component.text(rev.productTitle)]),
                      td([
                        div(classes: 'text-warning fs-7', [
                          for (var idx = 0; idx < rev.rating; idx++) i(classes: 'bi bi-star-fill me-1', []),
                          span(classes: 'text-dark fw-bold ms-1', [Component.text('${rev.rating}.0')]),
                        ]),
                      ]),
                      td(classes: 'fs-7 text-dark', styles: Styles(maxWidth: 250.px), [
                        Component.text('"${rev.comment}"'),
                      ]),
                      td(classes: 'fs-7', [
                        if (rev.replyText.isNotEmpty)
                          div(classes: 'p-2 bg-light rounded border text-muted fs-8', [
                            strong(classes: 'text-dark d-block', [Component.text('Balasan Toko:')]),
                            Component.text(rev.replyText),
                          ])
                        else
                          span(classes: 'badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill fs-8', [
                            Component.text('Belum Dibalas'),
                          ]),
                      ]),
                      td(classes: 'text-end pe-3', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm ${rev.replyText.isNotEmpty ? 'btn-outline-secondary' : 'btn-primary fw-semibold'} me-1',
                          events: {'click': (e) => _openReplyModal(rev)},
                          [
                            i(classes: 'bi bi-reply-fill me-1', []),
                            Component.text(rev.replyText.isNotEmpty ? 'Edit' : 'Balas'),
                          ],
                        ),
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-sm btn-outline-danger',
                          events: {'click': (e) => _deleteReview(rev.id)},
                          [i(classes: 'bi bi-trash', [])],
                        ),
                      ]),
                    ]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 3. Modal Reply Review
      if (activeReviewForReply != null)
        div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
          div(classes: 'modal-dialog modal-dialog-centered', [
            div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
              div(classes: 'modal-header bg-primary text-white py-3', [
                h5(classes: 'modal-title fw-bold fs-6', [
                  i(classes: 'bi bi-chat-left-quote me-2', []),
                  Component.text('Balas Ulasan Pelanggan'),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'btn-close btn-close-white',
                  events: {'click': (e) => setState(() => activeReviewForReply = null)},
                  [],
                ),
              ]),
              div(classes: 'modal-body p-4', [
                div(classes: 'p-3 bg-light rounded-3 border mb-3', [
                  div(classes: 'fw-bold text-dark fs-7', [Component.text(activeReviewForReply!.customerName)]),
                  div(classes: 'text-warning fs-8 mb-1', [
                    for (var idx = 0; idx < activeReviewForReply!.rating; idx++) i(classes: 'bi bi-star-fill me-1', []),
                  ]),
                  p(classes: 'mb-0 fs-7 text-muted italic', [Component.text('"${activeReviewForReply!.comment}"')]),
                ]),
                div(classes: 'mb-3', [
                  label(classes: 'form-label fw-semibold fs-7', [Component.text('Pesan Balasan Resmi dari Admin Toko')]),
                  textarea(
                    classes: 'form-control',
                    rows: 4,
                    events: {
                      'input': (e) {
                        replyInput = (e.target as html.TextAreaElement).value ?? '';
                      }
                    },
                    [Component.text(replyInput)],
                  ),
                ]),
              ]),
              div(classes: 'modal-footer bg-light py-3', [
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-secondary px-3',
                  events: {'click': (e) => setState(() => activeReviewForReply = null)},
                  [Component.text('Batal')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-primary px-4 fw-semibold',
                  events: {'click': (e) => _saveReply()},
                  [
                    i(classes: 'bi bi-send-fill me-1', []),
                    Component.text('Kirim Balasan'),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),

      // 4. Modal Add Testimonial / Review
      if (showAddModal) _buildAddTestimonialModal(),
    ]);
  }

  Component _buildAddTestimonialModal() {
    return div(classes: 'modal fade show d-block bg-dark bg-opacity-50', attributes: {'tabindex': '-1'}, [
      div(classes: 'modal-dialog modal-dialog-centered', [
        div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
          div(classes: 'modal-header bg-danger text-white py-3', [
            h5(classes: 'modal-title fw-bold fs-6', [
              i(classes: 'bi bi-star-fill me-2', []),
              Component.text('Tambah Testimoni & Rating Pembeli Baru'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'btn-close btn-close-white',
              events: {'click': (e) => setState(() => showAddModal = false)},
              [],
            ),
          ]),
          div(classes: 'modal-body p-4 bg-light', [
            div(classes: 'row g-3', [
              div(classes: 'col-md-6', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Nama Pelanggan / Pembeli')]),
                input(
                  type: InputType.text,
                  classes: 'form-control rounded-3',
                  value: newCustomerName,
                  events: {'input': (e) => newCustomerName = (e.target as html.InputElement).value ?? ''},
                ),
              ]),
              div(classes: 'col-md-6', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Produk Dibeli')]),
                input(
                  type: InputType.text,
                  classes: 'form-control rounded-3',
                  value: newProductTitle,
                  events: {'input': (e) => newProductTitle = (e.target as html.InputElement).value ?? ''},
                ),
              ]),
              div(classes: 'col-md-12', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Rating Bintang Kepuasan (1-5)')]),
                select(
                  classes: 'form-select rounded-3',
                  events: {'change': (e) => newRating = int.tryParse((e.target as html.SelectElement).value ?? '') ?? 5},
                  [
                    option(value: '5', selected: newRating == 5, [Component.text('⭐⭐⭐⭐⭐ (5 - Sangat Puas)')]),
                    option(value: '4', selected: newRating == 4, [Component.text('⭐⭐⭐⭐ (4 - Puas)')]),
                    option(value: '3', selected: newRating == 3, [Component.text('⭐⭐⭐ (3 - Cukup)')]),
                  ],
                ),
              ]),
              div(classes: 'col-md-12', [
                label(classes: 'form-label fw-bold fs-7', [Component.text('Komentar Ulasan & Testimoni')]),
                textarea(
                  classes: 'form-control rounded-3',
                  rows: 3,
                  events: {'input': (e) => newComment = (e.target as html.TextAreaElement).value ?? ''},
                  [Component.text(newComment)],
                ),
              ]),
            ]),
          ]),
          div(classes: 'modal-footer bg-white py-3', [
            button(
              type: ButtonType.button,
              classes: 'btn btn-secondary px-3 rounded-pill fw-semibold',
              events: {'click': (e) => setState(() => showAddModal = false)},
              [Component.text('Batal')],
            ),
            button(
              type: ButtonType.button,
              classes: 'btn btn-danger px-4 rounded-pill fw-bold shadow-sm',
              events: {'click': (e) => _addReview()},
              [Component.text('Simpan Testimoni')],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}

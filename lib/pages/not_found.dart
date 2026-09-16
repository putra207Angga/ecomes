import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class NotFoundPage extends StatelessComponent {
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'app-content-wrapper p-5 text-center min-vh-100 d-flex align-items-center justify-content-center', [
      div(classes: 'error-page', [
        h1(classes: 'headline text-warning display-1 fw-bold mb-0', [Component.text('404')]),
        div(classes: 'error-content', [
          h3(classes: 'fw-bold text-dark mb-3', [
            i(classes: 'bi bi-exclamation-triangle-fill text-warning me-2', []),
            Component.text('Halaman Tidak Ditemukan!'),
          ]),
          p(classes: 'text-muted mb-4 fs-6', [
            Component.text('Maaf, halaman yang Anda cari tidak tersedia atau rute URL salah.'),
          ]),
          Link(
            to: '/',
            child: a(classes: 'btn btn-primary btn-lg shadow-sm px-4 rounded-pill', href: '/', [
              i(classes: 'bi bi-house-door me-2', []),
              Component.text('Kembali ke Dashboard'),
            ]),
          ),
        ]),
      ]),
    ]);
  }
}

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis', [Component.text('Tentang E-Comes & Arsitektur Sistem')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Informasi teknologi Jaspr Dart Web dan template AdminLTE v4.9.1.')]),
            ]),
            div(classes: 'col-sm-6', [
              ol(classes: 'breadcrumb float-sm-end mb-0 bg-transparent p-0', [
                li(classes: 'breadcrumb-item', [a(href: '/', [Component.text('Home')])]),
                li(classes: 'breadcrumb-item active', [Component.text('Tentang')]),
              ]),
            ]),
          ]),
        ]),
      ]),

      // Main Card
      div(classes: 'card shadow-sm border-0 rounded-3 bg-body', [
        div(classes: 'card-header bg-body py-3 border-bottom', [
          h5(classes: 'card-title fw-bold mb-0 text-primary', [
            i(classes: 'bi bi-info-circle me-2', []),
            Component.text('Spesifikasi Teknologi Framework'),
          ]),
        ]),
        div(classes: 'card-body p-4', [
          div(classes: 'row g-4', [
            div(classes: 'col-md-6', [
              div(classes: 'border rounded-3 p-3 bg-body-tertiary', [
                h6(classes: 'fw-bold text-primary mb-2', [
                  i(classes: 'bi bi-lightning-charge me-2', []),
                  Component.text('Jaspr Framework (Dart Web)'),
                ]),
                p(classes: 'text-muted fs-7 mb-0', [
                  Component.text('Jaspr adalah modern web framework berbasis bahasa Dart yang memungkinkan pengembangan web cepat dengan rendering server-side (SSR) maupun client-side (SPA).'),
                ]),
              ]),
            ]),
            div(classes: 'col-md-6', [
              div(classes: 'border rounded-3 p-3 bg-body-tertiary', [
                h6(classes: 'fw-bold text-success mb-2', [
                  i(classes: 'bi bi-layout-text-window-reverse me-2', []),
                  Component.text('AdminLTE 4.9.1 UI Template'),
                ]),
                p(classes: 'text-muted fs-7 mb-0', [
                  Component.text('Template admin open-source terbaik berbasis Bootstrap 5, OverlayScrollbars, dan font Source Sans 3 untuk antarmuka yang sangat responsif.'),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

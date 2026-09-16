// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulComponent {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = 'admin@ecomes.com';
  String password = '••••••••';
  String? errorMessage;

  void _handleLogin([String? customEmail, String? customRole]) {
    final targetEmail = customEmail ?? email;
    final auth = AuthService();
    final success = auth.login(targetEmail, password);
    if (success) {
      Router.of(context).push('/');
    } else {
      setState(() {
        errorMessage = 'Email atau password salah. Silakan coba lagi.';
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'bg-body-secondary d-flex align-items-center justify-content-center min-vh-100 p-3', [
      div(classes: 'login-box w-100', styles: Styles(maxWidth: 420.px), [
        div(classes: 'card card-outline card-primary shadow-lg border-0 rounded-4 overflow-hidden', [
          div(classes: 'card-header text-center bg-primary text-white py-4', [
            h3(classes: 'mb-0 fw-bold', [
              i(classes: 'bi bi-bag-check me-2', []),
              Component.text('E-Comes Admin'),
            ]),
            p(classes: 'small mb-0 opacity-75', [Component.text('Enterprise E-Commerce Management System')]),
          ]),
          div(classes: 'card-body p-4', [
            p(classes: 'login-box-msg text-center text-muted mb-4 fs-7', [
              Component.text('Silakan masuk untuk mengelola toko online Anda'),
            ]),
            if (errorMessage != null)
              div(classes: 'alert alert-danger p-2 mb-3 fs-7 text-center rounded-3', [
                Component.text(errorMessage!),
              ]),
            form(
              events: {
                'submit': (e) {
                  e.preventDefault();
                  _handleLogin();
                }
              },
              [
                div(classes: 'input-group mb-3', [
                  span(classes: 'input-group-text bg-light text-muted', [i(classes: 'bi bi-envelope', [])]),
                  input(
                    type: InputType.email,
                    classes: 'form-control',
                    value: email,
                    attributes: {'placeholder': 'Email Admin'},
                    events: {
                      'input': (e) {
                        final val = (e.target as html.InputElement).value ?? '';
                        email = val;
                      }
                    },
                  ),
                ]),
                div(classes: 'input-group mb-3', [
                  span(classes: 'input-group-text bg-light text-muted', [i(classes: 'bi bi-lock', [])]),
                  input(
                    type: InputType.password,
                    classes: 'form-control',
                    value: password,
                    attributes: {'placeholder': 'Password'},
                    events: {
                      'input': (e) {
                        final val = (e.target as html.InputElement).value ?? '';
                        password = val;
                      }
                    },
                  ),
                ]),
                div(classes: 'row align-items-center mb-4', [
                  div(classes: 'col-8', [
                    div(classes: 'form-check', [
                      input(
                        type: InputType.checkbox,
                        classes: 'form-check-input',
                        id: 'remember',
                        attributes: {'checked': 'checked'},
                      ),
                      label(classes: 'form-check-label fs-7 text-muted', attributes: {'for': 'remember'}, [
                        Component.text('Ingat Saya'),
                      ]),
                    ]),
                  ]),
                  div(classes: 'col-4', [
                    button(
                      type: ButtonType.submit,
                      classes: 'btn btn-primary btn-block w-100 fw-semibold shadow-sm',
                      [
                        Component.text('Masuk '),
                        i(classes: 'bi bi-box-arrow-in-right me-1', []),
                      ],
                    ),
                  ]),
                ]),
              ],
            ),
            div(classes: 'hr-text text-center text-muted position-relative mb-3 fs-8', [
              span(classes: 'bg-white px-2 text-muted', [Component.text('ATAU LOGIN DENGAN DEMO AKUN')]),
            ]),
            div(classes: 'd-grid gap-2', [
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-primary btn-sm d-flex align-items-center justify-content-between px-3 py-2 rounded-3',
                events: {'click': (e) => _handleLogin('admin@ecomes.com', 'Super Admin')},
                [
                  div(classes: 'text-start', [
                    div(classes: 'fw-bold fs-7', [Component.text('Super Admin')]),
                    div(classes: 'fs-8 text-muted', [Component.text('admin@ecomes.com (Akses Penuh)')]),
                  ]),
                  span(classes: 'badge bg-primary rounded-pill', [Component.text('Full Access')]),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-success btn-sm d-flex align-items-center justify-content-between px-3 py-2 rounded-3',
                events: {'click': (e) => _handleLogin('manager@ecomes.com', 'Store Manager')},
                [
                  div(classes: 'text-start', [
                    div(classes: 'fw-bold fs-7', [Component.text('Store Manager')]),
                    div(classes: 'fs-8 text-muted', [Component.text('manager@ecomes.com (Katalog & Stok)')]),
                  ]),
                  span(classes: 'badge bg-success rounded-pill', [Component.text('Manager')]),
                ],
              ),
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-info btn-sm d-flex align-items-center justify-content-between px-3 py-2 rounded-3',
                events: {'click': (e) => _handleLogin('cs@ecomes.com', 'CS Support')},
                [
                  div(classes: 'text-start', [
                    div(classes: 'fw-bold fs-7', [Component.text('CS Support')]),
                    div(classes: 'fs-8 text-muted', [Component.text('cs@ecomes.com (Chat & Ulasan)')]),
                  ]),
                  span(classes: 'badge bg-info text-dark rounded-pill', [Component.text('CS Staff')]),
                ],
              ),
            ]),
          ]),
          div(classes: 'card-footer text-center bg-light py-3 border-0 fs-8 text-muted', [
            Component.text('© 2026 E-Comes Admin Panel | Jaspr Dart Web & AdminLTE 4'),
          ]),
        ]),
      ]),
    ]);
  }
}

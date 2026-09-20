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
  String email = '';
  String password = '';
  String? errorMessage;

  void _handleLogin() {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      setState(() {
        errorMessage = 'Silakan masukkan email dan password admin Anda.';
      });
      return;
    }
    final auth = AuthService();
    final success = auth.login(email.trim(), password.trim());
    if (success) {
      Router.of(context).push('/admin');
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
                    attributes: {'placeholder': 'Email Admin', 'required': 'required'},
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
                    attributes: {'placeholder': 'Password', 'required': 'required'},
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
          ]),
          div(classes: 'card-footer text-center bg-light py-3 border-0 fs-8 text-muted', [
            Component.text('© 2026 E-Comes Admin Panel | Jaspr Dart Web & AdminLTE 4'),
          ]),
        ]),
      ]),
    ]);
  }
}

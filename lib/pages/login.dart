// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../services/app_store.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulComponent {
  final String initialMode; // 'login' or 'register'
  final String initialRole;

  const LoginPage({
    super.key,
    this.initialMode = 'login',
    this.initialRole = 'member',
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String currentMode; // 'login' or 'register'

  // Unified Login State (Member & Admin)
  String loginIdentifierInput = '';
  String loginPasswordInput = '';
  bool rememberMe = true;

  // Member Register State
  String regNameInput = '';
  String regEmailInput = '';
  String regPhoneInput = '';
  String regPasswordInput = '';
  String regConfirmPasswordInput = '';
  bool agreeTerms = true;

  // Common UI State
  String? errorMessage;
  String? successMessage;
  bool showPassword = false;
  bool isSubmitting = false;

  // Social Auth Modal State
  bool showSocialModal = false;
  String selectedSocialProvider = 'Google';
  String customSocialEmail = 'angga.wijaya207@gmail.com';
  String customSocialName = 'Angga Wijaya';

  @override
  void initState() {
    super.initState();
    currentMode = component.initialMode;
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();
  }

  /// Unified Login Handler:
  /// Middleware logic automatically detects whether credentials belong to
  /// Admin/Staff (redirect to /admin) or Member/Customer (redirect to /).
  void _handleUnifiedLogin() {
    final identifier = _sanitizeText(loginIdentifierInput);
    final password = loginPasswordInput.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Silakan masukkan email / no. WhatsApp dan password Anda.';
        successMessage = null;
      });
      return;
    }

    if (identifier.length > 100 || password.length > 100) {
      setState(() {
        errorMessage = 'Panjang karakter melebihi batas yang diperbolehkan.';
        successMessage = null;
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
      successMessage = null;
    });

    // 1. Check Admin / Management credentials first
    final auth = AuthService();
    final isAdmin = auth.login(identifier, password);
    if (isAdmin) {
      setState(() {
        isSubmitting = false;
        successMessage = 'Login Admin berhasil! Mengalihkan ke Dashboard Toko...';
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        Router.of(context).push('/admin');
      });
      return;
    }

    // 2. Check Member / Customer credentials
    final isMember = AppStore().loginMember(
      emailOrPhone: identifier,
      password: password,
    );
    if (isMember) {
      setState(() {
        isSubmitting = false;
        successMessage = 'Berhasil masuk sebagai Member! Mengalihkan ke toko...';
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        Router.of(context).push('/');
      });
      return;
    }

    // 3. If neither Admin nor Member match
    setState(() {
      isSubmitting = false;
      errorMessage = 'Email/No. WhatsApp atau password tidak cocok. Silakan periksa kembali akun Anda.';
    });
  }

  void _handleMemberRegister() {
    final name = _sanitizeText(regNameInput);
    final email = _sanitizeText(regEmailInput.toLowerCase());
    final phone = regPhoneInput.replaceAll(RegExp(r'[^0-9+]'), '').trim();
    final password = regPasswordInput.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Mohon lengkapi seluruh kolom formulir pendaftaran.';
        successMessage = null;
      });
      return;
    }

    if (name.length < 2 || name.length > 60) {
      setState(() {
        errorMessage = 'Nama lengkap harus antara 2 hingga 60 karakter.';
        successMessage = null;
      });
      return;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        errorMessage = 'Format email tidak valid. Masukkan alamat email yang benar.';
        successMessage = null;
      });
      return;
    }

    if (phone.length < 9 || phone.length > 16) {
      setState(() {
        errorMessage = 'Nomor telepon / WhatsApp tidak valid (minimal 9 digit).';
        successMessage = null;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password minimal harus 6 karakter untuk keamanan akun Anda.';
        successMessage = null;
      });
      return;
    }

    if (password != regConfirmPasswordInput && regConfirmPasswordInput.isNotEmpty) {
      setState(() {
        errorMessage = 'Konfirmasi password tidak sesuai dengan password Anda.';
        successMessage = null;
      });
      return;
    }

    if (!agreeTerms) {
      setState(() {
        errorMessage = 'Anda wajib menyetujui Syarat & Ketentuan Keanggotaan.';
        successMessage = null;
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    final success = AppStore().registerMember(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (success) {
      setState(() {
        isSubmitting = false;
        successMessage = 'Pendaftaran berhasil! Anda mendapatkan 100 Poin Selamat Datang. Mengalihkan ke toko...';
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        Router.of(context).push('/');
      });
    } else {
      setState(() {
        isSubmitting = false;
        errorMessage = 'Gagal mendaftarkan akun. Silakan coba beberapa saat lagi.';
      });
    }
  }

  void _openSocialAuth(String provider) {
    if (provider == 'Google') {
      customSocialName = 'Angga Wijaya';
      customSocialEmail = 'angga.wijaya207@gmail.com';
    } else if (provider == 'Facebook') {
      customSocialName = 'Siti Aminah';
      customSocialEmail = 'siti.aminah.fb@gmail.com';
    } else {
      customSocialName = 'Budi Kurniawan';
      customSocialEmail = 'budi.kurniawan@icloud.com';
    }

    setState(() {
      selectedSocialProvider = provider;
      showSocialModal = true;
      errorMessage = null;
    });
  }

  void _confirmSocialLogin() {
    final avatar = selectedSocialProvider == 'Google'
        ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'
        : selectedSocialProvider == 'Facebook'
            ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'
            : 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150';

    final success = AppStore().loginOrRegisterSocial(
      provider: selectedSocialProvider.toLowerCase(),
      name: customSocialName.trim().isNotEmpty ? customSocialName.trim() : 'Pengguna $selectedSocialProvider',
      email: customSocialEmail.trim().isNotEmpty ? customSocialEmail.trim() : 'user@${selectedSocialProvider.toLowerCase()}.com',
      avatar: avatar,
    );

    setState(() {
      showSocialModal = false;
      if (success) {
        successMessage = 'Berhasil terhubung dengan $selectedSocialProvider! Mengalihkan ke toko...';
      }
    });

    if (success) {
      Future.delayed(const Duration(milliseconds: 700), () {
        Router.of(context).push('/');
      });
    }
  }


  @override
  Component build(BuildContext context) {
    return div(
      classes: 'min-vh-100 w-100 d-flex flex-column bg-white overflow-hidden position-relative',
      styles: Styles(raw: {'min-height': '100vh', 'height': '100vh'}),
      [
        div(classes: 'row g-0 w-100 flex-grow-1 m-0 h-100', [
          // ==========================================
          // LEFT COLUMN: SPACIOUS BRANDING & SHOWCASE (Desktop)
          // ==========================================
          div(
            classes: 'col-lg-5 col-xl-5 d-none d-lg-flex flex-column justify-content-between p-4 p-xl-5 text-white position-relative overflow-hidden h-100',
            attributes: {
              'style': 'background: linear-gradient(155deg, #1C1513 0%, #291C18 35%, #7D3E24 75%, #B8653F 100%);',
            },
            [
              // Ambient radial glow orbs & pattern
              div(classes: 'position-absolute top-0 start-0 w-100 h-100 opacity-15 pointer-events-none', attributes: {
                'style': 'background-image: radial-gradient(#F0C5A8 1.2px, transparent 1.2px); background-size: 24px 24px;',
              }, []),
              div(classes: 'position-absolute rounded-circle pointer-events-none', attributes: {
                'style': 'top: -60px; right: -60px; width: 320px; height: 320px; background: radial-gradient(circle, rgba(200, 125, 85, 0.35) 0%, transparent 70%); filter: blur(60px);',
              }, []),

              // Top Brand Header & Features
              div(classes: 'position-relative z-1 pt-2', [
                div(classes: 'd-inline-flex align-items-center gap-2 mb-4 rounded-pill px-3.5 py-1.5 shadow-sm', attributes: {
                  'style': 'background: rgba(255, 255, 255, 0.12); backdrop-filter: blur(12px); border: 1px solid rgba(255, 255, 255, 0.22);',
                }, [
                  span(classes: 'fs-5', [Component.text('🧶')]),
                  span(classes: 'fs-8 fw-bold text-white text-uppercase tracking-wider', [
                    Component.text("Abel'z Handmade Studio"),
                  ]),
                  span(classes: 'badge bg-warning text-dark rounded-pill px-2 py-0.5 fs-9 fw-extrabold ms-1', [
                    Component.text('OFFICIAL'),
                  ]),
                ]),

                h2(classes: 'fw-extrabold font-serif-heading text-white mb-3 tracking-wide leading-tight fs-2', [
                  Component.text('Kehangatan Sentuhan Tangan dalam Setiap '),
                  span(classes: 'fst-italic text-warning', [Component.text('Karya Rajutan ✨')]),
                ]),
                p(classes: 'text-white-50 fs-7 mb-5 leading-relaxed', [
                  Component.text('Satu portal akun terpadu untuk berbelanja produk rajutan handmade estetik dan mengelola operasional toko dengan mudah.'),
                ]),

                // Clean Spacious Feature Points (No cramped cards!)
                div(classes: 'd-flex flex-column gap-4 mb-4', [
                  div(classes: 'd-flex align-items-start gap-3.5', [
                    div(classes: 'rounded-circle bg-warning text-dark d-flex align-items-center justify-content-center flex-shrink-0 mt-0.5 shadow-sm', styles: Styles(width: 38.px, height: 38.px), [
                      i(classes: 'bi bi-gift-fill fs-6', []),
                    ]),
                    div([
                      h6(classes: 'fw-bold text-white fs-7 mb-1', [Component.text('Bonus 100 Poin Sambutan Member')]),
                      p(classes: 'fs-8 text-white-50 mb-0 leading-normal', [Component.text('Dapatkan 100 poin belanja langsung untuk potongan harga di setiap transaksi.')]),
                    ]),
                  ]),

                  div(classes: 'd-flex align-items-start gap-3.5', [
                    div(classes: 'rounded-circle bg-info text-white d-flex align-items-center justify-content-center flex-shrink-0 mt-0.5 shadow-sm', styles: Styles(width: 38.px, height: 38.px), [
                      i(classes: 'bi bi-palette-fill fs-6', []),
                    ]),
                    div([
                      h6(classes: 'fw-bold text-white fs-7 mb-1', [Component.text('Pilihan Benang & Kustomisasi Warna')]),
                      p(classes: 'fs-8 text-white-50 mb-0 leading-normal', [Component.text('Tersedia benang Poliindo & Milk Cotton dengan aneka palet pastel estetik.')]),
                    ]),
                  ]),

                  div(classes: 'd-flex align-items-start gap-3.5', [
                    div(classes: 'rounded-circle bg-success text-white d-flex align-items-center justify-content-center flex-shrink-0 mt-0.5 shadow-sm', styles: Styles(width: 38.px, height: 38.px), [
                      i(classes: 'bi bi-shield-check fs-6', []),
                    ]),
                    div([
                      h6(classes: 'fw-bold text-white fs-7 mb-1', [Component.text('Satu Akun Multi-Akses Otomatis')]),
                      p(classes: 'fs-8 text-white-50 mb-0 leading-normal', [Component.text('Sistem cerdas otomatis mengenali peran Member Pembeli atau Staf Admin.')]),
                    ]),
                  ]),
                ]),
              ]),

              // Bottom Social Proof & Trust Footer (Well-spaced, no collision!)
              div(classes: 'position-relative z-1 pt-4 mt-auto border-top border-white border-opacity-20 d-flex justify-content-between align-items-center flex-wrap gap-3', [
                div(classes: 'd-flex align-items-center gap-3', [
                  div(classes: 'd-flex align-items-center me-2', [
                    img(src: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80', classes: 'rounded-circle border border-2 border-white object-fit-cover shadow-sm', attributes: {'width': '34', 'height': '34', 'alt': 'Avatar'}),
                    img(src: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80', classes: 'rounded-circle border border-2 border-white object-fit-cover shadow-sm', attributes: {'width': '34', 'height': '34', 'alt': 'Avatar', 'style': 'margin-left: -10px;'}),
                    img(src: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80', classes: 'rounded-circle border border-2 border-white object-fit-cover shadow-sm', attributes: {'width': '34', 'height': '34', 'alt': 'Avatar', 'style': 'margin-left: -10px;'}),
                  ]),
                  div([
                    div(classes: 'text-warning fs-8 lh-1 mb-1', [
                      i(classes: 'bi bi-star-fill me-0.5', []),
                      i(classes: 'bi bi-star-fill me-0.5', []),
                      i(classes: 'bi bi-star-fill me-0.5', []),
                      i(classes: 'bi bi-star-fill me-0.5', []),
                      i(classes: 'bi bi-star-fill me-1', []),
                      span(classes: 'fw-bold text-white', [Component.text('4.9 / 5.0')]),
                    ]),
                    small(classes: 'text-white-50 fs-9 d-block', [Component.text('1.200+ Pelanggan Puas di Seluruh Indonesia')]),
                  ]),
                ]),
                span(classes: 'badge bg-white bg-opacity-10 border border-white border-opacity-25 rounded-pill px-3 py-1.5 fs-8 fw-semibold text-white shadow-xs', [
                  Component.text('100% Handcrafted 🧶'),
                ]),
              ]),
            ],
          ),

          // ==========================================
          // RIGHT COLUMN: SPACIOUS AUTHENTICATION FORM
          // ==========================================
          div(
            classes: 'col-lg-7 col-xl-7 d-flex flex-column justify-content-center align-items-center p-4 p-md-5 h-100 overflow-y-auto',
            attributes: {
              'style': 'background: #FFFFFF;',
            },
            [
              div(classes: 'w-100 my-auto py-3', styles: Styles(maxWidth: 460.px), [
                // Mobile Header (< lg)
                div(classes: 'd-lg-none text-center mb-4 pb-3 border-bottom border-light-subtle', [
                  div(classes: 'd-inline-flex align-items-center justify-content-center rounded-circle bg-pink-cream text-terracotta p-2.5 mb-2 shadow-xs', [
                    span(classes: 'fs-3', [Component.text('🧶')]),
                  ]),
                  h4(classes: 'fw-bold mb-1 font-serif-heading text-espresso', [Component.text("Abel'z Handmade & E-Comes")]),
                  p(classes: 'small text-espresso-muted fs-8 mb-0', [Component.text('Portal Autentikasi Member & Admin Toko')]),
                ]),

                // Segmented Control Switcher: Masuk (Login) vs Daftar Member (Spacious)
                div(classes: 'nav nav-pills nav-fill mb-4 p-1.5 rounded-pill shadow-xs', attributes: {
                  'style': 'background: #F5EFEB; border: 1px solid #EAE1D9;',
                }, [
                  button(
                    type: ButtonType.button,
                    classes: 'nav-link rounded-pill fs-7 py-2.5 tap-bounce',
                    attributes: currentMode == 'login' ? {
                      'style': 'background: linear-gradient(135deg, #C87D55, #B56740); box-shadow: 0 4px 14px rgba(200, 125, 85, 0.35); color: #ffffff; font-weight: 700;',
                    } : {
                      'style': 'color: #4A3B32; font-weight: 600;',
                    },
                    events: {'click': (e) => setState(() {
                      currentMode = 'login';
                      errorMessage = null;
                      successMessage = null;
                    })},
                    [
                      i(classes: 'bi bi-box-arrow-in-right me-2', []),
                      Component.text('Masuk (Login)'),
                    ],
                  ),
                  button(
                    type: ButtonType.button,
                    classes: 'nav-link rounded-pill fs-7 py-2.5 tap-bounce',
                    attributes: currentMode == 'register' ? {
                      'style': 'background: linear-gradient(135deg, #C87D55, #B56740); box-shadow: 0 4px 14px rgba(200, 125, 85, 0.35); color: #ffffff; font-weight: 700;',
                    } : {
                      'style': 'color: #4A3B32; font-weight: 600;',
                    },
                    events: {'click': (e) => setState(() {
                      currentMode = 'register';
                      errorMessage = null;
                      successMessage = null;
                    })},
                    [
                      i(classes: 'bi bi-person-plus-fill me-2', []),
                      Component.text('Daftar Member (+100 Poin)'),
                    ],
                  ),
                ]),

                // Feedback Alerts
                if (errorMessage != null)
                  div(classes: 'alert alert-danger d-flex align-items-center gap-2 rounded-3 py-2.5 px-3.5 fs-7 mb-4 shadow-xs border-0', attributes: {
                    'style': 'background-color: #FEE2E2; color: #991B1B;',
                  }, [
                    i(classes: 'bi bi-exclamation-triangle-fill fs-6', []),
                    span(classes: 'fw-semibold', [Component.text(errorMessage!)]),
                  ]),

                if (successMessage != null)
                  div(classes: 'alert alert-success d-flex align-items-center gap-2 rounded-3 py-2.5 px-3.5 fs-7 mb-4 shadow-xs border-0', attributes: {
                    'style': 'background-color: #DCFCE7; color: #166534;',
                  }, [
                    i(classes: 'bi bi-check-circle-fill fs-6', []),
                    span(classes: 'fw-semibold', [Component.text(successMessage!)]),
                  ]),

                // ==========================================
                // MODE 1: UNIFIED LOGIN (Member & Admin)
                // ==========================================
                if (currentMode == 'login') ...[
                  // Social Media Login Options (Spacious)
                  div(classes: 'mb-4', [
                    div(classes: 'text-center mb-2.5', [
                      span(classes: 'fs-8 text-uppercase fw-bold text-muted tracking-wider', [Component.text('Masuk Cepat dengan Akun Sosial:')]),
                    ]),
                    div(classes: 'row g-2.5', [
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-light bg-white border border-light-subtle text-dark fw-bold py-2.5 w-100 rounded-pill shadow-xs d-flex align-items-center justify-content-center gap-1.5 hover-scale tap-bounce fs-8',
                          events: {'click': (e) => _openSocialAuth('Google')},
                          [
                            span(classes: 'fs-6', styles: Styles(lineHeight: 1.em), [Component.text('🌐')]),
                            Component.text('Google'),
                          ],
                        ),
                      ]),
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn text-white fw-bold py-2.5 w-100 rounded-pill shadow-xs d-flex align-items-center justify-content-center gap-1.5 hover-scale tap-bounce fs-8',
                          attributes: {'style': 'background: linear-gradient(135deg, #1877F2, #0C63D4); border: none; box-shadow: 0 4px 12px rgba(24, 119, 242, 0.25);'},
                          events: {'click': (e) => _openSocialAuth('Facebook')},
                          [
                            i(classes: 'bi bi-facebook fs-6', []),
                            Component.text('Facebook'),
                          ],
                        ),
                      ]),
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-dark text-white fw-bold py-2.5 w-100 rounded-pill shadow-xs d-flex align-items-center justify-content-center gap-1.5 hover-scale tap-bounce fs-8',
                          attributes: {'style': 'background: linear-gradient(135deg, #222222, #000000); border: none; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);'},
                          events: {'click': (e) => _openSocialAuth('Apple')},
                          [
                            i(classes: 'bi bi-apple fs-6', []),
                            Component.text('Apple ID'),
                          ],
                        ),
                      ]),
                    ]),
                  ]),

                  // Divider (Clear Spacing)
                  div(classes: 'd-flex align-items-center my-4 text-muted', [
                    hr(classes: 'flex-grow-1 border-light-subtle my-0'),
                    span(classes: 'px-3 fs-8 text-uppercase fw-semibold tracking-wider text-muted', [Component.text('atau dengan email / no. whatsapp')]),
                    hr(classes: 'flex-grow-1 border-light-subtle my-0'),
                  ]),

                  // Unified Login Form (Spacious Vertical Rhythm)
                  form(
                    events: {
                      'submit': (e) {
                        e.preventDefault();
                        _handleUnifiedLogin();
                      }
                    },
                    [
                      div(classes: 'mb-3.5', [
                        label(classes: 'form-label fw-bold text-espresso fs-7 mb-2', [
                          Component.text('Email atau No. WhatsApp:'),
                        ]),
                        div(classes: 'input-group', [
                          span(classes: 'input-group-text border-end-0 text-espresso-muted', attributes: {
                            'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                          }, [i(classes: 'bi bi-person-circle fs-6 text-terracotta', [])]),
                          input(
                            type: InputType.text,
                            classes: 'form-control border-start-0 fs-7 py-2.5',
                            value: loginIdentifierInput,
                            attributes: {
                              'placeholder': 'Masukkan email atau no. WhatsApp',
                              'required': 'required',
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            },
                            events: {'input': (e) => loginIdentifierInput = (e.target as html.InputElement).value ?? ''},
                          ),
                        ]),
                      ]),

                      div(classes: 'mb-3.5', [
                        div(classes: 'd-flex justify-content-between align-items-center mb-2', [
                          label(classes: 'form-label fw-bold text-espresso fs-7 mb-0', [Component.text('Password:')]),
                          a(classes: 'fs-8 text-terracotta text-decoration-none fw-semibold hover-underline', href: '#', events: {
                            'click': (e) {
                              e.preventDefault();
                              setState(() => errorMessage = 'Silakan hubungi CS WhatsApp kami untuk bantuan reset password.');
                            }
                          }, [Component.text('Lupa Password?')]),
                        ]),
                        div(classes: 'input-group', [
                          span(classes: 'input-group-text border-end-0 text-espresso-muted', attributes: {
                            'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                          }, [i(classes: 'bi bi-shield-lock-fill fs-6 text-terracotta', [])]),
                          input(
                            type: showPassword ? InputType.text : InputType.password,
                            classes: 'form-control border-start-0 border-end-0 fs-7 py-2.5',
                            value: loginPasswordInput,
                            attributes: {
                              'placeholder': 'Masukkan password akun Anda',
                              'required': 'required',
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            },
                            events: {'input': (e) => loginPasswordInput = (e.target as html.InputElement).value ?? ''},
                          ),
                          button(
                            type: ButtonType.button,
                            classes: 'input-group-text border-start-0 text-espresso-muted tap-bounce',
                            attributes: {
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            },
                            events: {'click': (e) => setState(() => showPassword = !showPassword)},
                            [i(classes: 'bi ${showPassword ? 'bi-eye-slash' : 'bi-eye'} fs-7', [])],
                          ),
                        ]),
                      ]),

                      // Remember Me Checkbox
                      div(classes: 'form-check mb-3', [
                        input(
                          type: InputType.checkbox,
                          classes: 'form-check-input',
                          id: 'unifiedRemember',
                          attributes: rememberMe ? {'checked': 'checked'} : {},
                          events: {'change': (e) => rememberMe = (e.target as html.InputElement).checked ?? true},
                        ),
                        label(classes: 'form-check-label fs-8 text-espresso-muted fw-semibold', attributes: {'for': 'unifiedRemember'}, [
                          Component.text('Ingat Saya di perangkat ini'),
                        ]),
                      ]),



                      // Primary CTA Button (Generous size & spacing)
                      button(
                        type: ButtonType.submit,
                        classes: 'btn btn-terracotta w-100 py-2.5 rounded-pill fw-bold fs-6 shadow-sm d-flex align-items-center justify-content-center gap-2 hover-scale tap-bounce mb-4',
                        attributes: isSubmitting ? {'disabled': 'disabled'} : {},
                        [
                          if (isSubmitting)
                            span(classes: 'spinner-border spinner-border-sm me-1', [])
                          else
                            i(classes: 'bi bi-box-arrow-in-right fs-6', []),
                          Component.text('Masuk ke Akun'),
                        ],
                      ),
                    ],
                  ),
                ]

                // ==========================================
                // MODE 2: REGISTER (Daftar Member Baru)
                // ==========================================
                else ...[
                  // Social Media Register (Spacious)
                  div(classes: 'mb-4', [
                    div(classes: 'text-center mb-2.5', [
                      span(classes: 'fs-8 text-uppercase fw-bold text-muted tracking-wider', [Component.text('Daftar Cepat dengan Akun Sosial:')]),
                    ]),
                    div(classes: 'row g-2.5', [
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-light bg-white border border-light-subtle text-dark fw-bold py-2.5 w-100 rounded-pill shadow-xs d-flex align-items-center justify-content-center gap-1.5 hover-scale tap-bounce fs-8',
                          events: {'click': (e) => _openSocialAuth('Google')},
                          [
                            span(classes: 'fs-6', styles: Styles(lineHeight: 1.em), [Component.text('🌐')]),
                            Component.text('Google'),
                          ],
                        ),
                      ]),
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn text-white fw-bold py-2.5 w-100 rounded-pill shadow-xs d-flex align-items-center justify-content-center gap-1.5 hover-scale tap-bounce fs-8',
                          attributes: {'style': 'background: linear-gradient(135deg, #1877F2, #0C63D4); border: none; box-shadow: 0 4px 12px rgba(24, 119, 242, 0.25);'},
                          events: {'click': (e) => _openSocialAuth('Facebook')},
                          [
                            i(classes: 'bi bi-facebook fs-6', []),
                            Component.text('Facebook'),
                          ],
                        ),
                      ]),
                      div(classes: 'col-4', [
                        button(
                          type: ButtonType.button,
                          classes: 'btn btn-dark text-white fw-bold py-2.5 w-100 rounded-pill shadow-xs d-flex align-items-center justify-content-center gap-1.5 hover-scale tap-bounce fs-8',
                          attributes: {'style': 'background: linear-gradient(135deg, #222222, #000000); border: none; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);'},
                          events: {'click': (e) => _openSocialAuth('Apple')},
                          [
                            i(classes: 'bi bi-apple fs-6', []),
                            Component.text('Apple ID'),
                          ],
                        ),
                      ]),
                    ]),
                  ]),

                  // Divider (Clear Spacing)
                  div(classes: 'd-flex align-items-center my-4 text-muted', [
                    hr(classes: 'flex-grow-1 border-light-subtle my-0'),
                    span(classes: 'px-3 fs-8 text-uppercase fw-semibold tracking-wider text-muted', [Component.text('atau lengkapi formulir pendaftaran')]),
                    hr(classes: 'flex-grow-1 border-light-subtle my-0'),
                  ]),

                  // Register Form (Spacious Vertical Rhythm)
                  form(
                    events: {
                      'submit': (e) {
                        e.preventDefault();
                        _handleMemberRegister();
                      }
                    },
                    [
                      div(classes: 'row g-3 mb-3.5', [
                        div(classes: 'col-md-6', [
                          label(classes: 'form-label fw-bold text-espresso fs-7 mb-2', [Component.text('Nama Lengkap:')]),
                          div(classes: 'input-group', [
                            span(classes: 'input-group-text border-end-0 text-espresso-muted', attributes: {
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            }, [i(classes: 'bi bi-person text-terracotta', [])]),
                            input(
                              type: InputType.text,
                              classes: 'form-control border-start-0 fs-7 py-2.5',
                              value: regNameInput,
                              attributes: {
                                'placeholder': 'Nama Anda',
                                'required': 'required',
                                'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                              },
                              events: {'input': (e) => regNameInput = (e.target as html.InputElement).value ?? ''},
                            ),
                          ]),
                        ]),
                        div(classes: 'col-md-6', [
                          label(classes: 'form-label fw-bold text-espresso fs-7 mb-2', [Component.text('Alamat Email:')]),
                          div(classes: 'input-group', [
                            span(classes: 'input-group-text border-end-0 text-espresso-muted', attributes: {
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            }, [i(classes: 'bi bi-envelope text-terracotta', [])]),
                            input(
                              type: InputType.email,
                              classes: 'form-control border-start-0 fs-7 py-2.5',
                              value: regEmailInput,
                              attributes: {
                                'placeholder': 'nama@gmail.com',
                                'required': 'required',
                                'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                              },
                              events: {'input': (e) => regEmailInput = (e.target as html.InputElement).value ?? ''},
                            ),
                          ]),
                        ]),
                      ]),

                      div(classes: 'row g-3 mb-3.5', [
                        div(classes: 'col-md-6', [
                          label(classes: 'form-label fw-bold text-espresso fs-7 mb-2', [Component.text('Nomor WhatsApp:')]),
                          div(classes: 'input-group', [
                            span(classes: 'input-group-text border-end-0 text-espresso-muted', attributes: {
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            }, [i(classes: 'bi bi-whatsapp text-success', [])]),
                            input(
                              type: InputType.tel,
                              classes: 'form-control border-start-0 fs-7 py-2.5',
                              value: regPhoneInput,
                              attributes: {
                                'placeholder': '081234567890',
                                'required': 'required',
                                'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                              },
                              events: {'input': (e) => regPhoneInput = (e.target as html.InputElement).value ?? ''},
                            ),
                          ]),
                        ]),
                        div(classes: 'col-md-6', [
                          label(classes: 'form-label fw-bold text-espresso fs-7 mb-2', [Component.text('Password:')]),
                          div(classes: 'input-group', [
                            span(classes: 'input-group-text border-end-0 text-espresso-muted', attributes: {
                              'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                            }, [i(classes: 'bi bi-lock text-terracotta', [])]),
                            input(
                              type: showPassword ? InputType.text : InputType.password,
                              classes: 'form-control border-start-0 fs-7 py-2.5',
                              value: regPasswordInput,
                              attributes: {
                                'placeholder': 'Min. 6 karakter',
                                'required': 'required',
                                'style': 'background: #FAF8F6; border-color: #E6DDD5;',
                              },
                              events: {'input': (e) => regPasswordInput = (e.target as html.InputElement).value ?? ''},
                            ),
                          ]),
                        ]),
                      ]),

                      div(classes: 'form-check mb-4', [
                        input(
                          type: InputType.checkbox,
                          classes: 'form-check-input',
                          id: 'termsCheck',
                          attributes: agreeTerms ? {'checked': 'checked'} : {},
                          events: {'change': (e) => agreeTerms = (e.target as html.InputElement).checked ?? true},
                        ),
                        label(classes: 'form-check-label fs-8 text-espresso-muted', attributes: {'for': 'termsCheck'}, [
                          Component.text('Saya menyetujui Syarat & Ketentuan Keanggotaan Abel\'z Handmade.'),
                        ]),
                      ]),

                      button(
                        type: ButtonType.submit,
                        classes: 'btn btn-terracotta w-100 py-2.5 rounded-pill fw-bold fs-6 shadow-sm d-flex align-items-center justify-content-center gap-2 hover-scale tap-bounce mb-4',
                        attributes: isSubmitting ? {'disabled': 'disabled'} : {},
                        [
                          if (isSubmitting)
                            span(classes: 'spinner-border spinner-border-sm me-1', [])
                          else
                            i(classes: 'bi bi-gift-fill fs-6', []),
                          Component.text('Daftar Member & Klaim 100 Poin 🎁'),
                        ],
                      ),
                    ],
                  ),
                ],

                // Card Footer Switch Action (Spacious)
                div(classes: 'text-center fs-7 text-espresso-muted mb-4', [
                  if (currentMode == 'login')
                    span([
                      Component.text('Belum memiliki akun member? '),
                      a(
                        classes: 'text-terracotta fw-bold text-decoration-none hover-underline',
                        href: '#',
                        events: {
                          'click': (e) {
                            e.preventDefault();
                            setState(() {
                              currentMode = 'register';
                              errorMessage = null;
                              successMessage = null;
                            });
                          }
                        },
                        [Component.text('Daftar Sekarang (+100 Poin)')],
                      ),
                    ])
                  else
                    span([
                      Component.text('Sudah memiliki akun? '),
                      a(
                        classes: 'text-terracotta fw-bold text-decoration-none hover-underline',
                        href: '#',
                        events: {
                          'click': (e) {
                            e.preventDefault();
                            setState(() {
                              currentMode = 'login';
                              errorMessage = null;
                              successMessage = null;
                            });
                          }
                        },
                        [Component.text('Masuk ke Akun Anda')],
                      ),
                    ]),
                ]),

                // Clean Trust & Security Seal (Single border, spacious)
                div(classes: 'text-center text-muted fs-8 pt-3 border-top border-light-subtle d-flex align-items-center justify-content-center gap-2', [
                  i(classes: 'bi bi-shield-check text-success fs-7', []),
                  span(classes: 'fw-semibold text-secondary', [
                    Component.text('Keamanan 256-Bit SSL • Privasi Terlindungi • Abel\'z Official'),
                  ]),
                ]),
              ]),
            ],
          ),
        ]),

        // ==========================================
        // SIMULATED SOCIAL MEDIA OAUTH DIALOG
        // ==========================================
        if (showSocialModal)
          div(classes: 'modal fade show d-block bg-dark bg-opacity-75', attributes: {'tabindex': '-1'}, [
            div(classes: 'modal-dialog modal-dialog-centered', styles: Styles(maxWidth: 420.px), [
              div(classes: 'modal-content border-0 shadow-lg rounded-4 overflow-hidden', [
                div(classes: 'modal-header ${selectedSocialProvider == 'Google' ? 'bg-primary' : selectedSocialProvider == 'Facebook' ? 'bg-primary' : 'bg-dark'} text-white py-2.5', [
                  h5(classes: 'modal-title fw-bold fs-7 d-flex align-items-center gap-2', [
                    i(classes: 'bi ${selectedSocialProvider == 'Facebook' ? 'bi-facebook' : selectedSocialProvider == 'Apple' ? 'bi-apple' : 'bi-google'}', []),
                    Component.text('Masuk Cepat dengan $selectedSocialProvider'),
                  ]),
                  button(
                    type: ButtonType.button,
                    classes: 'btn-close btn-close-white',
                    events: {'click': (e) => setState(() => showSocialModal = false)},
                    [],
                  ),
                ]),
                div(classes: 'modal-body p-3 bg-white', [
                  div(classes: 'text-center mb-2.5', [
                    div(classes: 'rounded-circle bg-light d-inline-flex align-items-center justify-content-center p-2.5 mb-1.5 shadow-xs', [
                      span(classes: 'fs-3', [
                        Component.text(selectedSocialProvider == 'Google' ? '🌐' : selectedSocialProvider == 'Facebook' ? '📱' : '🍎'),
                      ]),
                    ]),
                    h6(classes: 'fw-bold text-espresso mb-0.5 fs-7', [
                      Component.text('Hubungkan Akun $selectedSocialProvider'),
                    ]),
                    p(classes: 'fs-9 text-espresso-muted mb-0', [
                      Component.text('Abel\'z Handmade akan menerima nama, email, dan foto profil Anda secara aman.'),
                    ]),
                  ]),

                  div(classes: 'card border border-light-subtle rounded-3 p-2.5 bg-soft-card mb-2.5', [
                    div(classes: 'mb-2', [
                      label(classes: 'form-label fw-bold text-espresso fs-9 mb-1', [Component.text('Nama Pengguna:')]),
                      input(
                        type: InputType.text,
                        classes: 'form-control form-control-sm fs-8',
                        value: customSocialName,
                        events: {'input': (e) => customSocialName = (e.target as html.InputElement).value ?? ''},
                      ),
                    ]),
                    div([
                      label(classes: 'form-label fw-bold text-espresso fs-9 mb-1', [Component.text('Email Terverifikasi:')]),
                      input(
                        type: InputType.email,
                        classes: 'form-control form-control-sm fs-8',
                        value: customSocialEmail,
                        events: {'input': (e) => customSocialEmail = (e.target as html.InputElement).value ?? ''},
                      ),
                    ]),
                  ]),

                  div(classes: 'd-flex align-items-center gap-2 text-success fs-9 mb-3', [
                    i(classes: 'bi bi-check-circle-fill', []),
                    span([Component.text('Otomatis terdaftar sebagai Gold Member (+100 Poin)')]),
                  ]),

                  div(classes: 'd-flex gap-2', [
                    button(
                      type: ButtonType.button,
                      classes: 'btn btn-light rounded-pill flex-grow-1 fs-8 fw-semibold border py-1.5',
                      events: {'click': (e) => setState(() => showSocialModal = false)},
                      [Component.text('Batal')],
                    ),
                    button(
                      type: ButtonType.button,
                      classes: 'btn ${selectedSocialProvider == 'Apple' ? 'btn-dark' : 'btn-primary'} rounded-pill flex-grow-1 fs-8 fw-bold shadow-sm py-1.5',
                      events: {'click': (e) => _confirmSocialLogin()},
                      [
                        i(classes: 'bi bi-check-lg me-1', []),
                        Component.text('Izinkan & Lanjutkan'),
                      ],
                    ),
                  ]),
                ]),
              ]),
            ]),
          ]),
      ],
    );
  }
}

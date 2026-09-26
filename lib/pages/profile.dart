// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulComponent {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String nameInput;
  late String emailInput;
  String currentPassword = '';
  String newPassword = '';
  String? profileSuccessMsg;
  String? passSuccessMsg;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    nameInput = user?.name ?? 'Admin';
    emailInput = user?.email ?? 'admin@ecomes.com';
  }

  void _saveProfile() {
    if (nameInput.trim().isEmpty || emailInput.trim().isEmpty) return;
    AuthService().updateProfile(nameInput.trim(), emailInput.trim(), '');
    setState(() {
      profileSuccessMsg = 'Profil berhasil diperbarui!';
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => profileSuccessMsg = null);
    });
  }

  void _changePassword() {
    if (newPassword.trim().length < 6) return;
    setState(() {
      passSuccessMsg = 'Password berhasil diubah!';
      currentPassword = '';
      newPassword = '';
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => passSuccessMsg = null);
    });
  }

  @override
  Component build(BuildContext context) {
    final user = AuthService().currentUser;
    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A';

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-body-emphasis', [Component.text('Profil Pengguna & Keamanan Sesi')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Manajemen identitas pengelola toko, peranan role, dan kredensial password.')]),
            ]),
          ]),
        ]),
      ]),

      // 2. Profile Details Grid
      div(classes: 'row g-4', [
        // Left Column (Avatar Card)
        div(classes: 'col-lg-4', [
          div(classes: 'card shadow-sm border-0 rounded-4 text-center p-4 bg-body mb-4', [
            div(
              classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold mx-auto mb-3 display-5 shadow-sm',
              styles: Styles(width: 80.px, height: 80.px),
              [Component.text(initial)],
            ),
            h5(classes: 'fw-bold text-body-emphasis mb-1', [Component.text(user?.name ?? 'Admin')]),
            p(classes: 'text-muted fs-7 mb-2', [Component.text(user?.email ?? 'admin@ecomes.com')]),
            span(classes: 'badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1 fs-7 mx-auto', [
              i(classes: 'bi bi-shield-check me-1', []),
              Component.text(user?.role ?? 'Super Admin'),
            ]),
          ]),
        ]),

        // Right Column (Forms)
        div(classes: 'col-lg-8', [
          // Update Profile Info
          div(classes: 'card shadow-sm border-0 rounded-4 p-4 bg-body mb-4', [
            h5(classes: 'fw-bold text-body-emphasis mb-3 border-bottom pb-2', [
              i(classes: 'bi bi-person-gear text-primary me-2', []),
              Component.text('Informasi Personal Administrator'),
            ]),
            if (profileSuccessMsg != null)
              div(classes: 'alert alert-success p-2 mb-3 fs-7 rounded-3', [
                Component.text(profileSuccessMsg!),
              ]),
            form([
              div(classes: 'mb-3', [
                label(classes: 'form-label fw-semibold fs-7', [Component.text('Nama Lengkap')]),
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
              div(classes: 'mb-3', [
                label(classes: 'form-label fw-semibold fs-7', [Component.text('Email Akses Login')]),
                input(
                  type: InputType.email,
                  classes: 'form-control',
                  value: emailInput,
                  events: {
                    'input': (e) {
                      emailInput = (e.target as html.InputElement).value ?? '';
                    }
                  },
                ),
              ]),
              button(
                type: ButtonType.button,
                classes: 'btn btn-primary fw-semibold px-4 rounded-3 shadow-sm',
                events: {'click': (e) => _saveProfile()},
                [
                  i(classes: 'bi bi-check-circle me-1', []),
                  Component.text('Simpan Perubahan Profil'),
                ],
              ),
            ]),
          ]),

          // Change Password Form
          div(classes: 'card shadow-sm border-0 rounded-4 p-4 bg-body', [
            h5(classes: 'fw-bold text-body-emphasis mb-3 border-bottom pb-2', [
              i(classes: 'bi bi-key text-warning me-2', []),
              Component.text('Ganti Password Keamanan'),
            ]),
            if (passSuccessMsg != null)
              div(classes: 'alert alert-success p-2 mb-3 fs-7 rounded-3', [
                Component.text(passSuccessMsg!),
              ]),
            form([
              div(classes: 'mb-3', [
                label(classes: 'form-label fw-semibold fs-7', [Component.text('Password Lama')]),
                input(
                  type: InputType.password,
                  classes: 'form-control',
                  value: currentPassword,
                  events: {
                    'input': (e) {
                      currentPassword = (e.target as html.InputElement).value ?? '';
                    }
                  },
                ),
              ]),
              div(classes: 'mb-3', [
                label(classes: 'form-label fw-semibold fs-7', [Component.text('Password Baru (Minimal 6 karakter)')]),
                input(
                  type: InputType.password,
                  classes: 'form-control',
                  value: newPassword,
                  events: {
                    'input': (e) {
                      newPassword = (e.target as html.InputElement).value ?? '';
                    }
                  },
                ),
              ]),
              button(
                type: ButtonType.button,
                classes: 'btn btn-outline-warning fw-semibold px-4 rounded-3',
                events: {'click': (e) => _changePassword()},
                [
                  i(classes: 'bi bi-shield-lock me-1', []),
                  Component.text('Perbarui Password'),
                ],
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

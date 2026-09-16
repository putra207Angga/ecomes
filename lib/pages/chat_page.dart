// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/app_models.dart';
import '../services/app_store.dart';
import '../services/auth_service.dart';

class ChatPage extends StatefulComponent {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String selectedContactId = 'CUST-001';
  String chatInputText = '';

  void _sendMessage([String? customText]) {
    final textToSend = customText ?? chatInputText;
    if (textToSend.trim().isEmpty) return;
    final store = AppStore();
    final auth = AuthService();

    final newMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactId: selectedContactId,
      sender: auth.currentUser?.name ?? 'Admin Support',
      text: textToSend.trim(),
      time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      isAdmin: true,
    );

    store.addChatMessage(newMsg);
    setState(() {
      chatInputText = '';
    });

    // Simulate real-time customer reply after 1.5s
    Timer(const Duration(milliseconds: 1500), () {
      final customer = store.customers.firstWhere(
        (c) => c.id == selectedContactId,
        orElse: () => CustomerItem(id: 'CUST-001', name: 'Pelanggan', email: '', phone: '', level: 'Regular', totalOrders: 1, totalSpent: 0, avatar: 'P'),
      );

      final replyMsg = ChatMessageItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        contactId: selectedContactId,
        sender: customer.name,
        text: 'Baik Kak ${auth.currentUser?.name ?? 'Admin'}, terima kasih banyak atas bantuan dan penjelasannya! 🙏',
        time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        isAdmin: false,
      );

      store.addChatMessage(replyMsg);
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _useCannedResponse(String text) {
    _sendMessage(text);
  }

  @override
  Component build(BuildContext context) {
    final store = AppStore();
    final customers = store.customers;
    final activeCustomer = customers.firstWhere((c) => c.id == selectedContactId, orElse: () => customers.first);

    final currentChats = store.chatMessages.where((msg) => msg.contactId == selectedContactId).toList();

    return div(classes: 'app-content-wrapper p-3 p-md-4', [
      // 1. Header
      div(classes: 'app-content-header mb-4', [
        div(classes: 'container-fluid', [
          div(classes: 'row align-items-center', [
            div(classes: 'col-sm-6', [
              h3(classes: 'mb-0 fw-bold text-dark', [Component.text('Live Chat & Customer Support')]),
              p(classes: 'text-muted mb-0 fs-7', [Component.text('Layanan pesan instan 1-on-1 dengan pembeli secara real-time.')]),
            ]),
            div(classes: 'col-sm-6 text-sm-end mt-2 mt-sm-0', [
              span(classes: 'badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-2 fs-7', [
                i(classes: 'bi bi-circle-fill me-1 fs-8', []),
                Component.text('Server WebSocket Active'),
              ]),
            ]),
          ]),
        ]),
      ]),

      // 2. Chat Interface Box
      div(classes: 'card shadow-sm border-0 rounded-4 overflow-hidden', [
        div(classes: 'row g-0', [
          // Left Contacts List Sidebar
          div(classes: 'col-md-4 col-lg-3 border-end bg-light', [
            div(classes: 'p-3 bg-white border-bottom', [
              div(classes: 'input-group input-group-sm', [
                span(classes: 'input-group-text bg-light border-end-0', [i(classes: 'bi bi-search', [])]),
                input(
                  type: InputType.text,
                  classes: 'form-control border-start-0',
                  attributes: {'placeholder': 'Cari kontak percakapan...'},
                ),
              ]),
            ]),
            div(classes: 'contacts-list overflow-y-auto', styles: Styles(height: 520.px), [
              for (var c in customers)
                div(
                  classes:
                      'p-3 border-bottom role-button d-flex align-items-center gap-3 transition-all ${c.id == selectedContactId ? 'bg-primary-subtle border-start border-4 border-primary' : 'bg-white hover-bg-light'}',
                  events: {'click': (e) => setState(() => selectedContactId = c.id)},
                  [
                    div(
                      classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7 shadow-sm position-relative',
                      styles: Styles(width: 42.px, height: 42.px),
                      [
                        Component.text(c.avatar),
                        span(classes: 'position-absolute bottom-0 end-0 p-1 bg-success border border-light rounded-circle', []),
                      ],
                    ),
                    div(classes: 'flex-grow-1 overflow-hidden', [
                      div(classes: 'd-flex align-items-center justify-content-between mb-1', [
                        h6(classes: 'fw-bold text-dark mb-0 text-truncate fs-7', [Component.text(c.name)]),
                        small(classes: 'text-muted fs-8', [Component.text('14:20')]),
                      ]),
                      p(classes: 'text-muted fs-8 mb-0 text-truncate', [
                        Component.text(c.level),
                      ]),
                    ]),
                  ],
                ),
            ]),
          ]),

          // Right Chat Window
          div(classes: 'col-md-8 col-lg-9 d-flex flex-column bg-white', [
            // Chat Header
            div(classes: 'p-3 border-bottom d-flex align-items-center justify-content-between bg-white', [
              div(classes: 'd-flex align-items-center gap-3', [
                div(
                  classes: 'bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7',
                  styles: Styles(width: 40.px, height: 40.px),
                  [Component.text(activeCustomer.avatar)],
                ),
                div([
                  h6(classes: 'fw-bold text-dark mb-0 fs-6', [Component.text(activeCustomer.name)]),
                  small(classes: 'text-success fw-semibold fs-8', [
                    i(classes: 'bi bi-dot me-1', []),
                    Component.text('Sedang Online • ${activeCustomer.email}'),
                  ]),
                ]),
              ]),
              button(
                type: ButtonType.button,
                classes: 'btn btn-sm btn-outline-secondary rounded-circle',
                attributes: {'title': 'Info Pelanggan'},
                [i(classes: 'bi bi-info-circle', [])],
              ),
            ]),

            // Messages Container
            div(classes: 'chat-body flex-grow-1 p-4 overflow-y-auto bg-light-subtle', styles: Styles(height: 360.px), [
              if (currentChats.isEmpty)
                p(classes: 'text-muted text-center py-5 fs-7', [Component.text('Belum ada pesan dengan pelanggan ini. Ketik pesan di bawah untuk memulai chat.')])
              else
                for (var msg in currentChats)
                  div(classes: 'mb-3 d-flex flex-column ${msg.isAdmin ? 'align-items-end' : 'align-items-start'}', [
                    div(classes: 'd-flex align-items-center gap-1 mb-1', [
                      span(classes: 'fw-semibold fs-8 text-dark', [Component.text(msg.sender)]),
                      span(classes: 'text-muted fs-8', [Component.text('• ${msg.time}')]),
                    ]),
                    div(
                      classes: 'p-3 rounded-4 fs-7 shadow-sm ${msg.isAdmin ? 'bg-primary text-white rounded-top-right-0' : 'bg-white text-dark border rounded-top-left-0'}',
                      styles: Styles(maxWidth: 70.percent),
                      [Component.text(msg.text)],
                    ),
                  ]),
            ]),

            // Canned Responses Pills & Input Footer
            div(classes: 'p-3 border-top bg-white', [
              // Canned Responses Quick Buttons
              div(classes: 'd-flex flex-wrap gap-1 mb-2', [
                small(classes: 'text-muted me-1 align-self-center fs-8 fw-semibold', [Component.text('Balasan Cepat:')]),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-sm btn-outline-secondary rounded-pill fs-8 py-0 px-2',
                  events: {'click': (e) => _useCannedResponse('Halo kak! Produk ini ready stok ya 😊')},
                  [Component.text('Stok Ready 😊')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-sm btn-outline-secondary rounded-pill fs-8 py-0 px-2',
                  events: {'click': (e) => _useCannedResponse('Pesanan Kakak sedang kami kemas dan siap diserahkan ke kurir.')},
                  [Component.text('Pesanan Dikemas')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-sm btn-outline-secondary rounded-pill fs-8 py-0 px-2',
                  events: {'click': (e) => _useCannedResponse('Nomor resi pengiriman sudah aktif, silakan diacak berkala ya.')},
                  [Component.text('Resi Aktif')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'btn btn-sm btn-outline-secondary rounded-pill fs-8 py-0 px-2',
                  events: {'click': (e) => _useCannedResponse('Terima kasih sudah berbelanja di E-Comes Official Store! 🙏')},
                  [Component.text('Terima Kasih 🙏')],
                ),
              ]),
              form(
                events: {
                  'submit': (e) {
                    e.preventDefault();
                    _sendMessage();
                  }
                },
                [
                  div(classes: 'input-group', [
                    input(
                      type: InputType.text,
                      classes: 'form-control form-control-lg fs-7',
                      value: chatInputText,
                      attributes: {'placeholder': 'Ketik balasan untuk ${activeCustomer.name}...'},
                      events: {
                        'input': (e) {
                          chatInputText = (e.target as html.InputElement).value ?? '';
                        }
                      },
                    ),
                    button(type: ButtonType.submit, classes: 'btn btn-primary px-4 fw-semibold', [
                      i(classes: 'bi bi-send-fill me-1', []),
                      Component.text('Kirim'),
                    ]),
                  ]),
                ],
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

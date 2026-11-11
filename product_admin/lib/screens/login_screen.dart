import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../ui/widgets/retro.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.signIn(_email.text, _password.text);
    } catch (e) {
      if (!mounted) return;
      await showRetroDialog<void>(
        context,
        title: 'Đăng nhập thất bại',
        message: AuthService.messageFor(e),
        kind: DialogKind.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = Retro.isPhone(context);

    final fields = Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nhập email và mật khẩu quản trị viên để đăng nhập KTGK OS.',
              style: Retro.body,
            ),
            const SizedBox(height: 14),
            RetroTextFormField(
              controller: _email,
              label: 'Email:',
              hint: 'admin@ktgk.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autofocus: !phone,
              enabled: !_busy,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Vui lòng nhập email';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 10),
            RetroTextFormField(
              controller: _password,
              label: 'Mật khẩu:',
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !_busy,
              onSubmitted: (_) => _submit(),
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Vui lòng nhập mật khẩu';
                if (v!.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                return null;
              },
            ),
            if (_busy) ...[
              const SizedBox(height: 12),
              const RetroProgressBar(height: 16),
            ],
          ],
        ),
      ),
    );

    final loginButton = RetroButton(
      label: _busy ? 'Đang đăng nhập…' : 'Đăng nhập',
      isDefault: true,
      onPressed: _busy ? null : _submit,
    );

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: phone
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: PixelIcon(PixelIcons.key, size: 40),
                ),
                const SizedBox(height: 8),
                fields,
                const SizedBox(height: 16),
                loginButton,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PixelIcon(PixelIcons.key, size: 40),
                const SizedBox(width: 14),
                Expanded(child: fields),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(width: 120, child: loginButton),
                ),
              ],
            ),
    );

    return DesktopShell(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(child: ChromeText('KTGK OS 2000', size: phone ? 44 : 56)),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Color(0x55000000), offset: Offset(4, 4))],
                  ),
                  child: RetroWindow(
                    title: 'Đăng nhập hệ thống',
                    icon: PixelIcons.key,
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stripe_colors.dart';
import '../application/register_action_notifier.dart';
import 'auth_form_shell.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmationPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    await ref.read(registerActionProvider.notifier).submit(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerActionProvider);

    ref.listen(authSessionProvider, (previous, next) {
      if (!next.isAuthenticated || !mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });

    ref.listen<RegisterActionState>(registerActionProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: StripeColors.errorRuby,
          ),
        );
      }
    });

    return AuthFormShell(
      title: 'Criar conta',
      subtitle: 'Crie sua conta para começar',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nome',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2B2B2D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Seu nome',
                filled: true,
                fillColor: const Color(0xFFEFEFF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) {
                  return 'Indique o nome.';
                }
                if (v.length < 2) {
                  return 'Nome muito curto.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2B2B2D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Johndoe@email.com',
                filled: true,
                fillColor: const Color(0xFFEFEFF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) {
                  return 'Indique o email.';
                }
                if (!v.contains('@')) {
                  return 'Email inválido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Senha',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2B2B2D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '******',
                filled: true,
                fillColor: const Color(0xFFEFEFF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                final v = value ?? '';
                if (v.isEmpty) {
                  return 'Informe a senha.';
                }
                if (v.length < 8) {
                  return 'Use no mínimo 8 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            _PasswordRule(
              label: 'Mínimo de 8 caracteres',
              isValid: _passwordController.text.length >= 8,
            ),
            _PasswordRule(
              label: 'Pelo menos 1 número (0-9)',
              isValid: RegExp(r'[0-9]').hasMatch(_passwordController.text),
            ),
            _PasswordRule(
              label: 'Pelo menos 1 letra',
              isValid: RegExp(r'[A-Za-z]').hasMatch(_passwordController.text),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirmar senha',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2B2B2D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordConfirmationController,
              obscureText: _hideConfirmationPassword,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) => _onSubmit(),
              decoration: InputDecoration(
                hintText: '******',
                filled: true,
                fillColor: const Color(0xFFEFEFF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _hideConfirmationPassword = !_hideConfirmationPassword;
                    });
                  },
                  icon: Icon(
                    _hideConfirmationPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme a senha.';
                }
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem.';
                }
                return null;
              },
            ),
            if (registerState.errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                registerState.errorMessage!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: StripeColors.errorRuby,
                  height: 1.35,
                  fontFeatures: AppTheme.ss01,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D1D1F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: registerState.isLoading ? null : _onSubmit,
                child: registerState.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: StripeColors.surface,
                        ),
                      )
                    : const Text('Cadastrar'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Já tem conta? ',
                  style: TextStyle(color: Color(0xFF8A8A8D)),
                ),
                GestureDetector(
                  onTap: registerState.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ao clicar em Cadastrar, você concorda com nossos Termos e Política de Dados.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8A8A8D),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordRule extends StatelessWidget {
  const _PasswordRule({
    required this.label,
    required this.isValid,
  });

  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? const Color(0xFF6C4DE6) : const Color(0xFFE05A5A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isValid ? Icons.check : Icons.close, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

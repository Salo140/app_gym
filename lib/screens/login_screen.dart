import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final ValueChanged<BuildContext> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) widget.onLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ContentShell(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.fade(AppColors.primary, 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.fade(AppColors.primary, 0.32),
                      ),
                    ),
                    child: const Icon(
                      Symbols.fitness_center,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('GymMate', style: AppText.headlineLg()),
                  const SizedBox(height: 6),
                  Text(
                    _isRegistering
                        ? 'Crea tu cuenta y empieza a avanzar.'
                        : 'Tu entrenamiento, a tu ritmo.',
                    style: AppText.bodyMd(),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Symbols.mail),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Symbols.lock),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Symbols.visibility
                              : Symbols.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) => (value?.length ?? 0) < 6
                        ? 'Usa al menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isRegistering ? 'Crear cuenta' : 'Iniciar sesión',
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => setState(
                      () => _isRegistering = !_isRegistering,
                    ),
                    child: Text(
                      _isRegistering
                          ? 'Ya tengo una cuenta · Iniciar sesión'
                          : '¿Primera vez en GymMate? · Crear cuenta',
                      textAlign: TextAlign.center,
                      style: AppText.bodySm(color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Contenido de entrenamiento y alimentación con enfoque '
                    'educativo. No sustituye la orientación profesional.',
                    textAlign: TextAlign.center,
                    style: AppText.bodySm(size: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
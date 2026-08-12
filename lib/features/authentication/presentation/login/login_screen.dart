import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/authentication_card.dart';
import '../../widgets/authentication_header.dart';
import '../../widgets/fluent_text_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../../../theme/app_spacing.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
          data: (_) {
            if (!authState.isLoading && !state.hasError) {
              context.go('/dashboard');
            }
          },
        );
      },
    );

    return Scaffold(
      body: AuthenticationCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthenticationHeader(
                title: 'Welcome Back',
                subtitle: 'Continue building your consistency.',
              ),
              FluentTextField(
                label: 'Email',
                hint: 'name@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              PasswordField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              PrimaryButton(
                text: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: _onLogin,
              ),
              const SizedBox(height: AppSpacing.s16),
              SecondaryButton(
                text: 'Create Account',
                onPressed: () => context.push('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

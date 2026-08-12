import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/authentication_card.dart';
import '../../widgets/authentication_header.dart';
import '../../widgets/fluent_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../../../theme/app_spacing.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).forgotPassword(
            _emailController.text.trim(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent.')),
              );
              context.pop();
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
                title: 'Forgot Password',
                subtitle: 'Enter your email to receive a reset link.',
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
              const SizedBox(height: AppSpacing.s32),
              PrimaryButton(
                text: 'Send Reset Link',
                isLoading: authState.isLoading,
                onPressed: _onSendResetLink,
              ),
              const SizedBox(height: AppSpacing.s16),
              SecondaryButton(
                text: 'Back to Login',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

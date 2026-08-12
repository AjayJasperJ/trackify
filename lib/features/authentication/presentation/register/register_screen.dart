import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackify/features/authentication/presentation/widgets/dicebear_avatar_picker.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/authentication_card.dart';
import '../../widgets/authentication_header.dart';
import '../../widgets/fluent_text_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../../../theme/app_spacing.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authControllerProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
            phone: _phoneController.text.trim(),
            image: _imageUrlController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (!authState.isLoading && !state.hasError) {
            context.go('/dashboard');
          }
        },
      );
    });

    return Scaffold(
      body: AuthenticationCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthenticationHeader(
                title: 'Create Account',
                subtitle: 'Start your journey with us today.',
              ),
              FluentTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
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
              FluentTextField(
                label: 'Phone Number (Optional)',
                hint: '+1 234 567 8900',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.s16),
              DicebearAvatarPicker(
                initialSeed: 'trackify_user',
                onAvatarChanged: (url) {
                  _imageUrlController.text = url;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              PasswordField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Minimum 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              PasswordField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s32),
              PrimaryButton(
                text: 'Register',
                isLoading: authState.isLoading,
                onPressed: _onRegister,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/authentication_card.dart';
import '../../widgets/authentication_header.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../../../theme/app_spacing.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdatePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).updatePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
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
                const SnackBar(content: Text('Password updated successfully.')),
              );
              context.pop();
            }
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AuthenticationCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthenticationHeader(
                title: 'Update Password',
                subtitle: 'Please enter your current password to continue.',
              ),
              PasswordField(
                label: 'Current Password',
                hint: 'Enter your current password',
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              PasswordField(
                label: 'New Password',
                hint: 'Enter your new password',
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 8) {
                    return 'Minimum 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              PasswordField(
                label: 'Confirm New Password',
                hint: 'Confirm your new password',
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s32),
              PrimaryButton(
                text: 'Update Password',
                isLoading: authState.isLoading,
                onPressed: _onUpdatePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

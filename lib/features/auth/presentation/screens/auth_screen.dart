import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../router/route_names.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<AuthProvider>().submitEmailAuth(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(RouteNames.root, (_) => false);
  }

  Future<void> _signInWithGoogle() async {
    final success = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted || !success) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(RouteNames.root, (_) => false);
  }

  Future<void> _continueAsGuest() async {
    final success = await context.read<AuthProvider>().continueAsGuest();
    if (!mounted || !success) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(RouteNames.root, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final isSignIn = authProvider.authMode == AuthMode.signIn;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    isSignIn ? 'Sign in to continue' : 'Create your account',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isSignIn
                        ? 'Only Firebase Auth users can enter through email login now.'
                        : 'Create a real Firebase account before entering the app.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<AuthMode>(
                    segments: const [
                      ButtonSegment<AuthMode>(
                        value: AuthMode.signIn,
                        label: Text('Sign in'),
                      ),
                      ButtonSegment<AuthMode>(
                        value: AuthMode.signUp,
                        label: Text('Sign up'),
                      ),
                    ],
                    selected: {authProvider.authMode},
                    onSelectionChanged: (selection) {
                      context.read<AuthProvider>().setAuthMode(selection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  _AuthField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Enter your email';
                      }
                      if (!email.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _AuthField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: (value) {
                      final password = value ?? '';
                      if (password.isEmpty) {
                        return 'Enter your password';
                      }
                      if (password.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: const Color(0xFFFFF1F2),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          authProvider.errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: authProvider.isBusy ? null : _submitEmailAuth,
                      child: Text(
                        authProvider.isBusy
                            ? 'Please wait...'
                            : isSignIn
                            ? 'Continue with email'
                            : 'Create account',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: authProvider.isBusy ? null : _signInWithGoogle,
                    icon: const Icon(Icons.account_circle_outlined),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: authProvider.isBusy ? null : _continueAsGuest,
                    child: const Text('Continue as guest'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: (_) => context.read<AuthProvider>().clearError(),
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}

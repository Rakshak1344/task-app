import 'package:app/features/auth/views/states/login_state.dart';
import 'package:app/features/auth/views/validators/validators.dart';
import 'package:app/navigation/app_route_name.dart';
import 'package:app/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void listenLoginState() {
    ref.listen(loginStateProvider, (previous, next) {
      if (previous?.isLoading != true) {
        return;
      }

      if (next.hasError && next.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                "Failed to log in.\n${next.error}",
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        return;
      }

      if (next.hasValue) {
        context.goNamed(AppRouteName.root);
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref
        .read(loginStateProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    listenLoginState();

    final isLoading = ref.watch(loginStateProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Welcome back",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      key: K.auth.emailEntry,
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: K.auth.passwordEntry,
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                      validator: AuthValidators.password,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 32),
                    Visibility(
                      visible: isLoading,
                      replacement: ElevatedButton(
                        key: K.auth.loginButton,
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Log in"),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: K.auth.createAccountButton,

                      /// Pushed rather than replaced, so the back gesture
                      /// returns here without signup needing its own link back.
                      onPressed: isLoading
                          ? null
                          : () =>
                                context.pushNamed(AppRouteName.auth.signup),
                      child: const Text("Don't have an account? Create account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

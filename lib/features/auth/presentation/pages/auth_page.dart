import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _name = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _name.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'أهلًا بك في محفظتي',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سجّل دخولك أو أنشئ حسابًا لتبدأ تتبع مصروفاتك.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          const TabBar(
                            tabs: [
                              Tab(text: 'تسجيل الدخول'),
                              Tab(text: 'إنشاء حساب'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 350,
                            child: TabBarView(
                              children: [
                                _buildLoginForm(context),
                                _buildRegisterForm(context),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'أو',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.read<AuthCubit>().signInWithGoogle(),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('المتابعة باستخدام Google'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Form(
          key: _loginKey,
          child: Column(
            children: [
              AppTextField(
                controller: _loginEmail,
                label: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _loginPassword,
                label: 'كلمة المرور',
                obscureText: true,
                validator: _passwordValidator,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'دخول',
                icon: Icons.login_rounded,
                isLoading: state.status == AuthStatus.loading,
                onPressed: () {
                  if (_loginKey.currentState!.validate()) {
                    context.read<AuthCubit>().login(
                          email: _loginEmail.text.trim(),
                          password: _loginPassword.text.trim(),
                        );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Form(
          key: _registerKey,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'الاسم',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _registerEmail,
                label: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _registerPassword,
                label: 'كلمة المرور',
                obscureText: true,
                validator: _passwordValidator,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'إنشاء حساب',
                icon: Icons.person_add_alt_1_rounded,
                isLoading: state.status == AuthStatus.loading,
                onPressed: () {
                  if (_registerKey.currentState!.validate()) {
                    context.read<AuthCubit>().register(
                          name: _name.text.trim(),
                          email: _registerEmail.text.trim(),
                          password: _registerPassword.text.trim(),
                        );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
}

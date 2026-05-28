import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool rememberMe = false;

  void doLogin() {
    context.read<AuthBloc>().add(
      SignInEvent(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        bool isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.authBackground,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textDark),
                        onPressed: () {
                           // Exit or pop
                        },
                        style: IconButton.styleFrom(backgroundColor: AppColors.authBackground, padding: const EdgeInsets.all(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Log in", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    const Text(
                      "Enter your email and password to securely access your account and manage your services.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    
                    // Email Input
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textDark),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Input
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textDark),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textDark),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Options row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (val) => setState(() => rememberMe = val ?? false),
                              activeColor: AppColors.authPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            const Text("Remember me", style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Text("Forgot Password", style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Login Button
                    isLoading 
                        ? const CircularProgressIndicator(color: AppColors.authPrimary)
                        : ElevatedButton(
                            onPressed: doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.authPrimary,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 24),
                    
                    // Sign up link
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppColors.textLight, fontSize: 13),
                          children: [
                            TextSpan(text: "Sign Up here", style: TextStyle(color: AppColors.authPrimary, fontWeight: FontWeight.bold)),
                          ]
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.inputFill, thickness: 2)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Or Continue With Account", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ),
                        const Expanded(child: Divider(color: AppColors.inputFill, thickness: 2)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Social Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialBtn(FontAwesomeIcons.facebookF),
                        const SizedBox(width: 16),
                        _buildSocialBtn(FontAwesomeIcons.google, color: Colors.blueAccent),
                        const SizedBox(width: 16),
                        _buildSocialBtn(FontAwesomeIcons.apple),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialBtn(IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, size: 20, color: color ?? AppColors.textDark),
    );
  }
}

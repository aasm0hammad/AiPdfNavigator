import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;

  void doRegister() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }
    
    context.read<AuthBloc>().add(
      SignUpEvent(
        name: nameController.text.trim(),
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
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
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
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(backgroundColor: AppColors.authBackground, padding: const EdgeInsets.all(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    const Text(
                      "Create a new account to get started and enjoy seamless access to our features.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    
                    // Name Input
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.textDark),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

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

                    // Confirm Password Input
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textDark),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textDark),
                          onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                        ),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Register Button
                    isLoading 
                        ? const CircularProgressIndicator(color: AppColors.authPrimary)
                        : ElevatedButton(
                            onPressed: doRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.authPrimary,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 24),
                    
                    // Sign in link
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: AppColors.textLight, fontSize: 13),
                          children: [
                            TextSpan(text: "Sign In here", style: TextStyle(color: AppColors.authPrimary, fontWeight: FontWeight.bold)),
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

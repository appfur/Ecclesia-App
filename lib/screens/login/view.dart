import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

import 'package:go_router/go_router.dart';

import '../../widgets/custom_textfield.dart';
import 'viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 16),
              Text(
                "Login to your account\nto get started",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "e.g jackson@gmail",
                controller: vm.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "Password",
                controller: vm.passwordController,
                obscureText: !vm.showPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    vm.showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: vm.togglePasswordVisibility,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: vm.onForgotPassword,
                  child: const Text(
                    "Forgot password ?",
                    style: TextStyle(color: AppColors.linkColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: vm.isLoading ? null : vm.login,
                //onPressed: vm.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                //child: const Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                child:
                    vm.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: vm.onSignup,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.subtitleColor),
                      children: [
                        TextSpan(text: "Don’t have an account ? "),
                        TextSpan(
                          text: "sign up",
                          style: TextStyle(color: AppColors.linkColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

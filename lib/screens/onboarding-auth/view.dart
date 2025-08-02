import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';

import '../../widgets/round_button.dart';

import '../../widgets/social_button.dart';
import 'viewmodel.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/logo.jpg', height: 120),
                const SizedBox(height: 32),
                const Text(
                  // 'Welcome to the rhythm\nof stories',
                  "Empowering believers with\nkingdom knowledge for God's purpose\nand spiritual maturity.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 32),
                RoundedButton(
                  text: 'Sign up',
                  onPressed: viewModel.onSignUpPressed,
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                SocialButton.google(onPressed: viewModel.onGoogleSignIn),
                const SizedBox(height: 12),
                SocialButton.apple(onPressed: viewModel.onAppleSignIn),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: viewModel.onLoginPressed,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.subtitleColor),
                      children: [
                        TextSpan(text: "Already have an account ? "),
                        TextSpan(
                          text: "Login",
                          style: TextStyle(color: AppColors.linkColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

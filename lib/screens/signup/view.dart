import 'package:flutter/material.dart';
import 'package:myapp/core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';
import 'viewmodel.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => navigatorKey.currentState?.pop(),
                ),
                const SizedBox(height: 16),
                Text(
                  "Create your account\nwith us",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Username",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "Your name",
                  controller: vm.usernameController,
                ),
                const SizedBox(height: 16),
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
                //   const Text("Birthday", style: TextStyle(fontWeight: FontWeight.w500)),
                //   const SizedBox(height: 8),
                /*  Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "MM",
                        controller: vm.monthController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        hintText: "DD",
                        controller: vm.dayController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        hintText: "YYYY",
                        controller: vm.yearController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),*/
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: vm.isLoading ? null : vm.register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    //  padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
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
                            "Sign up",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
                /*    ElevatedButton(
                  onPressed: vm.register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text("Sign up", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}

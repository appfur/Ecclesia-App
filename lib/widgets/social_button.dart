import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String assetPath; // for SVG
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onPressed,
  });

  factory SocialButton.google({required VoidCallback onPressed}) {
    return SocialButton(
      text: 'Sign up with Google',
      assetPath: 'assets/svg/google.svg',
      onPressed: onPressed,
    );
  }

  factory SocialButton.apple({required VoidCallback onPressed}) {
    return SocialButton(
      text: 'Sign up with Apple',
      assetPath: 'assets/svg/apple.svg',
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: SvgPicture.asset(assetPath, width: 24, height: 24),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
      label: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

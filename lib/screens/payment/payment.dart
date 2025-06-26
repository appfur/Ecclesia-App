import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/book_model.dart';
//import '../models/book_model.dart'; // Update this path as needed

class Payment extends StatefulWidget {
  final BookModel book;

  const Payment({super.key, required this.book});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        _triggerPayment();
      }
    });
  }

  void _triggerPayment() {
    final priceInKobo = (widget.book.price * 100).toDouble();

    PaystackFlutter().pay(
      context: context,
      secretKey:
          'sk_live_2f6dd3ed79d52ebb36515870f3185c260fd4ec69', // Replace with your test/live key
      amount: priceInKobo,
      email: user!.email ?? 'fallback@email.com',
      firstName: user!.displayName?.split(" ").first ?? 'First',
      lastName: user!.displayName?.split(" ").last ?? 'Last',
      callbackUrl: 'https://mayorkayedu.com/callback',
      showProgressBar: true,
      currency: Currency.NGN,
      metaData: {
        "product_name": widget.book.title,
        "product_quantity": 1,
        "product_price": widget.book.price,
        "book_id": widget.book.id,
      },
      onSuccess: (paystackCallback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaction Successful: ${paystackCallback.reference}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.push('/paysuccess');
      },
      onCancelled: (paystackCallback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaction Cancelled: ${paystackCallback.reference}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

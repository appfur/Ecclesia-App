import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../shelf/viewmodel.dart';
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

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your email before making a payment. We’ve sent you a verification link.',
          ),
        ),
      );

      // Optionally: pop this screen so user doesn’t stay on payment UI
      Navigator.of(context).pop();
      return;
    }

    // Proceed if verified
    _triggerPayment();
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
      callbackUrl: 'https://ecclesia.com/callback',
      showProgressBar: true,
      currency: Currency.NGN,
      metaData: {
        "product_name": widget.book.title,
        "product_quantity": 1,
        "product_price": widget.book.price,
        "book_id": widget.book.id,
      },
      
        onSuccess: (paystackCallback) async {
      final uid = user!.uid;
      final firestore = FirebaseFirestore.instance;

      try {
        // ✅ 1. Add book to user's library
        await firestore.collection('users').doc(uid).collection('library').doc(widget.book.id).set({
          ...widget.book.toMap(),
          'added_at': FieldValue.serverTimestamp(),
        });

        // ✅ 2. Mark book as purchased
        await firestore.collection('users').doc(uid).collection('purchases').doc(widget.book.id).set({
          'price': widget.book.price,
          'purchased_at': FieldValue.serverTimestamp(),
          'reference': paystackCallback.reference,
        });
await FirebaseFirestore.instance
    .collection('notifications')
    .doc('users')
    .collection(user!.uid)
    .add({
  'title': 'Book Purchased',
  'body': 'You successfully bought "${widget.book.title}".',
  'timestamp': FieldValue.serverTimestamp(),
  'isGeneral': false,
});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Payment Successful: ${paystackCallback.reference}',
            ),
            backgroundColor: Colors.green,
          ),
        );
context.read<LibraryViewModel>().loadLibrary();

        // Navigate to success screen or library
        context.push('/paysuccess');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Failed to save book after payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
      onCancelled: (paystackCallback) async {
        await FirebaseFirestore.instance
  .collection('notifications')
  .doc('users')
  .collection(user!.uid)
  .add({
    'title': 'Payment Cancelled',
    'body': 'You cancelled payment for "${widget.book.title}". You can complete it anytime.',
    'timestamp': FieldValue.serverTimestamp(),
    'isGeneral': false,
  });

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

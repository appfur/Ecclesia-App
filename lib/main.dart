import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/screens/login/view.dart';
import 'package:myapp/screens/onboarding-auth/view.dart';
import 'package:myapp/seeds/book_prices.dart';
import 'package:provider/provider.dart';

import 'core/maps/global.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_service.dart';
import 'firebase_options.dart';
import 'screens/account/viewmodel.dart';
import 'screens/auth_success/viewmodel.dart';
import 'screens/home/viewmodel.dart';
import 'screens/login/viewmodel.dart';
import 'screens/notification/viewmodel.dart';
import 'screens/onboarding-auth/viewmodel.dart';
import 'screens/search/viewmodel.dart';
import 'screens/signup/viewmodel.dart';
import 'seeds/author_seed.dart';
import 'seeds/book_content_seed.dart';
import 'seeds/firebase_seed.dart';
import 'widgets/custom_nav_bar/viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await supabase.Supabase.initialize(
    // url: 'https://your-project-id.supabase.co',
    url: 'https://qajukiladobrxjvyrkuw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhanVraWxhZG9icnhqdnlya3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwNzkwMDksImV4cCI6MjA2NTY1NTAwOX0.A8sqMIbIf2mXMlGxdRzs3gtBQTK2VbHt6gMcAVwrOl4',
  );
  // Optional: Seed functions (uncomment if needed)
  // await seedFirestoreLibrary();
  // seedAuthors();
  // await notificationDBSeed();
  // await seedBookContent();
  //await seedBookPrices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = AuthStateNotifier();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(
          create: (_) => LibraryViewModel()..fetchCategories(),
        ),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => NavViewModel()),
        ChangeNotifierProvider(create: (_) => CountdownViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider.value(value: authNotifier),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          final user = snapshot.data;

          final app = MaterialApp.router(
            title: 'Ecclesia Library',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            routerConfig: AppRouter.router,
          );

          if (user != null) {
            return MultiProvider(
              providers: [
                //  ChangeNotifierProvider(create: (_) => NavViewModel()),
                ChangeNotifierProvider(create: (_) => AccountViewModel()),
                ChangeNotifierProvider(
                  create: (_) => NotificationsViewModel(uid: user.uid),
                ),
              ],
              child: app,
            );
          } else {
            return app;
          }
        },
      ),
    );
  }

  //TODO:TO RUN UPDATE NAME , ICONS AND SPLASH AND ALSO sharing url , paystack callback
}
//TODO:

//pythonize
//https://chatgpt.com/c/684ce63f-1158-8012-986b-7df542a3ae47

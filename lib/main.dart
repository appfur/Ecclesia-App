import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/screens/login/view.dart';
import 'package:myapp/screens/onboarding-auth/view.dart';
import 'package:myapp/seeds/book_id_injection_to_books_chaper.dart';
import 'package:myapp/seeds/book_prices.dart';
import 'package:myapp/seeds/category_id_injection.dart';
import 'package:myapp/seeds/long_paragraph.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'screens/shelf/view.dart';
import 'screens/shelf/viewmodel.dart';
import 'screens/signup/viewmodel.dart';
import 'seeds/author_seed.dart';
import 'seeds/book_content_seed.dart';
import 'seeds/firebase_seed.dart';
import 'widgets/custom_nav_bar/viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await supabase.Supabase.initialize(
    // url: 'https://your-project-id.supabase.co',
    url: 'https://qajukiladobrxjvyrkuw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhanVraWxhZG9icnhqdnlya3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwNzkwMDksImV4cCI6MjA2NTY1NTAwOX0.A8sqMIbIf2mXMlGxdRzs3gtBQTK2VbHt6gMcAVwrOl4',
  );
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults(const {
    'livekey': 'sk_test_967cbe6350052f0d81559d38f0b264b435e35ded',
  });

  await remoteConfig.fetchAndActivate();

  // Optional: Seed functions (uncomment if needed)
  // await seedFirestoreLibrary();
  // seedAuthors();
  // await notificationDBSeed();
  // await seedBookContent();
  //await seedBookPrices();
  //injectCategoryIdsToBooks();
  // patchChaptersWithBookId();
  // patchChaptersWithBookId();
  // seedBookText();
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
          create: (_) => HomeViewModel()..fetchCategories(),
        ),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => NavViewModel()),
        ChangeNotifierProvider(create: (_) => CountdownViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),

        //  ChangeNotifierProvider(create: (_) => AccountViewModel()),

        // ChangeNotifierProvider(create: (_) => LibraryViewModel()),
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
                ChangeNotifierProvider(
                  create:
                      (_) => LibraryViewModel(
                        firestore: FirebaseFirestore.instance,
                        //prefs: await SharedPreferences.getInstance(), // if async, use FutureProvider
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      )..loadLibrary(), // optionally call method on init
                  child: LibraryScreen(),
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

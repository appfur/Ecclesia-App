import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/maps/global.dart';
import 'package:myapp/screens/Book_Detail_Now/view2.dart';
import 'package:myapp/screens/account/change_username.dart';
import 'package:myapp/screens/account/forgot_password.dart';
import 'package:myapp/screens/account/report.dart';
import 'package:myapp/screens/home/view.dart';
import 'package:myapp/screens/payment/payment.dart';
import 'package:myapp/screens/payment/success.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/book_model.dart';
//import '../../screens/Book_Detail/view.dart';
import '../../screens/Book_Detail_Now/viewmodel.dart';
import '../../screens/ONBOARDING/view.dart';
import '../../screens/Reader/view.dart';
import '../../screens/account/change_email.dart';
import '../../screens/account/change_password.dart';
import '../../screens/account/view.dart';
import '../../screens/auth_success/view.dart';
//import '../../screens/book_reader.dart';
import '../../screens/category_detail/view.dart';
import '../../screens/login/view.dart';
import '../../screens/notification/view.dart';
import '../../screens/onboarding-auth/view.dart';
import '../../screens/openbook/view.dart';
import '../../screens/openbook/viewmodel.dart';
import '../../screens/search/view.dart';
import '../../screens/shelf/view.dart';
import '../../screens/signup/view.dart';
import '../../screens/verify_mail/view.dart';
import '../../widgets/custom_nav_bar/view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/*class AppRoute {
  static GoRouter router(User? user) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = user != null;
        final isOnAuth =
            state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/signup') ||
            state.matchedLocation == '/';

        if (!isLoggedIn && !isOnAuth) return '/';
        if (isLoggedIn && isOnAuth) return '/home';

        return null;
      },

      // ✅ FIXED HERE
      routes: [
        GoRoute(path: '/', builder: (context, state) => const OnboardingView()),
        GoRoute(path: '/login', builder: (context, state) => const LoginView()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupView(),
        ),
        GoRoute(
          path: '/acc-success',
          builder: (context, state) => const SuccessScreen(),
        ),

        // ✅ ShellRoute with nested routes
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(body: child, bottomNavigationBar: CustomNavBar());
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const LibraryScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => SearchScreen(),
            ),
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
        
            GoRoute(
  path: '/notification',
  builder: (context, state) {
    final user = FirebaseAuth.instance.currentUser!;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotificationsViewModel()),
        ),
       //  ChangeNotifierProvider(
      //    create: (_) => NotificationsViewModel(user.uid)..loadNotifications(),
      //  ),
        // Add other view models here if needed:
        // ChangeNotifierProvider(create: (_) => SomeOtherViewModel()),
      ],
      child: const NotificationsScreen(),
    );
  },
),

          ],
        ),

        GoRoute(
          path: '/category/:id',
          builder: (context, state) {
            final categoryId = state.pathParameters['id']!;
            final title = state.extra as String;
            return CategoryDetailScreen(categoryId: categoryId, title: title);
          },
        ),
        GoRoute(
          path: '/book/:id',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            final book = state.extra as BookModel;
            return BookDetailScreen(book: book);
          },
        ),
      ],
    );
  }
}

*/

class AppRouter {
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    // refreshListenable: Provider.of<AuthStateNotifier>(context, listen: false),
    refreshListenable: authNotifier, // ✅ no context needed
    // refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    /*redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      // Unauthenticated → send to onboarding
      if (!loggedIn && state.fullPath != '/') {
        return '/';
      }

      // Already logged in → block access to auth pages
      if (loggedIn && (state.matchedLocation == '/' || loggingIn)) {
        return '/home';
      }

      return null; // allow default nav
    },*/
    /* redirect: (context, state) {
  final loggedIn = authNotifier.isLoggedIn;
  final goingToLogin = state.matchedLocation == '/login';
  final goingToSignup = state.matchedLocation == '/signup';
  final onboarding = state.matchedLocation == '/';

  // 🔐 NOT logged in
  if (!loggedIn) {
    if (!onboarding && !goingToLogin && !goingToSignup) {
      return '/'; // force to onboarding if trying to access anything else
    }
  }

  // ✅ Already logged in
  if (loggedIn && (onboarding || goingToLogin || goingToSignup)) {
    return '/home'; // block auth screens for logged in user
  }

  return null; // no redirect
},*/
    redirect: (context, state) async {
      final isLoading = authNotifier.isLoading;
      final loggedIn = authNotifier.isLoggedIn;
      final subloc = state.matchedLocation;

      // Intro screen logic
      final prefs = await SharedPreferences.getInstance();
      final introSeen = prefs.getBool('introSeen') ?? false;
      final isAtIntro = subloc == '/intro';

      // Auth-related routes
      final isAtAuth = {
        '/',
        '/login',
        '/signup',
        '/forgot-password',
      }.contains(subloc);

      // ⏳ Wait for Firebase to finish initializing
      if (isLoading) return null;

      // 🟪 Show intro only once
      if (!introSeen) {
        if (!isAtIntro) return '/intro';
        return null; // already on /intro, stay here
      }

      // 🔐 Not logged in → allow only auth routes
      if (!loggedIn && !isAtAuth) {
        return '/';
      }

      // ✅ Logged in → block access to auth routes
      if (loggedIn && isAtAuth) {
        return '/home';
      }

      return null; // no redirect needed
    },

    routes: [
      // ✅ Standalone routes first
      GoRoute(path: '/', builder: (context, state) => const OnboardingView()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/intro',
        builder:
            (context, state) =>
                const OnboardingScreen(), // Your Christian-style screen
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupView()),
      GoRoute(
        path: '/acc-success',
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/change-username',
        builder: (context, state) => const ChangeUsernameScreen(),
      ),
      GoRoute(
        path: '/change-email',
        builder: (context, state) => const ChangeEmailScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      GoRoute(
        path: '/report-issue',
        builder: (context, state) => const ReportIssueScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/category/:id',
        builder: (context, state) {
          final categoryId = state.pathParameters['id']!;
          final title = state.extra as String;
          return CategoryDetailScreen(categoryId: categoryId, title: title);
        },
      ),

      // GoRoute(
      //name: 'reader',
      // path: '/reader', // 🚫 No path parameters here
      // builder: (context, state) {
      //   final book = state.extra as BookModel;
      //   return ReaderScreen(book: book);
      // },
      //),

      /*GoRoute(
  path: '/reader/:bookId',
  name: 'reader',
  builder: (context, state) {
    final book = state.extra;
    if (book == null || book is! BookModel) {
      return const Scaffold(
        body: Center(child: Text("❌ Book data missing.")),
      );
    }

    return ReaderScreen(book: book);
  },
),*/
      GoRoute(
        path: '/reader/:bookId',
        name: 'reader',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return ChangeNotifierProvider(
            create: (_) => ReaderViewModel(bookId)..init(),
            child: const ReaderScreen(),
          );
        },
      ),

      /* GoRoute(
  path: '/reader/:bookId',
  name: 'reader',
  builder: (context, state) {
    final book = state.extra as BookModel; // ⬅️ You still get the whole book
    final bookId = state.pathParameters['bookId']; // optional, for validation
      return ReaderScreen(book: book);

  //  return BookReaderScreen(book: book, bookId: '$bookId',);
  },
),*/

      /*  GoRoute(oRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

        path: '/book/:i',
        name: 'book_deta',
        builder: (context, state) {
          final book = state.extra as BookModel?;
          final bookId = state.pathParameters['id']!;

          // if `extra` is passed (normal in-app nav), use that
          if (book != null) {
            return BookDetailScreen(book: book);
          }

          // if deep link from outside app, fetch book by ID
          return FutureBuilder<BookModel>(
            future: BookDetailViewModel.fetchBookById(bookId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return BookDetailScreen(book: snapshot.data!);
            },
          );
        },
      ),

*/
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/payment-success',
        name: 'paymentSuccess',
        builder: (context, state) {
          final bookId = (state.extra as Map)['bookId'] as String;
          return PaymentSuccessScreen(bookId: bookId);
        },
      ),

      GoRoute(
        path: '/pay',
        builder: (context, state) {
          final book = state.extra as BookModel;
          return Payment(book: book);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),

      GoRoute(
        path: '/book/:id',
        name: 'bookDetail',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          final bookExtra = state.extra;

          // If coming from in-app navigation, use passed BookModel
          if (bookExtra is BookModel) {
            return BookDetailScreen(book: bookExtra);
          }

          // If coming from deep link or refresh, fetch from Firestore
          return FutureBuilder<BookModel>(
            future: BookDetailViewModel.fetchBookById(bookId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: Text('Book not found')),
                );
              }

              return BookDetailScreen(book: snapshot.data!);
            },
          );
        },
      ),

      /*   
GoRoute(
  path: '/book/:id',
  name: 'book_detail',
  builder: (context, state) {
    final book = state.extra as BookModel?;
    final bookId = state.pathParameters['id'];

    if (book != null) {
      return ChangeNotifierProvider(
        create: (_) => BookDetailViewModel(book: book),
        child: BookDetailScreen(book: book),
      );
    }

    if (bookId == null || bookId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Missing book ID')),
      );
    }

    return FutureBuilder<BookModel>(
      future: BookDetailViewModel.fetchBookById(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Book not found')),
          );
        }

        final fetchedBook = snapshot.data!;
        return ChangeNotifierProvider(
          create: (_) => BookDetailViewModel(book: fetchedBook),
          child: BookDetailScreen(book: fetchedBook),
        );
      },
    );
  },
),
*/

      /* GoRoute(
          path: '/book/:id',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            final book = state.extra as BookModel;
            return BookDetailScreen(book: book);
          },
        ),
*/
      // ✅ ShellRoute with nested routes
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(body: child, bottomNavigationBar: CustomNavBar());
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(path: '/search', builder: (context, state) => SearchScreen()),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/notification',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}

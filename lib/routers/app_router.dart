import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ims_scanner_app/features/authentication/presentation/providers/auth_controller.dart';
import 'package:ims_scanner_app/features/authentication/screens/login/login.dart';
import 'package:ims_scanner_app/features/authentication/screens/network_config/url_screen.dart';
import 'package:ims_scanner_app/features/authentication/presentation/providers/auth_state.dart';
import 'package:ims_scanner_app/features/authentication/screens/splash/splash.dart';
import 'package:ims_scanner_app/features/authentication/screens/settings/settings.dart';
import 'package:ims_scanner_app/features/coldstorage/dashboard/presentation/screens/dashboard.dart';
import 'package:ims_scanner_app/features/coldstorage/modules/receiving/presentation/screens/receiving_screen.dart';
import 'package:ims_scanner_app/features/home/home.dart';
import 'package:ims_scanner_app/routers/app_route_paths.dart';
 
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);

  ref.listen<AuthState>(authControllerProvider, (_, __) {
    refresh.value++;
  }); 
  return GoRouter(
    refreshListenable: refresh,
    initialLocation: AppRoutePaths.splash,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final path = state.matchedLocation;
      final isLogin = path == AppRoutePaths.login;
      final isNetwork = path == AppRoutePaths.networkConfig;
      final isSplash = path == AppRoutePaths.splash;

      if (auth.status == AuthStatus.loading) return null;
      if (!auth.isAuthenticated) {
        if (isLogin || isNetwork) return null;
        return AppRoutePaths.login;
      }
      if (auth.isAuthenticated && (isLogin || isSplash)) return AppRoutePaths.home;
      return null;
    },
        routes: [ 
            GoRoute(
              path: AppRoutePaths.splash,
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: AppRoutePaths.login,
              builder: (context, state) => LoginScreen(),
            ),
            // GoRoute( path: AppRoutePaths.signup, builder: (context, state) { return BlocProvider(  create: (_) => SignupBloc(LaravelService(), Isar.getInstance()!), child: const SignUpScreen(), ); }, ),
            // GoRoute( path: AppRoutePaths.verifyEmail, builder: (context, state) => VerifyEmailScreen()),
            // GoRoute( path: AppRoutePaths.signupSuccess, builder: (context, state) {
            //             final data = state.extra as Map<String, dynamic>;
            //             return SignupSuccessScreen(
            //               image: data['image'],
            //               title: data['title'],
            //               subtitle: data['subtitle'],
            //               nextRoute: data['nextRoute'],
            //             );
            //           },
            //         ),
            // GoRoute( path: AppRoutePaths.forgotPassword, builder: (context, state) => ForgetPasswordScreen()),
            //  GoRoute( path: AppRoutePaths.verifyResetPassword, builder: (context, state) => ResetPasswordScreen()),
            // GoRoute( path: AppRoutePaths.navigationMenu, builder: (context, state) => NavigationMenuScreen()),
            GoRoute(path: AppRoutePaths.home, builder: (context, state) => HomeScreen()),
            GoRoute(path: AppRoutePaths.dashboard, builder: (context, state) => const Dashboard()),
            GoRoute(path: AppRoutePaths.settings, builder: (context, state) => const SettingScreen()),
            GoRoute(path: AppRoutePaths.receiving, builder: (context, state) => const ReceivingScreen()),
            GoRoute(path: AppRoutePaths.networkConfig, builder: (context, state) => const UrlScreen()),
        ],
      );
  });  

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../navigation/main_screen.dart';
import '../../features/bot_management/presentation/screens/connect_bot_screen.dart';
import '../supabase/supabase_client.dart';
import '../../features/catalog/presentation/screens/bot_detail_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/language_screen.dart';
import '../../features/settings/presentation/screens/notifications_screen.dart';
import '../../features/bot_management/presentation/screens/bot_management_screen.dart';
import '../../features/bot_management/domain/business.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final notifier = _AuthNotifier(supabase);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = supabase.auth.currentSession != null;
      final location = state.matchedLocation;

      final isProtectedRoute =
          location.startsWith('/profile') | location.startsWith('/payment') ||
              location.startsWith('/connect-bot') ||
              location.startsWith('/bot-management');

      final isAuthRoute = location == '/auth';

      if (!isLoggedIn && isProtectedRoute) {
        return '/auth';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ProfileScreen(currentEmail: email);
        },
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      // Обновленный маршрут: принимаем категорию из URL
      GoRoute(
        path: '/bot-detail/:category',
        builder: (context, state) => BotDetailScreen(
          category: state.pathParameters['category']!,
        ),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentScreen(
            botId: extra['botId'] as String,
            botName: extra['botName'] as String,
            botDescription: extra['botDescription'] as String,
            priceMonthly: extra['priceMonthly'] as double,
            priceYearly: extra['priceYearly'] as double,
          );
        },
      ),
      GoRoute(
        path: '/connect-bot/:botId/:botName',
        builder: (context, state) => ConnectBotScreen(
          botId: state.pathParameters['botId']!,
          botName: state.pathParameters['botName']!,
        ),
      ),
      GoRoute(
        path: '/bot-management/:botId',
        builder: (context, state) => BotManagementScreen(
          business: state.extra as Business,
        ),
      ),
    ],
  );
});

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(SupabaseClient supabase) {
    supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbird/state/game_session_controller.dart';
import 'package:superbird/ui/screens/home_screen.dart';
import 'package:superbird/ui/screens/shop_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // App still runs with local leaderboard when Firebase is not configured.
  }
  final controller = GameSessionController();
  await controller.load();
  runApp(SuperbirdApp(controller: controller));
}

class SuperbirdApp extends StatelessWidget {
  const SuperbirdApp({super.key, required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameSessionController>.value(
      value: controller,
      child: MaterialApp(
        title: 'Superbird',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6FAFF),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const HomeScreen(),
          '/shop': (_) => const ShopScreen(),
        },
      ),
    );
  }
}

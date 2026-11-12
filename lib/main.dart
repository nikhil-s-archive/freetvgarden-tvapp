import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/repo.dart';
import 'services/store.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive landscape mode for TV and large screens
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();
  final store = Store(prefs);
  final repo = Repo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Store>.value(value: store),
        Provider<Repo>.value(value: repo),
      ],
      child: const FreeTvGardenApp(),
    ),
  );
}

class FreeTvGardenApp extends StatelessWidget {
  const FreeTvGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final repo = context.read<Repo>();

    return MaterialApp(
      title: 'FreeTvGarden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: aestheticDark,
        canvasColor: aestheticDark,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: iosBlue,
          surface: aestheticSurface,
          background: aestheticDark,
        ),
      ),
      home: HomeScreen(store: store, repo: repo),
    );
  }
}

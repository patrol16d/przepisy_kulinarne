import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:przepisy_kulinarne/theme_manager.dart';
import 'list_of_ingredients.dart';
import 'countdown_timer.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Map<String, dynamic> timers = {};

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'Przepisy Kulinarne',
        channelName: 'Przepisy Kulinarne',
        channelDescription: 'Powiadomienia o zakończeniu stopera',
        playSound: true,
        ledColor: Colors.white,
        enableLights: true,
        enableVibration: true,
      ),
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StateOfTheme(),
      builder: (context, _) => ChangeNotifierProvider(
        create: (context) => StateOfTimers(),
        child: ChangeNotifierProvider(
          create: (context) => StateOfIngredients(),
          child: MaterialApp(
            theme: ThemeData(
              dividerTheme: const DividerThemeData(
                color: Colors.lightGreen,
                thickness: 3,
              ),
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.green,
              ),
              tabBarTheme:
                  const TabBarTheme(indicator: UnderlineTabIndicator()),
            ),
            darkTheme: ThemeData.dark().copyWith(
              dividerTheme: const DividerThemeData(
                thickness: 3,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                ),
              ),
            ),
            themeMode: Provider.of<StateOfTheme>(context).theme,
            debugShowCheckedModeBanner: false,
            home: const DefaultTabController(
              length: 3,
              child: HomePage(),
            ),
          ),
        ),
      ),
    );
  }
}

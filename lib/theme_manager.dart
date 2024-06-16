import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateOfTheme with ChangeNotifier {
  ThemeMode _theme = ThemeMode.dark;
  SharedPreferences? pref;

  StateOfTheme() {
    init();
  }

  void init() async {
    if (pref == null) {
      pref = await SharedPreferences.getInstance();
      if ((pref?.containsKey('darkTheme') ?? false) == false) {
        pref?.setBool('darkTheme', true);
      } else {
        if (pref?.getBool('darkTheme') == false) {
          _theme = ThemeMode.light;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        } else {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        }
        notifyListeners();
      }
    }
  }

  ThemeMode get theme => _theme;

  void toggle() {
    if (_theme == ThemeMode.dark) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      _theme = ThemeMode.light;
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      _theme = ThemeMode.dark;
    }

    pref?.setBool('darkTheme', _theme == ThemeMode.dark);

    notifyListeners();
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<StateOfTheme>(context, listen: false);
    return IconButton(
      icon: const Icon(Icons.dark_mode),
      onPressed: () => theme.toggle(),
    );
  }
}

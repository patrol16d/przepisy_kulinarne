import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'recipe_page.dart';

class StateOfTimers with ChangeNotifier {
  String? _timeZone;
  final Map<String, dynamic> _timers = {};

  Map<String, dynamic> get timers => _timers;

  add({id, date, recipe}) async {
    _timeZone ??= await AwesomeNotifications().getLocalTimeZoneIdentifier();

    _timers[id] = {'date': date, 'recipe': recipe, 'startDate': DateTime.now()};

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id.hashCode,
        channelKey: 'Przepisy Kulinarne',
        title: "Kociec czasu",
        icon: 'assets/logo.png',
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: true,
        criticalAlert: true,
      ),
      schedule: NotificationInterval(
        interval: date.difference(DateTime.now()).inSeconds,
        timeZone: _timeZone,
        repeats: false,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );

    while (_timers.containsKey(id) &&
        date.difference(DateTime.now()).inSeconds > 0) {
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }
    notifyListeners();
  }

  Color getColor(String id) {
    int allDuration =
        _timers[id]['date'].difference(_timers[id]['startDate']).inSeconds;
    int timeLeft = _timers[id]['date'].difference(DateTime.now()).inSeconds;
    if (allDuration < 1) allDuration = 1;

    return Color.lerp(
          Colors.red,
          Colors.orange,
          (timeLeft / allDuration).clamp(0, 1),
        ) ??
        Colors.red;
  }

  remove(id) {
    AwesomeNotifications().cancel(id.hashCode);
    _timers.remove(id);
    notifyListeners();
  }
}

class CountdownTimer extends StatelessWidget {
  final String id;
  const CountdownTimer({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = Provider.of<StateOfTimers>(context).timers;
    final Duration timeLeft =
        (time[id]['date'] ?? DateTime.now()).difference(DateTime.now());

    final String timeDisplay = timeLeft.inSeconds > 1
        ? timeLeft.toString().split('.').first
        : 'Koniec czasu';

    return Text(timeDisplay);
  }
}

class ListOfTimers extends StatelessWidget {
  final String? recipeId;

  const ListOfTimers({Key? key, this.recipeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StateOfTimers>(
      builder: (context, state, _) => Container(
        padding: const EdgeInsets.only(top: 10, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(
            state.timers.length,
            (index) => ElevatedButton(
              onPressed: state.timers.keys
                      .toList()[index]
                      .startsWith(recipeId ?? 'aaaaaaaaaaaaaaa')
                  ? () => {}
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => RecipePage(
                              recipe: state.timers.values.toList()[index]
                                  ['recipe']),
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                primary: state.getColor(state.timers.keys.toList()[index]),
              ),
              child: CountdownTimer(
                id: state.timers.keys.toList()[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

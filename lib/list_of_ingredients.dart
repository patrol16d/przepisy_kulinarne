import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'recipe.dart';

class StateOfIngredients with ChangeNotifier {
  final Map<String, List<dynamic>> _ingredients = {};
  Map<String, List<dynamic>> get ingredients => _ingredients;

  void addOrDelite(String id, List<String> list) {
    if (_ingredients.containsKey(id)) {
      _ingredients.remove(id);
    } else {
      _ingredients[id] = list.map((e) => {'ing': e, 'done': false}).toList();
    }

    notifyListeners();
  }

  remove(String id) {
    _ingredients.remove(id);
    notifyListeners();
  }

  removeAll() {
    _ingredients.clear();
    notifyListeners();
  }

  List<dynamic> listOfAll() {
    return _ingredients.values.toList().expand((x) => x).toList();
  }

  bool get hasAny => _ingredients.isNotEmpty;
}

class ListOfIngredients extends StatefulWidget {
  const ListOfIngredients({super.key});

  @override
  State<ListOfIngredients> createState() => _ListOfIngredientsState();
}

class _ListOfIngredientsState extends State<ListOfIngredients> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateOfIngredients>(
      builder: (context, state, _) => ListView.builder(
        itemCount: state.listOfAll().length,
        itemBuilder: (context, index) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            state.listOfAll()[index]['done']
                ? Icons.check_box
                : Icons.check_box_outline_blank_rounded,
            color:
                state.listOfAll()[index]['done'] ? Colors.green : Colors.grey,
          ),
          title: Text(state.listOfAll()[index]['ing']),
          subtitle:
              Text(Recipe.subDescription(state.listOfAll()[index]['ing'])),
          onTap: () => setState(
            () => state.listOfAll()[index]['done'] =
                state.listOfAll()[index]['done'] == false,
          ),
        ),
      ),
    );
  }
}

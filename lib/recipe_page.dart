import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:przepisy_kulinarne/countdown_timer.dart';

import 'database_service.dart';
import 'recipe.dart';
import 'theme_manager.dart';

class RecipePage extends StatefulWidget {
  final Recipe recipe;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  RecipePage({required this.recipe});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        actions: const [ThemeToggleButton()],
      ),
      body: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          ListView.builder(
            itemCount: 6 +
                widget.recipe.ingredients.length +
                widget.recipe.steps.length,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return widget.recipe.images.isEmpty
                      ? Container()
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.recipe.images.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                future: storage
                                    .downloadURL(widget.recipe.images[index]),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<String> snapshot,
                                ) {
                                  if (snapshot.hasError) {
                                    return Text('Error - ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    final imageURL = snapshot.data!;
                                    return GestureDetector(
                                      child: Image.network(
                                        imageURL,
                                        fit: BoxFit.cover,
                                      ),
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  GestureDetector(
                                                    onTap: Navigator.of(context)
                                                        .pop,
                                                    child:
                                                        Image.network(imageURL),
                                                  ))),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              );
                            },
                          ),
                        );
                case 1:
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Text(
                      'Opis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                case 2:
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: Text(
                      widget.recipe.description,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  );
                case 3:
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Text(
                      'Lista składników',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
              }
              if (index < 4 + widget.recipe.ingredients.length) {
                return ListTile(
                  title: Text(widget.recipe.ingredients[index - 4]),
                  subtitle: Text(Recipe.subDescription(
                      widget.recipe.ingredients[index - 4])),
                  minLeadingWidth: 20,
                  leading: const Icon(Icons.adjust, size: 20),
                );
              }
              if (index == 4 + widget.recipe.ingredients.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Text(
                    'Lista kroków',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              if (index <
                  5 +
                      widget.recipe.ingredients.length +
                      widget.recipe.steps.length) {
                int i = index - 5 - widget.recipe.ingredients.length;
                final state = Provider.of<StateOfTimers>(context);
                return GestureDetector(
                  child: Container(
                    color: state.timers.containsKey('${widget.recipe.id}$i')
                        ? state.getColor('${widget.recipe.id}$i')
                        : Colors.transparent,
                    child: ListTile(
                      title: Text(widget.recipe.steps[i]),
                      minLeadingWidth: 20,
                      leading: Recipe.hasTime(widget.recipe.steps[i]) > 0
                          ? const Icon(Icons.access_time_rounded, size: 20)
                          : const Icon(Icons.adjust, size: 20),
                      subtitle:
                          state.timers.containsKey('${widget.recipe.id}$i')
                              ? CountdownTimer(id: '${widget.recipe.id}$i')
                              : const Text(''),
                    ),
                  ),
                  onTap: () {
                    if (Recipe.hasTime(widget.recipe.steps[i]) > 0) {
                      setState(() {
                        if (state.timers.containsKey('${widget.recipe.id}$i')) {
                          state.remove('${widget.recipe.id}$i');
                        } else {
                          state.add(
                            id: '${widget.recipe.id}$i',
                            date: DateTime.now().add(
                              Duration(
                                  minutes:
                                      Recipe.hasTime(widget.recipe.steps[i])),
                            ),
                            recipe: widget.recipe,
                          );
                        }
                      });
                    }
                  },
                );
              }
              return Container();
            },
          ),
          ListOfTimers(recipeId: widget.recipe.id),
        ],
      ),
    );
  }

  List<dynamic> mapToList(Map<String, dynamic> t) {
    final list = [];
    t.forEach((key, value) =>
        key != widget.recipe.id ? value.forEach((k, v) => list.add(v)) : null);
    return list;
  }
}

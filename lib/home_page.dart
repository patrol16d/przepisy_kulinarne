import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_or_edit_recipe_page.dart';
import 'database_service.dart';
import 'list_of_ingredients.dart';
import 'recipe.dart';
import 'recipe_page.dart';
import 'countdown_timer.dart';
import 'theme_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int _bottomIndex = 0;

  final Storage storage = Storage();
  final Cloud cloud = Cloud();
  List<String> categories = ['Ciasta', 'Dania', 'Desery'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future _showDialog(Recipe recipe, int index) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Co chciałbyś zrobić z tym przepisem'),
          actions: [
            TextButton(
              child: const Text('Edytować'),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (BuildContext context) => AddOrEditRecipePage(
                          type: categories[_tabIndex], recipe: recipe),
                    ))
                    .then((_) => Future.delayed(const Duration(seconds: 1)))
                    .then((_) => setState(() => {}));
              },
            ),
            TextButton(
              child: const Text(
                'Usunąć',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                for (String fileName in recipe.images) {
                  storage.deleteFile(fileName);
                }
                cloud.deleteRecipe(
                  recipe.id,
                  categories[index],
                );
                Navigator.pop(context, 'OK');
              },
            ),
            TextButton(
              child: const Text('Nic'),
              onPressed: () => Navigator.pop(context, 'Cancel'),
            ),
          ],
        ),
      );

  BottomNavigationBar? _myBottomNavigationBar() {
    final state = Provider.of<StateOfIngredients>(context);
    return state.hasAny
        ? BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_rounded),
                label: 'Przepisy',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_rounded),
                label: 'Lista składników',
              )
            ],
            currentIndex: _bottomIndex,
            onTap: (index) => setState(() => _bottomIndex = index),
          )
        : null;
  }

  Widget _recipeTile(Recipe recipe, index) => InkWell(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: FutureBuilder(
                  future: storage.downloadURL(recipe.images.isEmpty
                      ? Recipe.defaultImg
                      : recipe.images[0]),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<String> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Text('Error - ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final imageURL = snapshot.data!;
                      final state = Provider.of<StateOfIngredients>(context);
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageURL,
                            fit: BoxFit.cover,
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            alignment: state.ingredients.containsKey(recipe.id)
                                ? const Alignment(-1, -1)
                                : const Alignment(0, 0),
                            curve: Curves.bounceOut,
                            child: AnimatedScale(
                              curve: Curves.easeOutCirc,
                              duration: const Duration(milliseconds: 500),
                              scale: state.ingredients.containsKey(recipe.id)
                                  ? 1
                                  : 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                // ignore: prefer_const_constructors
                                child: Icon(
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      color: Colors.black,
                                      blurRadius: 10,
                                    ),
                                  ],
                                  Icons.format_list_bulleted_rounded,
                                  color: state.ingredients[recipe.id]
                                              ?.every((e) => e['done']) ??
                                          false
                                      ? Colors.greenAccent
                                      : Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(fontSize: 25),
                      ),
                      const Divider(height: 8),
                      Text(
                        recipe.description,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (BuildContext context) => RecipePage(recipe: recipe),
            ))
            .then((_) => setState(() => {})),
        onLongPress: () => _showDialog(recipe, index),
        onDoubleTap: () => setState(() =>
            Provider.of<StateOfIngredients>(context, listen: false)
                .addOrDelite(recipe.id, recipe.ingredients)),
      );

  @override
  Widget build(BuildContext context) {
    if (_bottomIndex == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(categories[_tabIndex]),
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState(() => _tabIndex = index);
            },
            tabs: const [
              Tab(icon: Icon(Icons.cake_rounded)),
              Tab(icon: Icon(Icons.food_bank_rounded)),
              Tab(icon: Icon(Icons.cookie_rounded)),
            ],
          ),
          actions: const [ThemeToggleButton()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      AddOrEditRecipePage(type: categories[_tabIndex]),
                ),
              )
              .then((_) => Future.delayed(const Duration(seconds: 1)))
              .then((_) => setState(() => {})),
          child: const Icon(Icons.add),
        ),
        body: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            TabBarView(
              controller: _tabController,
              children: List<Widget>.generate(
                categories.length,
                (int index) => StreamBuilder<List<Recipe>>(
                  stream: cloud.readRecipes(categories[index]),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error - ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final recipies = snapshot.data!;
                      return ListView(
                        children: recipies
                            .map((recipe) => _recipeTile(recipe, index))
                            .toList(),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            const ListOfTimers(),
          ],
        ),
        bottomNavigationBar: _myBottomNavigationBar(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista składników'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              Provider.of<StateOfIngredients>(context, listen: false)
                  .removeAll();
              _bottomIndex = 0;
            });
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.delete)),
      body: const ListOfIngredients(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded),
            label: 'Przepisy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: 'Lista składników',
          )
        ],
        currentIndex: _bottomIndex,
        onTap: (index) => setState(() => _bottomIndex = index),
      ),
    );
  }
}

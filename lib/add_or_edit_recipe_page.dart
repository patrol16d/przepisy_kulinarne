import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'database_service.dart';
import 'recipe.dart';
import 'theme_manager.dart';

// ignore: must_be_immutable
class AddOrEditRecipePage extends StatefulWidget {
  final String type;
  Recipe? recipe;
  AddOrEditRecipePage({Key? key, required this.type, this.recipe})
      : super(key: key);

  @override
  State<AddOrEditRecipePage> createState() => _AddOrEditRecipePageState();
}

class _AddOrEditRecipePageState extends State<AddOrEditRecipePage> {
  final List<File> _images = [];
  final List<String> _imagesToDelete = [];
  List<String> _ingredients = [];
  List<String> _steps = [];
  final Storage storage = Storage();
  final Cloud cloud = Cloud();
  late TextEditingController titleControler;
  late TextEditingController descriptionControler;
  bool edit = false;

  @override
  void initState() {
    super.initState();

    edit = widget.recipe != null;

    titleControler = TextEditingController(text: widget.recipe?.title);
    descriptionControler =
        TextEditingController(text: widget.recipe?.description);

    _ingredients = widget.recipe?.ingredients ?? [];
    _steps = widget.recipe?.steps ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          edit ? 'Edycja przepisu' : 'Dodaj nowy przepis',
        ),
        actions: const [ThemeToggleButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (titleControler.text.isEmpty) {
            const snackBar = SnackBar(content: Text('Dodaj tytuł'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            if (edit) {
              await cloud.deleteRecipe(widget.recipe!.id, widget.type);
              for (String fileName in widget.recipe!.images) {
                if (_imagesToDelete.contains(fileName)) {
                  await storage.deleteFile(fileName);
                }
              }
            }

            for (var element in _images) {
              await storage.uploadFile(element, element.path.split('/').last);
            }

            await cloud
                .uploadRecipe(
                    Recipe(
                      title: titleControler.text,
                      description: descriptionControler.text,
                      images: (widget.recipe?.images ?? []) +
                          _images.map((i) => i.path.split('/').last).toList(),
                      ingredients: _ingredients,
                      steps: _steps,
                    ),
                    widget.type)
                .then((_) => Navigator.of(context).pop());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 9 + _ingredients.length + _steps.length,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: TextField(
                  controller: titleControler,
                  decoration: const InputDecoration(
                    hintText: 'Wpisz tytuł przepisu',
                  ),
                ),
              );
            case 1:
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Text(
                  'Zdjęcia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            case 2:
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      (widget.recipe?.images.length ?? 0) + _images.length + 1,
                  itemBuilder: (context, ii) {
                    int i = (widget.recipe?.images.length ?? 0);
                    return ii == _images.length + i
                        ? Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: ElevatedButton(
                              onPressed: () => showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        pickImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Zrób zdjęcie'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        pickImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Wybierz z telefonu'),
                                    ),
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                              child: const Icon(Icons.add_a_photo_rounded,
                                  size: 30),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ii < i
                                    ? FutureBuilder(
                                        future: storage.downloadURL(
                                            widget.recipe?.images[ii]),
                                        builder: (
                                          BuildContext context,
                                          AsyncSnapshot<String> snapshot,
                                        ) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error - ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            final imageURL = snapshot.data!;
                                            return Image.network(
                                              imageURL,
                                              fit: BoxFit.cover,
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      )
                                    : Image.file(
                                        _images[ii - i],
                                      ),
                                InkWell(
                                  onTap: () => setState(
                                    () => ii < i
                                        ? {
                                            _imagesToDelete.add(
                                                widget.recipe?.images[ii] ??
                                                    ''),
                                            widget.recipe?.images.removeAt(ii)
                                          }
                                        : _images.removeAt(ii - i),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(5.0),
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 30),
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),
              );
            case 3:
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Text(
                  'Krótki opis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            case 4:
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: TextField(
                  controller: descriptionControler,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Wpisz krótki opis',
                  ),
                ),
              );
            case 5:
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
          if (index < 6 + _ingredients.length) {
            return ListTile(
              title: Text(_ingredients[index - 6]),
              subtitle: Text(Recipe.subDescription(_ingredients[index - 6])),
              minLeadingWidth: 20,
              leading: const Icon(Icons.adjust, size: 20),
              trailing: IconButton(
                onPressed: () => {
                  setState(() {
                    _ingredients.removeAt(index - 6);
                  })
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              onLongPress: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Edycja'),
                  content: TextFormField(
                    initialValue: _ingredients[index - 6],
                    onFieldSubmitted: (String value) {
                      setState(() => {
                            if (value.isNotEmpty)
                              {_ingredients[index - 6] = value}
                          });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            );
          }
          if (index == 6 + _ingredients.length) {
            return ListTile(
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'Wpisz składnik',
                ),
                onSubmitted: (String value) => {
                  setState(() => {
                        if (value.isNotEmpty) {_ingredients.add(value)}
                      })
                },
              ),
            );
          }
          if (index == 7 + _ingredients.length) {
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
          if (index < 8 + _ingredients.length + _steps.length) {
            return ListTile(
              title: Text(_steps[index - 8 - _ingredients.length]),
              minLeadingWidth: 20,
              leading:
                  Recipe.hasTime(_steps[index - 8 - _ingredients.length]) > 0
                      ? const Icon(Icons.access_time_rounded, size: 20)
                      : const Icon(Icons.adjust, size: 20),
              trailing: IconButton(
                onPressed: () => {
                  setState(() {
                    _steps.removeAt(index - 8 - _ingredients.length);
                  })
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              onLongPress: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Edycja'),
                  content: TextFormField(
                    initialValue: _steps[index - 8 - _ingredients.length],
                    onFieldSubmitted: (String value) {
                      setState(() => {
                            if (value.isNotEmpty) {_steps[index - 6] = value}
                          });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            );
          }
          return ListTile(
            title: TextField(
              decoration: const InputDecoration(
                hintText: 'Wpisz krok',
              ),
              onSubmitted: (String value) => {
                setState(() {
                  _steps.add(value);
                })
              },
            ),
          );
        },
      ),
    );
  }

  Future pickImage(source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } on PlatformException catch (e) {
      debugPrint("Nie udało się wczytać zdjęcia: ${e.message}");
    }
  }
}

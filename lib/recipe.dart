class Recipe {
  String id;
  String title = '';
  List<String> images = [];
  String description = '';
  List<String> ingredients = [];
  List<String> steps = [];

  static const String defaultImg =
      'https://storcpdkenticomedia.blob.core.windows.net/media/recipemanagementsystem/media/recipe-media-files/recipes/retail/x17/rainbow-cake760x580.jpg?ext=.jpg';

  Recipe({
    this.id = '',
    required this.title,
    required this.images,
    required this.description,
    required this.ingredients,
    required this.steps,
  }) {
    //Storage storage = Storage();
    //imagesURL = images.map((i) => storage.downloadURL(i)).toList();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'images': images,
        'description': description,
        'ingredients': ingredients,
        'steps': steps
      };

  static Recipe fromJson(Map<String, dynamic> jsonFile, String id) => Recipe(
        id: id,
        title: jsonFile.containsKey('title') ? jsonFile['title'] : '',
        images: jsonFile.containsKey('images')
            ? jsonFile['images'].cast<String>()
            : [],
        description:
            jsonFile.containsKey('description') ? jsonFile['description'] : '',
        ingredients: jsonFile.containsKey('ingredients')
            ? jsonFile['ingredients'].cast<String>()
            : [],
        steps: jsonFile.containsKey('steps')
            ? jsonFile['steps'].cast<String>()
            : [],
      );

  static String subDescription(String title) {
    if (title.isEmpty) return '';

    final strings = title.split(' ');

    if (strings.length < 3) return '';

    double amount = double.tryParse(strings[0]) ?? 0;
    String type = strings[1].toLowerCase();
    String ingridient = strings[2].toLowerCase();

    if (amount > 0) {
      if (type.startsWith("szklan")) {
        if (ingridient == 'mąki') {
          return '${(amount * 170).toInt()}g';
        } else if (ingridient == 'cukru') {
          if (strings.length > 3 && strings[3].toLowerCase() == 'pudru') {
            return '${(amount * 170).toInt()}g';
          } else {
            return '${(amount * 220).toInt()}g';
          }
        } else if (ingridient == 'oleju') {
          return '${(amount * 220).toInt()}g';
        } else if (ingridient == 'wody') {
          if (strings.length > 2 && strings[3].toLowerCase() == 'gazowanej') {
            return '${(amount * 240).toInt()}g';
          } else {
            return '${(amount * 250).toInt()}g';
          }
        } else if (ingridient == 'mleka') {
          return '${(amount * 250).toInt()}g';
        } else if (ingridient == 'śmietany' && strings.length > 2) {
          if (strings[3].startsWith('30')) {
            return '${(amount * 270).toInt()}g';
          } else if (strings[3].startsWith('18')) {
            return '${(amount * 220).toInt()}g';
          }
        }
      } else if (type.startsWith("łyżk") || type.startsWith("łyżeczk")) {
        if (type.startsWith("łyżeczk")) amount /= 3;
        if (ingridient == 'mąki') {
          return '${(amount * 10).toInt()}g';
        } else if (ingridient == 'cukru') {
          if (strings.length > 3 && strings[3].toLowerCase() == 'pudru') {
            return '${(amount * 12).toInt()}g';
          } else {
            return '${(amount * 15).toInt()}g';
          }
        } else if (ingridient == 'oleju') {
          return '${(amount * 15).toInt()}g';
        } else if (ingridient == 'mleka') {
          return '${(amount * 15).toInt()}g';
        }
      }
    }
    return '';
  }

  static int hasTime(String title) {
    RegExp exp = RegExp(r'(\d*\.?\d+ min)|(\d*\.?\d+ godz)|(\d*\.?\d+ h)');
    String lower = title.toLowerCase();

    if (exp.hasMatch(lower)) {
      List<String> output =
          (exp.firstMatch(lower)?.group(0) ?? '0 s').split(' ');
      double number = double.parse(output[0]);
      int type = (output[1].startsWith('min') ? 1 : 60);
      return (number * type).round();
    }

    return 0;
  }
}

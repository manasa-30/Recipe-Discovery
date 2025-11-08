import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ===============================
/// 🧩 MODEL
/// ===============================
class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final String prepTime;
  final String cookTime;
  final String servings;
  final double rating;

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.rating,
  });
}

/// ===============================
/// 🧠 PROVIDER
/// ===============================
class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];
  final List<Recipe> _favorites = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('https://dummyjson.com/recipes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recipeList = data['recipes'];
        _recipes = recipeList.map((r) {
          return Recipe(
            id: r['id'].toString(),
            title: r['name'],
            imageUrl: r['image'] ?? '',
            category: r['cuisine'] ?? 'General',
            ingredients: List<String>.from(r['ingredients'] ?? []),
            instructions: List<String>.from(r['instructions'] ?? []),
            prepTime: '${r['prepTimeMinutes']} min',
            cookTime: '${r['cookTimeMinutes']} min',
            servings: '${r['servings']} servings',
            rating: (r['rating'] ?? 4.0).toDouble(),
          );
        }).toList();
      } else {
        _hasError = true;
      }
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFavorite(Recipe recipe) {
    if (_favorites.any((r) => r.id == recipe.id)) {
      _favorites.removeWhere((r) => r.id == recipe.id);
    } else {
      _favorites.add(recipe);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((r) => r.id == id);
  }
}

/// ===============================
/// 🎨 THEME PROVIDER
/// ===============================
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

/// ===============================
/// 🏁 MAIN APP
/// ===============================
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Discovery',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
      home: const MainScreen(),
    );
  }
}

/// ===============================
/// 📱 MAIN SCREEN
/// ===============================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    RecipeListScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

/// ===============================
/// 🔍 RECIPE LIST + SEARCH BAR
/// ===============================
class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    if (recipeProvider.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (recipeProvider.hasError) {
      return const Scaffold(
          body: Center(child: Text('Failed to load recipes.')));
    }

    final filteredRecipes = recipeProvider.recipes.where((recipe) {
      final query = _searchQuery.toLowerCase();
      return recipe.title.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Recipes 🍽'),
        backgroundColor: Colors.orange,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: filteredRecipes.isEmpty
          ? const Center(child: Text('No recipes found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];
                return RecipeCard(recipe: recipe);
              },
            ),
    );
  }
}

/// ===============================
/// 🧁 RECIPE CARD
/// ===============================
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const RecipeCard({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final isFav = provider.isFavorite(recipe.id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(recipe: recipe)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(recipe.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => provider.toggleFavorite(recipe),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// 📜 RECIPE DETAIL SCREEN
/// ===============================
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final isFav = provider.isFavorite(recipe.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.white),
            onPressed: () => provider.toggleFavorite(recipe),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.network(recipe.imageUrl,
              height: 250, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
          const SizedBox(height: 16),
          Text(recipe.title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Category: ${recipe.category}'),
          Text('Servings: ${recipe.servings}'),
          Text('Prep Time: ${recipe.prepTime}, Cook Time: ${recipe.cookTime}'),
          const SizedBox(height: 16),
          const Text('Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...recipe.ingredients.map((e) => Text('• $e')),
          const SizedBox(height: 16),
          const Text('Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...recipe.instructions
              .asMap()
              .entries
              .map((e) => Text('${e.key + 1}. ${e.value}')),
        ],
      ),
    );
  }
}

/// ===============================
/// ❤ FAVORITES SCREEN
/// ===============================
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final favorites = provider.favorites;

    if (favorites.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No favorites yet ❤')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Favorites ❤')),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final recipe = favorites[index];
          return ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(recipe.imageUrl),
                onBackgroundImageError: (_, __) {}),
            title: Text(recipe.title),
            subtitle: Text(recipe.category),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => provider.toggleFavorite(recipe),
            ),
          );
        },
      ),
    );
  }
}

/// ===============================
/// ⚙ SETTINGS SCREEN
/// ===============================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings ⚙')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
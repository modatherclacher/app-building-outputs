import 'package:flutter/material.dart';

import '../data/recipes.dart';
import '../models/recipe.dart';
import '../state/recipe_store.dart';
import 'recipe_card_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeStore _store = RecipeStore(recipes: sampleRecipes);

  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeCardPage(store: _store, recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Card')),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final recipes = _store.recipes;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    recipe.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${recipe.ingredients.length} ingredients · '
                    'serves ${_store.servingsOf(recipe)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openRecipe(recipe),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

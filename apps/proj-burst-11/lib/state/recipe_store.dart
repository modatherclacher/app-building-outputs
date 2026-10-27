import 'package:flutter/foundation.dart';

import '../data/recipes.dart';
import '../models/recipe.dart';

/// In-memory state for the app: recipe catalog, per-recipe serving counts and
/// which ingredients have been checked off. Notifies listeners on every change.
class RecipeStore extends ChangeNotifier {
  RecipeStore({List<Recipe> recipes = sampleRecipes}) : _recipes = recipes;

  final List<Recipe> _recipes;
  final Map<String, int> _servings = {};
  final Set<String> _checked = {};

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  int servingsOf(Recipe recipe) => _servings[recipe.id] ?? recipe.baseServings;

  bool isChecked(Recipe recipe, int index) =>
      _checked.contains('${recipe.id}:$index');

  int checkedCount(Recipe recipe) {
    var count = 0;
    for (var i = 0; i < recipe.ingredients.length; i++) {
      if (isChecked(recipe, i)) count++;
    }
    return count;
  }

  void incrementServings(Recipe recipe) =>
      _setServings(recipe, servingsOf(recipe) + 1);

  void decrementServings(Recipe recipe) =>
      _setServings(recipe, servingsOf(recipe) - 1);

  void _setServings(Recipe recipe, int value) {
    final clamped = value < 1 ? 1 : (value > 99 ? 99 : value);
    if (clamped == servingsOf(recipe)) return;
    _servings[recipe.id] = clamped;
    notifyListeners();
  }

  void toggleIngredient(Recipe recipe, int index) {
    final key = '${recipe.id}:$index';
    if (!_checked.remove(key)) _checked.add(key);
    notifyListeners();
  }

  void resetChecks(Recipe recipe) {
    _checked.removeWhere((key) => key.startsWith('${recipe.id}:'));
    notifyListeners();
  }
}

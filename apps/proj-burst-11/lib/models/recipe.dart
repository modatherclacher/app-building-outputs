import 'package:flutter/foundation.dart';

@immutable
class Ingredient {
  const Ingredient({
    required this.name,
    required this.amount,
    this.unit = '',
  });

  /// Amount of this ingredient for the recipe's [Recipe.baseServings].
  final double amount;

  /// Measurement unit such as "cups" or "tsp"; empty for count-based items.
  final String unit;

  final String name;
}

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.baseServings,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final int baseServings;
  final List<Ingredient> ingredients;
  final List<String> steps;
}

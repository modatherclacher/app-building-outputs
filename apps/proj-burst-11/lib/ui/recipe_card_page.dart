import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../state/recipe_store.dart';
import '../utils/format_amount.dart';

/// The recipe card: scaled ingredient checklist plus a servings stepper.
class RecipeCardPage extends StatelessWidget {
  const RecipeCardPage({super.key, required this.store, required this.recipe});

  final RecipeStore store;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final servings = store.servingsOf(recipe);
        final factor = servings / recipe.baseServings;
        final total = recipe.ingredients.length;
        final checked = store.checkedCount(recipe);

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: [
              IconButton(
                tooltip: 'Reset checked items',
                onPressed:
                    checked == 0 ? null : () => store.resetChecks(recipe),
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(recipe.description,
                        style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text('Servings', style: theme.textTheme.titleMedium),
                      const Spacer(),
                      IconButton(
                        key: const ValueKey('servings-minus'),
                        tooltip: 'Fewer servings',
                        onPressed: servings > 1
                            ? () => store.decrementServings(recipe)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$servings',
                          key: const ValueKey('servings-count'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('servings-plus'),
                        tooltip: 'More servings',
                        onPressed: servings < 99
                            ? () => store.incrementServings(recipe)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Ingredients', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('$checked of $total checked',
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: total == 0 ? 0.0 : checked / total,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              ...List.generate(total, (i) {
                final ingredient = recipe.ingredients[i];
                final isChecked = store.isChecked(recipe, i);
                return CheckboxListTile(
                  value: isChecked,
                  onChanged: (_) => store.toggleIngredient(recipe, i),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    ingredientLabel(
                      ingredient.name,
                      ingredient.unit,
                      ingredient.amount * factor,
                    ),
                    style: TextStyle(
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text('Steps', style: theme.textTheme.headlineSmall),
              ...List.generate(recipe.steps.length, (i) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text('${i + 1}'),
                  ),
                  title: Text(recipe.steps[i]),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

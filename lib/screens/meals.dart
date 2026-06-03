import 'package:flutter/material.dart';
import 'package:meal/models/meal.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key, required this.title, required this.meals});

  final String title;
  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (meals.isEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No meals found',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try selecting a different category',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    } else {
      content = ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return ListTile(
            leading: Image.network(meal.imageUrl),
            title: Text(meal.title),
            subtitle: Text('${meal.duration} min'),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: content,
    );
  }
}

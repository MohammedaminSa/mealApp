import "package:flutter/material.dart";
import "package:meal/models/meal.dart";
// removed transparent placeholder import; using Image.network loaders instead

class MealItem extends StatelessWidget {
  const MealItem({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                meal.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                child: Text(
                  meal.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

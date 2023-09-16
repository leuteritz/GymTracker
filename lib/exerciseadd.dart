import 'package:flutter/cupertino.dart';

import 'database.dart';

class ExerciseAdd extends StatefulWidget {
  final String name;
  final String muscleGroup;

  ExerciseAdd({required this.muscleGroup, required this.name, Key? key})
      : super(key: key);

  @override
  State<ExerciseAdd> createState() => _ExerciseAddState();
}

class _ExerciseAddState extends State<ExerciseAdd> {
  @override
  void initState() {
    super.initState();
    fetchFavoriteStatus();
  }

  void fetchFavoriteStatus() async {
    final dbHelper = DatabaseHelper();
    bool isFavorite = await dbHelper.isExerciseFavorite(widget.name);
    print("status: $isFavorite");
    if (mounted) {
      setState(() {
        isPressed = isFavorite;
      });
    }
  }

  bool isPressed = false;

  void _toggleHeart() {
    setState(() {
      isPressed = !isPressed;
    });
  }

  void updateFavorite(String name) async {
    final dbHelper = DatabaseHelper();
    if (isPressed) {
      await dbHelper.updateExerciseFavoriteStatus(name, 1);
    } else {
      await dbHelper.updateExerciseFavoriteStatus(name, 0);
    }
  }

  String getFirstLetter() {
    return widget.name[0];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      leading: Text(getFirstLetter()),
      title: Text(widget.name),
      subtitle: Text(widget.muscleGroup),
      trailing: CupertinoButton(
        child: Icon(
          isPressed ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        ),
        onPressed: () {
          _toggleHeart();
          updateFavorite(widget.name);

          fetchFavoriteStatus();
        },
      ),
    );
  }
}
